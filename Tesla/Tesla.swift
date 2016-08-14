import Foundation
import RxSwift

//Action

public protocol TeslaAction : AnyObject {
    
}

//ActionService

public class ActionServiceCallback {
    let pipeline:PublishSubject<ActionState<AnyObject>>
    
    public init(_ pipeline:PublishSubject<ActionState<AnyObject>>) {
        self.pipeline = pipeline
    }
    
    public func onStart(_ action:TeslaAction) {
        self.pipeline.onNext(ActionState.Running(action, 0))
    }
    
    public func onProgress(_ action:TeslaAction, progress:Float) {
        self.pipeline.onNext(ActionState.Running(action, progress))
    }
    
    public func onSuccess(_ action:TeslaAction) {
        self.pipeline.onNext(ActionState.Success(action))
    }
    
    public func onError(_ action:TeslaAction, error:Error) {
        self.pipeline.onNext(ActionState.Error(action, error))
    }
}

public protocol ActionService {
    func acceptsType(_ action:Any.Type) -> Bool
    func execute(_ action:TeslaAction)
    func cancel(_ action:TeslaAction)
    
    var callback:ActionServiceCallback? { set get }
}

public protocol TypedActionService : ActionService {
    associatedtype ActionType
    func executeAction(_ action:ActionType) throws
    
    func onStart(_ action:ActionType)
    func onProgress(_ action:ActionType, progress:Float)
    func onSuccess(_ action:ActionType)
    func onError(_ action:ActionType, error:Error)
}

public extension TypedActionService {
    func onStart(_ action:ActionType) {
        if let teslaAction = action as? TeslaAction {
            self.callback?.onStart(teslaAction)
        }
    }
    
    func onProgress(_ action:ActionType, progress:Float) {
        if let teslaAction = action as? TeslaAction {
            self.callback?.onProgress(teslaAction, progress:progress)
        }
    }
    
    func onSuccess(_ action:ActionType) {
        if let teslaAction = action as? TeslaAction {
            self.callback?.onSuccess(teslaAction)
        }
    }
    
    func onError(_ action:ActionType, error:Error) {
        if let teslaAction = action as? TeslaAction {
            self.callback?.onError(teslaAction, error:error)
        }
    }
}

public extension TypedActionService {
    func execute(_ action:TeslaAction) {
        if let serviceAction = action as? ActionType {
            do {
                try self.executeAction(serviceAction)
            } catch {
                self.callback?.onError(action, error: error)
            }
        } else {
            fatalError("Can't cast action")
        }
    }
    
    func cancel(_ action:TeslaAction) {
        
    }
}

public class ActionServiceDecorator : ActionService {
    
    public var callback:ActionServiceCallback? {
        didSet {
            self.decoratedService.callback = self.callback
        }
    }
    
    var decoratedService:ActionService
    
    init(decoratedService:ActionService) {
        self.decoratedService = decoratedService
    }
    
    public func acceptsType(_ action:Any.Type) -> Bool {
        return self.decoratedService.acceptsType(action)
    }
    
    public func execute(_ action:TeslaAction) {
        print(action)
        self.decoratedService.execute(action)
    }
    
    public func cancel(_ action:TeslaAction) {
        self.decoratedService.cancel(action)
    }
}

//ActionState

public protocol ActionStateHolder {
    func castTo<A>() -> ActionState<A>
}

public enum ActionState<T:AnyObject> : ActionStateHolder {
    
    case Running(T, Float)
    case Success(T)
    case Error(T, Error)
    
    public func castTo<A>() -> ActionState<A> {
        switch self {
        case .Running(let action, let progress):
            return ActionState<A>.Running(action as! A, progress)
        case .Success(let action):
            return ActionState<A>.Success(action as! A)
        case .Error(let action, let error):
            return ActionState<A>.Error(action as! A, error)
        }
    }
    
    func canCastTo<A>(_ actionType:A.Type) -> Bool {
        return self.action() is A
    }
    
    public func action() -> T {
        switch self {
        case .Running(let action, _):
            return action
        case .Success(let action):
            return action
        case .Error(let action, _):
            return action
        }
    }
}

//Pipe

public class ReadActionPipe<T:AnyObject where T:TeslaAction> {
    let pipeline:Observable<ActionState<T>>
    let cachedPipeline:Observable<ActionState<T>>
    
    init(pipeline:Observable<ActionState<T>>) {
        self.pipeline = pipeline
        
        self.cachedPipeline = pipeline.replay(1).refCount()
        _ = self.cachedPipeline.subscribe()
    }
    
