//
//  ExampleViewController.swift
//  Example
//
//  Created by xaoxuu on 2018/8/2.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import NoticeBoard
import AXKit
import MarkdownView
import SafariServices
import WebKit

class ExampleViewController: UIViewController {
    
    
    var placeholder = UIImageView()
    let web = WKWebView()
    
    var observer : Any?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "NoticeBoard"
        
        // 加载成功后保存截图，下次启动先显示截图，加载成功后移除截图。
        setupPlaceholder()
        
        
        if let path = Bundle.main.path(forResource: "header.gif", ofType: nil) {
            web.load(URLRequest.init(url: URL.init(fileURLWithPath: path)))
            web.scrollView.isScrollEnabled = false
        }
        
        if let path = Bundle.main.path(forResource: "Examples.md", ofType: nil) {
            do {
                let md = try NSString.init(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
                let mdView = MarkdownView()
                view.insertSubview(mdView, at: 0)
                mdView.frame = view.bounds
                mdView.isScrollEnabled = false
                mdView.load(markdown: md)
                mdView.onRendered = { [weak self] height in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        // 加载成功后保存截图，下次启动先显示截图，加载成功后移除截图。
                        UIView.animate(withDuration: 0.38, animations: {
                            self!.placeholder.alpha = 0
                        }, completion: { (completed) in
                            self!.placeholder.removeFromSuperview()
                            self!.saveImage(UIImage.init(view: mdView))
                            mdView.isScrollEnabled = true
                        })
                    })
                }
                // 外链
                let externalURLs = ["https://github.com/xaoxuu/NoticeBoard/issues",
                                    "https://xaoxuu.com/docs/noticeboard"]
                
                mdView.onTouchLink = { [weak self] request in
                    guard let url = request.url else { return false }
                    
                    if url.scheme == "file" {
                        return false
                    } else if url.scheme == "https" {
                        if externalURLs.contains(url.absoluteString) {
                            UIApplication.shared.openURL(url)
                        } else {
                            let safari = SFSafariViewController(url: url)
                            self?.present(safari, animated: true, completion: nil)
                        }
                        return false
                    } else if url.scheme == "cmd" {
                        if let cmd = url.host, let idx = url.port {
                            if cmd == "fastpost" {
                                self!.postSimpleNotice(idx)
                            } else if cmd == "postcustom" {
                                self!.postCustomView(idx)
                            } else if cmd == "alert" {
                                self!.alert(idx)
                            } else if cmd == "modify" {
                                self!.modify(idx)
                            }
                        }
                        return false
                    } else {
                        return false
                    }
                }
            } catch {
                print(error)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let o = observer {
            NotificationCenter.default.removeObserver(o)
        }
    }
    
    func setupPlaceholder() {
        // placeholder image
        func loadImage() -> UIImage?{
            let path = NSString.init(string: "screenshot.png").docPath() as String
            do {
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
                return UIImage.init(data: data)
            } catch {
                return nil
            }
        }
        placeholder = UIImageView.init(frame: view.bounds)
        placeholder.image = loadImage()
        placeholder.contentMode = .scaleAspectFill
        view.addSubview(placeholder)
        let mask = UIView.init(frame: placeholder.bounds)
        mask.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        placeholder.addSubview(mask)
        // loading
        let w = placeholder.frame.width
        let h = placeholder.frame.height
        let loadingView = UIActivityIndicatorView.init(style: .white)
        loadingView.frame = .init(x: w/2, y: h/2, width: 0, height: 0)
        placeholder.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    func saveImage(_ image: UIImage){
        if let data = image.pngData() {
            let path = NSString.init(string: "screenshot.png").docPath() as String
            let url = URL.init(fileURLWithPath: path)
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                print(error)
            }
        }
    }
    func postSimpleNotice(_ idx: Int){
//        let img = UIImage.init(named: "alert-circle")
//        switch idx {
//        case 1:
//            NoticeBoard.post("Hello World!")
//        case 2:
//            NoticeBoard.post("Hello World!", duration: 2)
//        case 11:
//            NoticeBoard.post(.error, message: "Something Happend", duration: 5)
//        case 12:
//            NoticeBoard.post(.dark, message: "Good evening", duration: 2)
//        case 21:
//            NoticeBoard.post(.light, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
//        case 31:
//            NoticeBoard.post(.light, icon:img, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
//        case 41:
////            NoticeBoard.post(.warning, icon: img, title: "Warning", message: "Please see more info", duration: 0) { (notice, sender) in
////                NoticeBoard.post("button tapped", duration: 1)
////            }
//            break
//        default:
//            print("xxx")
//        }
    }
    
