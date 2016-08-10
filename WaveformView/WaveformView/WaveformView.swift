//
//  SampleDataProvider.swift
//  WaveformView
//
//  Created by XB on 16/8/10.
//  Copyright © 2016年 XB. All rights reserved.
//

import UIKit
import AVFoundation

class WaveformView: UIView {

    let widthScaling: CGFloat = 0.95
    let heightScaling: CGFloat = 0.85
    
    var filter: SampleDataFilter?
    var loadingView: UIActivityIndicatorView!
    
    var asset: AVAsset? {
        didSet {
            guard let asset = asset else { return }
            //从资源中获取到样本数据后进行绘制
            SampleDataProvider.loadAudioSamplesFormAsset(asset){sampleData in
                self.filter = SampleDataFilter(sampleData: sampleData)
                self.loadingView.stopAnimating()
                self.setNeedsDisplay()
            }
        }
    }

    var waveColor = UIColor.whiteColor() {
        didSet {
            layer.borderWidth = 2.0
            layer.borderColor = waveColor.CGColor
            setNeedsDisplay()
        }
    }



    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = 2.0
        layer.masksToBounds = true

        loadingView = UIActivityIndicatorView(activityIndicatorStyle:.WhiteLarge)
        addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    override func drawRect(rect: CGRect) {

        //1. 获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else { return }
        //2. 获取需要进行绘制的数据
        guard let filteredSamples = filter?.filteredSamplesForSize(bounds.size) else {
            return
        }
        //3. 设置画布的缩放和上下左右间距
        CGContextScaleCTM(context, widthScaling, heightScaling);
        let xOffset = bounds.size.width - (bounds.size.width * widthScaling)
        let yOffset = bounds.size.height - (bounds.size.height * heightScaling)
        CGContextTranslateCTM(context, xOffset / 2, yOffset / 2);
        
        //4. 绘制上半部分
        let midY = CGRectGetMidY(rect)
        let halfPath = CGPathCreateMutable()
        CGPathMoveToPoint(halfPath, nil, 0.0, midY);
        for i in 0..<filteredSamples.count {
            let sample = CGFloat(filteredSamples[i])
            CGPathAddLineToPoint(halfPath, nil, CGFloat(i), midY - sample);
        }
        CGPathAddLineToPoint(halfPath, nil, CGFloat(filteredSamples.count), midY);

        //5. 绘制下半部分,对上半部分进行translate和sacle变化,即翻转上半部分
        let fullPath = CGPathCreateMutable()
        CGPathAddPath(fullPath, nil, halfPath);
        var transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        CGPathAddPath(fullPath, &transform, halfPath);
        
        //6. 将完整路径添加到上下文
        CGContextAddPath(context, fullPath);                                    
        CGContextSetFillColorWithColor(context, self.waveColor.CGColor);
        CGContextDrawPath(context, .Fill);

    }

    override func layoutSubviews() {
        let size = loadingView.frame.size
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        loadingView.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

