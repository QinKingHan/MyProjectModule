//
//  SDBarrageView.swift
//  SDBarrageView
//
//  Created by XinXin on 2020/5/7.
//  Copyright © 2020 xinxin. All rights reserved.
//

// XXTODO 间距问题 富文本图片问题

import Foundation
import UIKit

class SDBarrageView: UIView {
    // 轨道间距
    let lineSpace: CGFloat = 20.0
    // 轨道数
    var numberOfRows: Int = 3
    // 速度
    var speed: CGFloat = 100.0
    
    var timer: Timer?
    
    lazy var pendingList: [SDBarrageInfo] = {
        var list = Array<SDBarrageInfo>()
    
        return list
    }()
    
    lazy var reuseItemViewSet: Set<UIView> = {
        var set = Set<UIView>()
        return set
    }()
    
    // key:className  XXTODO字典作为重用池
    lazy var reuseItemViewPool: [String: UIView] = {
        var reusePool = [String: UIView]()
        return reusePool
    }()
    
    // 最后一条弹幕完全显示在屏幕上的时间记录
    lazy var timeDict: [Int: CGFloat] = {
        var dict = [Int: CGFloat]()
        return dict
    }()
    
    //MARK:init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        commonInit()
    }
    
    func commonInit() {
        startTimer()
    }
    
    
    //MARK: timer
    func startTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(SDBarrageView.handleTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    @objc func handleTimer() {
        guard pendingList.count > 0 else {
            return
        }
        
        if let info = pendingList.first {
            // get栈顶元素
            playDanmu(info: info)
            // 移除栈顶
            pendingList.remove(at: 0)
        }
    }
    
    //MARK:play danmu
    func rowHeight() -> CGFloat {
        return (self.height - lineSpace * CGFloat((numberOfRows - 1))) / CGFloat(numberOfRows)
    }
    
    func rowWithY(y: CGFloat) -> Int {
        return Int(y / (rowHeight() + lineSpace))
    }
    
    func reuseItemView(cls: AnyClass) -> UIView? {
        guard reuseItemViewPool.count > 0 else {
            return nil
        }
        
        let className = NSStringFromClass(cls)
        if let reuseView = reuseItemViewPool[className] {
            reuseItemViewPool.removeValue(forKey: className)
//            print("reuseItemView: \(reuseView)")
//            print("reusePool:\(self.reuseItemViewPool)")
            return reuseView
        }
        
        return nil
    }
    
    // 计算弹轨
    func calculateRow() -> Int {
        for index in 0..<numberOfRows {
            // 判断是否能放在该条轨道，即该轨道的最后一条弹幕已经在屏幕上。
            var shouldShow = true
            if let time = timeDict[index] {
                let currentTime = NSDate()
                if currentTime.timeIntervalSince1970 < TimeInterval(time) {
                    shouldShow = false
                }
            }
            
            if shouldShow {
                return index
            }
        }
        
        return -1;
    }
    
    // 播放弹幕
    func playDanmu(info: SDBarrageInfo) {
        guard info.text.count > 0 else {
            return
        }
        
        // 计算弹轨
        let index = calculateRow()
        guard index >= 0 && index < numberOfRows else {
            pendingList.insert(info, at: 0)
            return
        }
        
        let itemViewClass: AnyClass = info.itemViewClass
        var reuseItemView = self.reuseItemView(cls: itemViewClass)
        if reuseItemView == nil {
            if let cls = itemViewClass as? UIView.Type {
                reuseItemView = cls.init()
            }
        }
        
        guard let itemView = reuseItemView else {
            pendingList.insert(info, at: 0)
            return
        }
        
        // 计算坐标y
        let y =  CGFloat(index) * (lineSpace + rowHeight())
        itemView.x = self.frame.size.width
        itemView.y = y
        
        if let itemView = itemView as? SDBarrageItemView {
            if info.attributedText != nil {
                itemView.updateAttributedText(text: info.attributedText!)
            }else{
                itemView.updateDanmuInfo(info: info)
            }
        }
        
        itemView.sizeToFit()
        
        self.addSubview(itemView)
        
        // 弹幕完全显示在屏幕的时间+间隔
        let time = itemView.width / speed + 0.5 + CGFloat(NSDate().timeIntervalSince1970)
        timeDict[index] = time
        
        // 动画
        let duration = (self.width + itemView.width) / speed
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .curveLinear, animations: {
            itemView.x = itemView.x - itemView.width
        }) { (finished) in
            if (finished) {
                // add to reusePool viewClassName 为key
                self.reuseItemViewPool[NSStringFromClass(itemViewClass)] = itemView
//                print("reusePool:\(self.reuseItemViewPool)")
                // view 离开屏幕后移除，那这个缓存池是其实是没有的呀？？
                itemView.removeFromSuperview()
            }
        }
    }
    
    func pause() {
        stopTimer()
        for itemView in self.subviews {
            if itemView.isKind(of: SDBarrageItemView.self) {
                if let frame = itemView.layer.presentation()?.frame {
                    itemView.frame = frame
                }
                
                itemView.layer.removeAllAnimations()
            }
        }
    }
    
    func resume() {
        startTimer()
        for itemView in self.subviews {
            if itemView.isKind(of: SDBarrageItemView.self) {
                let index = rowWithY(y: itemView.y)                
                // 更新时间，如果右边未完全显示在屏幕
                if (itemView.x + itemView.width > self.width) {
                    let time = (itemView.x + itemView.width - self.width) / speed + 0.5 + CGFloat(NSDate().timeIntervalSince1970)
                    timeDict[index] = time
                }
                
                let duration = (itemView.x + itemView.width) / speed
                
                UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .curveLinear, animations: {
                    itemView.x = -itemView.width
                }) { (finished) in
                    if (finished) {
                        let mirror = Mirror(reflecting: itemView)
                        self.reuseItemViewPool[NSStringFromClass(mirror.subjectType as! AnyClass)] = itemView
                        itemView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func reset() {
        stopTimer()
        reuseItemViewSet.removeAll()
        pendingList.removeAll()
        timeDict.removeAll()
    }
    
    func removeAll() {
        stopTimer()
        reuseItemViewSet.removeAll()
        pendingList.removeAll()
        timeDict.removeAll()
        self.removeAllSubviews()
    }
}
