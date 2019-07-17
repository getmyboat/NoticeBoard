//
//  DebuggerWindow.swift
//  Example
//
//  Created by xaoxuu on 2018/6/28.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import NoticeBoard


let ax_yellow = UIColor.init(red: 255/255, green: 235/255, blue: 59/255, alpha: 1)
let ax_red = UIColor.init(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
let ax_green = UIColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
let ax_blue = UIColor.init(red: 82/255, green: 161/255, blue: 248/255, alpha: 1)

let isIPhoneX: Bool = {
    if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) || UIScreen.main.bounds.size.equalTo(CGSize.init(width: 812, height: 375)) {
        return true
    } else {
        return false
    }
}()

func topSafeMargin() -> CGFloat {
    if isIPhoneX {
        return 44;
    } else {
        return margin;
    }
}

func bottomSafeMargin() -> CGFloat {
    if isIPhoneX {
        return 34 + margin;
    } else {
        return margin;
    }
}

let margin = CGFloat(8)
let padding = CGFloat(4)
let minH = CGFloat(100)
let titleH = CGFloat(36)
let cellH = CGFloat(36)
let screenSize = UIScreen.main.bounds.size
let leftViewW = CGFloat(50)
let maxWidth = min(UIScreen.main.bounds.size.width - 2 * margin, 500)

func defSize() -> CGSize {
    return CGSize.init(width: maxWidth, height: screenSize.height - topSafeMargin() - bottomSafeMargin())
}
func collapsePoint() -> CGPoint {
    return CGPoint.init(x: (UIScreen.main.bounds.size.width - maxWidth) / 2, y: screenSize.height - minH)
}
func expandPoint() -> CGPoint {
    return CGPoint.init(x: (UIScreen.main.bounds.size.width - maxWidth) / 2, y: topSafeMargin())
}

var keyboardHeight = CGFloat(0)

class DebuggerWindow: UIWindow,UITextViewDelegate,MyTableViewDelegate {
    
    enum Tag: Int {
        typealias RawValue = Int
        
        case bg = 10
        case clean = 11
        case post = 12
        
        case title = 20
        case body = 21
        case icon = 22
        
        case duration = 30
        case scheme = 31
        case blur = 32
        case level = 33
        case layout = 34
        
        var cacheKey : String {
            switch self {
            case .bg:
                return "cache.bg"
            case .clean:
                return "cache.clean"
            case .post:
                return "cache.post"
            case .title:
                return "cache.title"
            case .body:
                return "cache.body"
            case .icon:
                return "cache.icon"
            case .duration:
                return "cache.duration"
            case .scheme:
                return "cache.scheme"
            case .blur:
                return "cache.blur"
            case .level:
                return "cache.level"
            case .layout:
                return "cache.layout"
                
                
            }
        }
    }
    
    var lastFrame = CGRect.init(origin: collapsePoint(), size: defSize())
    lazy var tf_title = UITextField()
    lazy var tv_body = UITextView()
    lazy var lb_duration = UILabel()
    lazy var s_duration = UISlider()

    lazy var seg_icon = UISegmentedControl.init()
    lazy var seg_scheme = UISegmentedControl.init()
    lazy var seg_level = UISegmentedControl.init()
    lazy var seg_layout = UISegmentedControl.init()
    lazy var seg_bg = UISegmentedControl.init()
    
    lazy var table = TableView()
    
    func axBlueColor(alpha: CGFloat) -> UIColor {
        return UIColor.init(red: 82/255, green: 161/255, blue: 248/255, alpha: alpha)
    }
    // MARK: - delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 2
        windowExpand(y: textView.frame.origin.y)
        // tableview
        var f = table.frame
        f.origin.y = textView.frame.maxY + margin
        if f.size.height < 200 {
            f.size.height = 200
        }
        table.frame = f
        table.isHidden = false
        table.loadData(.body)
        updateTableHeight()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        textView.layer.borderWidth = 0
        windowResume()
        UserDefaults.standard.set(textView.text, forKey: Tag.body.cacheKey)
        