    func postCustomView(_ idx: Int){
        let notice = Notice()
        let w = notice.frame.width
        
        if idx == 1 {
            let h = w * 0.25
            notice.blurMask(.extraLight)
            let view = UIView.init(frame: .init(x: 0, y: 0, width: w, height: h))
            let ww = view.frame.size.width * 0.7
            let hh = CGFloat(h)
            let imgv = UIImageView.init(frame: .init(x: (w-ww)/2, y: (h-hh)/2, width: ww, height: hh))
            imgv.image = UIImage.init(named: "header_center")
            imgv.contentMode = .scaleAspectFit
            view.addSubview(imgv)
            notice.rootViewController?.view.addSubview(view)
//            notice.actionButtonDidTapped(action: { (notice, sender) in
//                if let url = URL.init(string: "https://xaoxuu.com/docs/noticeboard") {
//                    UIApplication.shared.openURL(url)
//                }
//            })
//            notice.actionButton?.setTitle("→", for: .normal)
        } else if idx == 2 {
            let h = w * 0.6
            let view = UIView.init(frame: .init(x: 0, y: 0, width: w, height: h))
            notice.rootViewController?.view.addSubview(view)
            web.frame = view.bounds
            web.scrollView.contentInset.top = -44
            web.scrollView.contentInset.bottom = -44
            view.addSubview(web)
            // icon
            let icon = UIImageView.init(frame: .init(x: w/2 - 30, y: h/2 - 16 - 30, width: 60, height: 60))
            icon.image = UIImage.init(named: Bundle.appIconName())
            icon.contentMode = .scaleAspectFit
            icon.layer.masksToBounds = true
            icon.layer.cornerRadius = 15
            view.addSubview(icon)
            // label
            let lb = UILabel.init(frame: .init(x: 0, y: icon.frame.maxY + 8, width: w, height: 20))
            lb.textAlignment = .center
            lb.font = UIFont.boldSystemFont(ofSize: 14)
            lb.textColor = .white
            lb.text = "\(Bundle.init(for: NoticeBoard.self).bundleName()!) \(Bundle.init(for: NoticeBoard.self).bundleShortVersionString()!)"
            view.addSubview(lb)
            // button
//            notice.actionButtonDidTapped(action: { (notice, sender) in
//                UIView.animate(withDuration: 0.68, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
//                    if sender.transform == .identity {
//                        sender.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 4 * 3)
//                    } else {
//                        sender.transform = .identity
//                    }
//                }, completion: nil)
//            })
//            notice.actionButton?.setTitle("＋", for: .normal)
//            notice.actionButton?.setTitleColor(.white, for: .normal)
        }
        
        NoticeBoard.post(notice)
        
    }
    
    func alert(_ idx: Int){
        if NoticeBoard.shared.notices.count == 0 {
            NoticeBoard.post(title: "消息", message: "这是一条测试消息").duration(0)
        }
        DispatchQueue.main.async {
            for notice in NoticeBoard.shared.notices {
                if idx == 10 {
                    notice.alert(options: [.normally])
                } else if idx == 11 {
                    notice.alert(options: [.slowly])
                } else if idx == 12 {
                    notice.alert(options: [.fast])
                } else if idx == 20 {
                    notice.alert(options: [.darken])
                } else if idx == 21 {
                    notice.alert(options: [.lighten])
                } else if idx == 22 {
                    notice.alert(options: [.flash])
                } else if idx == 30 {
                    notice.alert(options: [.once])
                } else if idx == 31 {
                    notice.alert(options: [.twice])
                } else if idx == 32 {
                    notice.alert(options: [.breathing])
                } else if idx == 101 {
                    notice.alert()
                } else if idx == 102 {
                    notice.alert(options: [.fast, .darken])
                } else if idx == 103 {
                    notice.alert(options: [.slowly, .breathing])
                } else if idx == 104 {
                    notice.alert(options: [.fast, .lighten])
                } else if idx == 105 {
                    notice.alert(options: [.fast, .lighten, .twice])
                }
            }
        }
    }
    
    var modifyNotice: Notice?
    func modify(_ idx: Int){
        func post(){
            modifyNotice?.enableGesture = true
//            if idx == 101 {  
//                modifyNotice?.title = "连接成功"
//                modifyNotice?.body = "你现在可以愉快的使用了"
//                modifyNotice?.theme = .success
//                modifyNotice?.icon = UIImage.init(named: "alert-circle")
//                NoticeBoard.post(modifyNotice!, duration: 2)
//            } else if idx == 102 {
//                modifyNotice?.title = "设备已断开"
//                modifyNotice?.body = "请重新连接设备"
//                modifyNotice?.theme = .error
//                modifyNotice?.icon = UIImage.init(named: "alert-circle")
//                modifyNotice?.enableGesture = false
//                NoticeBoard.post(modifyNotice!)
//            } else if idx == 103 {
//                modifyNotice?.title = "电量过低"
//                modifyNotice?.body = "电量不足10%，请及时给设备充电。"
//                modifyNotice?.theme = .warning
//                modifyNotice?.icon = UIImage.init(named: "alert-circle")
//                NoticeBoard.post(modifyNotice!, duration: 5)
//            }
        }
        if modifyNotice == nil {
            modifyNotice = Notice()
            post()
        } else {
            UIView.animate(withDuration: 0.5) {
                post()
            }
        }
        
    }
    
}