    public func observe() -> Observable<ActionState<T>> {
        return self.pipeline
    }
    
    public func observeWithReplay() -> Observable<ActionState<T>> {
        return self.cachedPipeline
    }
}

public class ActionPipe<T:TeslaAction> : ReadActionPipe<T> {
    
    typealias ActionSender<T:TeslaAction> = (action:T) -> Observable<ActionState<T>>
    typealias ActionCancel<T:TeslaAction> = (action:T) -> Void
    
    let actionSend:ActionSender<T>
    let actionCancel:ActionCancel<T>
    let scheduler:SchedulerType?
    
    init(actionSend:ActionSender<T>, pipeline:Observable<ActionState<T>>, scheduler:SchedulerType?, actionCancel:ActionCancel<T>) {
        self.actionSend = actionSend
        self.scheduler = scheduler
        self.actionCancel = actionCancel
        super.init(pipeline: pipeline)
    }
    
    @discardableResult
    public func send(_ action:T) -> Observable<ActionState<T>> {
        return send(action, scheduler: self.scheduler)
    }
    
    @discardableResult
    public func send(_ action:T, scheduler:SchedulerType?) -> Observable<ActionState<T>> {
        let observable = actionSend(action: action)
        
        if let observeOnScheduler = scheduler {
            return observable.observeOn(observeOnScheduler)
        } else {
            return observable
        }
    }
    
    public func cancel(_ action:T) {
        self.actionCancel(action: action)
    }
    
    public func cancelLatest() {
        cachedPipeline.take(1).subscribeNext { (item) in
            self.actionCancel(action: item.action())
        }
    }
    
    public func asReadOnly() -> ReadActionPipe<T> {
        return self
    }
}

//Errors

public struct TeslaActionCanceledError : Error {
    
}

//ObservableType

public extension Observable {
    
    @discardableResult
    func subscribeNext(_ onNext: (item:E) -> Void) -> Disposable {
        return self.subscribe(onNext: { (item) in
            onNext(item: item)
        })
    }
}

//Tesla

public protocol TeslaPipeFactory {
    func createPipe<T:AnyObject>(_ actionType:T.Type) -> ActionPipe<T>
    func createPipe<T:AnyObject>(_ actionType:T.Type, scheduler:SchedulerType?) -> ActionPipe<T>
}

public class Tesla : TeslaPipeFactory {
    
    let services:[ActionService]
    let pipeline:PublishSubject<ActionState<AnyObject>> = PublishSubject()
    let serviceCallback:ActionServiceCallback
    
    public init(_ services:[ActionService]) {
        self.services = services
        self.serviceCallback = ActionServiceCallback(self.pipeline)
        
        self.services.forEach { (var service) in
            service.callback = self.serviceCallback
        }
    }
    
    public func createPipe<T:TeslaAction>(_ actionType:T.Type) -> ActionPipe<T> {
        return createPipe(actionType, scheduler: nil)
    }
    
    public func createPipe<T:TeslaAction>(_ actionType:T.Type, scheduler:SchedulerType?) -> ActionPipe<T> {
        return ActionPipe<T>(
            actionSend: self.sendAction,
            pipeline: self.createScopedPipeline(),
            scheduler: scheduler,
            actionCancel: self.cancelAction
        )
    }
    
    private func createScopedPipeline<T:TeslaAction>() -> Observable<ActionState<T>> {
        return self.pipeline.filter { (actionState) -> Bool in
            return actionState.canCastTo(T.self)
            }.map { (actionState) -> ActionState<T> in
                return actionState.castTo()
        }
    }
    
    private func sendAction<T:TeslaAction>(_ action:T) -> Observable<ActionState<T>> {
        guard let service = findService(T.self) else {
            fatalError("Can't find service for actionType:\(action)")
        }
        
        let actionObservable = self.pipeline.filter { (actionState) -> Bool in
            return actionState.action() === action
            }.map { (actionState) -> ActionState<T> in
                return actionState.castTo()
        }
        
        service.execute(action)
        
        return actionObservable
    }
    
    private func findService(_ actionType:Any.Type) -> ActionService? {
        return self.services.first { (service) -> Bool in
            return service.acceptsType(actionType)
        }
    }
    
    private func cancelAction<T:TeslaAction>(action:T) {
        serviceCallback.onError(action, error: TeslaActionCanceledError())
        
        guard let service = findService(T.self) else {
            fatalError("Can't find service for action:\(action)")
        }
        
        service.cancel(action)
    }
}