        // tableview
        table.isHidden = true
    }
    func tableView(_ tableView: TableView, didSelectTitle: String) {
        if tf_title.isFirstResponder == true {
            tf_title.text = didSelectTitle
        } else if tv_body.isFirstResponder == true {
            tv_body.text = didSelectTitle
        }
    }
    
    
    // MARK: - life cycle
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        windowLevel = UIWindow.Level(rawValue: 9000)
        
        tintColor = axBlueColor(alpha: 1)
        
        layer.shadowRadius = 12
        layer.shadowOffset = .init(width: 0, height: 8)
        layer.shadowOpacity = 0.45
        
        let vev = UIVisualEffectView.init(frame: .init(origin: .zero, size: defSize()))
        vev.effect = UIBlurEffect.init(style: .extraLight)
        let vc = UIViewController()
        rootViewController = vc
        vc.view.layer.cornerRadius = 12
        vc.view.clipsToBounds = true
        vc.view.insertSubview(vev, at: 0)
        
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(_:)))
        self.addGestureRecognizer(pan)
        
        
        // first install
        let notFirstLaunch = UserDefaults.standard.bool(forKey: "notFirstLaunch")
        if !notFirstLaunch {
            UserDefaults.standard.set(true, forKey: "notFirstLaunch")
            UserDefaults.standard.set("this is title", forKey: Tag.title.cacheKey)
            UserDefaults.standard.set("this is body", forKey: Tag.body.cacheKey)
            UserDefaults.standard.set(1, forKey: Tag.icon.cacheKey)
            UserDefaults.standard.set(2, forKey: Tag.duration.cacheKey)
            UserDefaults.standard.set(1, forKey: Tag.scheme.cacheKey)
            UserDefaults.standard.set(1, forKey: Tag.level.cacheKey)
        }
        
        // load subviews
        
        let lb_title = loadLabel(text: "NoticeBoard Debugger")
        lb_title.backgroundColor = UIColor(white: 1, alpha: 0.1)
        lb_title.textAlignment = .center
        lb_title.font = UIFont.boldSystemFont(ofSize: 15)
        vc.view.addSubview(lb_title)
        var f = lb_title.frame
        
        let width = defSize().width - 2*margin
        let h = cellH
        var x = margin
        var y = lb_title.frame.maxY
        func newLine() -> CGFloat {
            y += h + margin
            return y
        }
        
        let btnW = (width - 2 * margin) / 3
        let btn_remove = loadButton(title: "clean")
        btn_remove.frame = .init(x: x, y: y, width: btnW, height: h)
        vc.view.addSubview(btn_remove)
        
        let btn_progress = loadButton(title: "progress")
        btn_progress.frame = .init(x: x+btnW+margin, y: y, width: btnW, height: h)
        vc.view.addSubview(btn_progress)
        
        let btn_post = loadButton(title: "post")
        btn_post.frame = .init(x: x+btnW+margin+btnW+margin, y: y, width: btnW, height: h)
        vc.view.addSubview(btn_post)
        
        
        // title
        tf_title = loadTextField(y: newLine(), title: "title", placeholder: "notice title", text: "notice title")
        vc.view.addSubview(tf_title)
        tf_title.tag = Tag.title.rawValue
        tf_title.text = UserDefaults.standard.string(forKey: Tag.title.cacheKey)
        
        // body
        tv_body = loadTextView(y: newLine(), title: "body")
        tv_body.tag = Tag.body.rawValue
        tv_body.text = UserDefaults.standard.string(forKey: Tag.body.cacheKey)
        vc.view.addSubview(tv_body)
        
        // icon
        y = tv_body.frame.maxY + margin
        seg_icon = loadSegment(y: y, title: "icon", items: ["none","alert-circle"], tag: Tag.icon.rawValue)
        seg_icon.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.icon.cacheKey)
        vc.view.addSubview(seg_icon)
        
        
        // duration
        f.origin.x += f.size.width + margin
        f.size.width = defSize().width - 3 * margin - f.size.width
        s_duration = loadSlider(y: newLine(), title: "duration", min: 0, max: 60)
        vc.view.addSubview(s_duration)
        f = s_duration.frame
        
        // color
        f.origin.y += f.size.height + margin
        f.origin.x = margin
        seg_scheme = loadSegment(y: newLine(), title: "scheme", items: ["plain", "loading", "success", "warning", "error"], tag: Tag.scheme.rawValue)
        seg_scheme.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.scheme.cacheKey)
        vc.view.addSubview(seg_scheme)
        
        
        // layout
        f.origin.y += f.size.height + margin
        seg_layout = loadSegment(y: newLine(), title: "layout", items: ["tile", "stack"], tag: Tag.layout.rawValue)
        seg_layout.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.layout.cacheKey)
        vc.view.addSubview(seg_layout)
        
        // bg
        f.origin.y += f.size.height + margin
        seg_bg = loadSegment(y: newLine(), title: "bg", items: ["guide", "white", "web"], tag: Tag.bg.rawValue)
        seg_bg.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.bg.cacheKey)
        segmentChanged(seg_bg)
        vc.view.addSubview(seg_bg)
        
        
        // footer
        f.origin.y += f.size.height
        f.size = .init(width: defSize().width - 2*margin, height: 24)
        let lb_footer = loadLabel(text: "@xaoxuu")
        lb_footer.font = UIFont.systemFont(ofSize: 12)
        lb_footer.textAlignment = .right
        lb_footer.frame = f
        vc.view.addSubview(lb_footer)
        
        
        var ff = self.frame
        ff.size.height = f.maxY + margin
        self.frame = ff
        ff.origin = .zero
        vc.view.frame = ff
        vev.frame = ff
        transform = .init(translationX: 0, y: minH-ff.size.height-margin)
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            self.transform = .identity
        }) { (completed) in
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // table view
        table = loadTableView()
        table.isHidden = true
        vc.view.addSubview(table)
        
    }
    convenience init() {
        self.init(frame: CGRect.init(origin: collapsePoint(), size: defSize()))
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func windowExpand(y: CGFloat) {
        lastFrame = frame
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            var f = self.frame
            f.origin.y = expandPoint().y - y
            self.frame = f
        }) { (completed) in
            
        }
    }
    func windowCollapse() {
        lastFrame = frame
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            var f = self.frame
            f.origin = collapsePoint()
            self.frame = f
        }) { (completed) in
            
        }
    }
    func windowResume() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.frame = self.lastFrame
        }) { (completed) in
            
        }
    }
    func updateTableHeight(){
        var y = CGFloat(0)
        if self.tf_title.isFirstResponder {
            y = tf_title.frame.height + 2*margin
        } else if self.tv_body.isFirstResponder {
            y = tv_body.frame.height + 2*margin
        }
        var f = self.table.frame
        
        f.size.height = UIScreen.main.bounds.height - y - keyboardHeight - bottomSafeMargin()
        if f.maxY > self.frame.height - margin {
            f.size.height -= f.maxY - self.frame.height + margin
        }
        self.table.frame = f
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}



