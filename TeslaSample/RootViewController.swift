//
//  RootViewController.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/9/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import RxSwift
import Tesla

enum API {
    class GoogleAction : HTTPAction<String> {
        let path = Path("https://google.com/?q=" + UUID.init().uuidString)
        let method = HTTPMethod.GET
    }
}

extension UIActivityIndicatorView {
    func observePipe<T>(actionPipe:ActionPipe<T>) {
        weak var weakSelf = self
        
        
        
        actionPipe.observe().subscribeNext { (actionState) in
            if case .Running(_) = actionState {
                weakSelf?.startAnimating()
            } else {
                weakSelf?.stopAnimating()
            }
        }
    }
}

class RootViewController : UIViewController {
    
    let tesla = Tesla([HTTPActionService()])
    let googlePipe:ActionPipe<API.GoogleAction>
    
    lazy var textView:UITextView = {
        let tv = UITextView(frame: self.view.frame)
        tv.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tv.textAlignment = NSTextAlignment.center
        return tv
    }()
    
    init() {
        self.googlePipe = tesla.createPipe(API.GoogleAction.self)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        indicator.hidesWhenStopped = true
        indicator.observePipe(actionPipe: self.googlePipe)
        
        self.navigationItem.titleView = indicator
        
        self.view.addSubview(self.textView)
        
        self.googlePipe.observe().subscribeNext { (actionState) in
            switch actionState {
            case .Success(let action):
                self.textView.text = action.result.value
            case .Error(_, let error):
                self.textView.text = "\n\nLoading failed: \(error)"
            case .Running(_):
                break
            }
        }
    }
    
    func reload() {
        self.googlePipe.send(API.GoogleAction())
    }
    
    func cancel() {
        self.googlePipe.cancelLatest()
    }
}