// MARK: - load
extension DebuggerWindow{
    
    
    func loadLabel(text: String?) -> UILabel {
        let lb = UILabel.init(frame: .init(x: 0, y: 0, width: defSize().width, height: titleH))
        lb.textColor = .darkText
        lb.textAlignment = .justified
        lb.text = text
        return lb
    }
    
    func loadSlider(y: CGFloat, title: String, min: Float, max: Float) -> UISlider{
        lb_duration = loadLabel(text: "duration")
        lb_duration.frame = .init(x: margin, y: y, width: leftViewW, height: cellH)
        self.rootViewController?.view.addSubview(lb_duration)
        
        let s = UISlider.init(frame: .init(x: margin+leftViewW+margin, y: y, width: defSize().width - margin - lb_duration.frame.maxX - margin, height: cellH))
        s.minimumValue = min
        s.maximumValue = max
        let value = UserDefaults.standard.integer(forKey: Tag.duration.cacheKey)
        s.value = Float(value)
        if value > 0 {
            lb_duration.text = "\(value)s"
        } else {
            lb_duration.text = "∞"
        }
        s.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
        return s
    }
    func loadTextField(y: CGFloat, title: String, placeholder: String?, text: String?) -> UITextField {
        let f = createTitleLabelForCell(y: y, title: title)
        
        let tf = UITextField.init(frame: f)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 4
        tf.backgroundColor = UIColor(white: 0, alpha: 0.1)
        tf.returnKeyType = .done
        tf.textColor = .darkText
        tf.clearButtonMode = .whileEditing
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.text = text
        tf.layer.borderColor = ax_red.cgColor
        tf.addTarget(self, action: #selector(self.tfInputBegin(_:)), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(self.tfInputEnd(_:)), for: [.editingDidEnd, .editingDidEndOnExit])
        return tf
    }
    func createTitleLabelForCell(y: CGFloat, title: String) -> CGRect {
        // title
        var f = CGRect.init(x: margin, y: y, width: leftViewW, height: cellH)
        let lb = loadLabel(text: title)
        lb.frame = f
        self.rootViewController?.view.addSubview(lb)
        f = lb.frame
        f.origin.x += f.size.width + margin
        f.size.width = defSize().width - 3 * margin - f.size.width
        return f
    }
    func loadTextView(y: CGFloat, title: String) -> UITextView {
        // title
        var f = createTitleLabelForCell(y: y, title: title)
        f.size.height = 80
        let tv = UITextView.init(frame: f)
        tv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        tv.layer.cornerRadius = 4
        tv.layer.borderColor = ax_red.cgColor
        tv.textColor = .darkText
        tv.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        tv.delegate = self
        return tv
    }
    func loadSegment(items: [String], tag: Int) -> UISegmentedControl{
        let seg = UISegmentedControl.init(items: items)
        seg.tag = tag
        seg.frame = CGRect.init(x: margin, y: margin, width: 0.5*defSize().width, height: cellH)
        seg.addTarget(self, action: #selector(self.segmentChanged(_:)), for: .valueChanged)
        return seg
    }
    func loadSegment(y: CGFloat, title: String, items: [String], tag: Int) -> UISegmentedControl{
        // title
        var f = CGRect.init(x: margin, y: y, width: leftViewW, height: cellH)
        let lb = loadLabel(text: title)
        lb.frame = f
        self.rootViewController?.view.addSubview(lb)
        f = lb.frame
        
        f.origin.x += f.size.width + margin
        f.size.width = defSize().width - 3 * margin - f.size.width
        
        let seg = loadSegment(items: items, tag: tag)
        seg.frame = f
        self.rootViewController?.view.addSubview(seg)
        return seg
    }
    
    func loadButton(title: String?) -> UIButton {
        let btn = UIButton.init(frame: .init(x: 0, y: 0, width: defSize().width, height: cellH))
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 4
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        btn.addTarget(self, action: #selector(self.tapBtn(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(self.btnUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        btn.addTarget(self, action: #selector(self.btnDown(_:)), for: .touchDown)
        btnUp(btn)
        return btn
    }
    
    // MARK: - actions
    func loadTableView() -> TableView {
        let table = TableView.init(frame: .init(x: margin+leftViewW+margin, y: 0, width: defSize().width - 3*margin-leftViewW, height: 180), style: .grouped)
        table.layer.borderWidth = 2
        table.layer.borderColor = ax_red.cgColor
        table.layer.cornerRadius = 4
        table.myDelegate = self
        return table
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        UserDefaults.standard.set(value, forKey: Tag.duration.cacheKey)
        if value > 0 {
            lb_duration.text = "\(value)s"
        } else {
            lb_duration.text = "∞"
        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if let tag = Tag.init(rawValue: sender.tag) {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: tag.cacheKey)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: tag.cacheKey), object: sender.selectedSegmentIndex)
        }
    }
    
    @objc func tfInputBegin(_ sender: UITextField) {
        windowExpand(y: sender.frame.origin.y)
        sender.layer.borderWidth = 2
        // tableview
        var f = table.frame
        f.origin.y = sender.frame.maxY + margin
        if f.size.height < 240 {
            f.size.height = 240
        }
        table.frame = f
        table.isHidden = false
        table.loadData(.title)
        updateTableHeight()
    }
    
    @objc func tfInputEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
        windowResume()
        sender.layer.borderWidth = 0
        UserDefaults.standard.set(sender.text, forKey: Tag.title.cacheKey)
        // tableview
        table.isHidden = true
    }
    
    @objc func tapBtn(_ sender: UIButton) {
        if let t = sender.titleLabel?.text {
            if t == "post" || t == "progress" {
//                let n = Notice(scheme: .plain, title: tf_title.text, message: tv_body.text)
//                if let iconName = seg_icon.titleForSegment(at: seg_icon.selectedSegmentIndex) {
//                    if let i = UIImage.init(named: iconName) {
////                        n.icon = i
//                    }
//                }
//
                
                var n: Notice
                switch seg_scheme.selectedSegmentIndex {
                case 1:
                    n = Notice(scene: .loading, title: tf_title.text, message: tv_body.text)
                case 2:
                    n = Notice(scene: .success, title: tf_title.text, message: tv_body.text)
                case 3:
                    n = Notice(scene: .warning, title: tf_title.text, message: tv_body.text)
                case 4:
                    n = Notice(scene: .error, title: tf_title.text, message: tv_body.text)
                default:
                    n = Notice(scene: .default, title: tf_title.text, message: tv_body.text)
                } 
                n.duration(TimeInterval(s_duration.value))
                n.didTapped { [weak n] in
                    debugPrint("点击了")
                    n?.alert()
                }.didDisappear {
                    debugPrint("消失了")
                }
                if seg_layout.selectedSegmentIndex == 1 {
                    NoticeBoard.shared.layout = .stack
                } else {
                    NoticeBoard.shared.layout = .tile
                }
                NoticeBoard.shared.post(n)
                
                
            } else if t == "clean" {
                NoticeBoard.shared.remove(.all)
            }
            
        }
    }
    @objc func selectBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @objc func btnDown(_ sender: UIButton) {
        sender.backgroundColor = axBlueColor(alpha: 0.5)
    }
    @objc func btnUp(_ sender: UIButton) {
        sender.backgroundColor = axBlueColor(alpha: 1)
    }
    
    @objc func pan(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.translation(in: sender.view)
        var f = self.frame
        f.origin.y += point.y
        self.frame = f
        sender.setTranslation(.zero, in: sender.view)
        if sender.state == .began {
            self.endEditing(true)
        }
        if sender.state == .recognized {
            let velocity = sender.velocity(in: sender.view)
            var endF = f
            if abs(velocity.y) > 50 {
                endF.origin.y += 0.3 * velocity.y
            }

            var duration = 1.5
            if abs(velocity.y) > 4000 {
                duration = 0.3
            } else if abs(velocity.y) > 2000 {
                duration = 0.5
            } else if abs(velocity.y) > 1000 {
                duration = 1
            }
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
                var endY = endF.origin.y
                if endY + f.size.height + bottomSafeMargin() < UIScreen.main.bounds.height {
                    endY = UIScreen.main.bounds.height - f.size.height - bottomSafeMargin()
                }
                if endY > collapsePoint().y {
                    endY = collapsePoint().y
                } else {

                }
                endF.origin.y = endY
                self.frame = endF
            }) { (completed) in

            }

        }

    }
    
    
    @objc func keyboardWillShow(note: Notification){
        //获取键盘的高度
        if let userinfo = note.userInfo {
            let value = userinfo[UIResponder.keyboardFrameEndUserInfoKey]
            if let keyboardRect = value as? CGRect {
                keyboardHeight = keyboardRect.height
                updateTableHeight()
            }
        }
    }
    
}

