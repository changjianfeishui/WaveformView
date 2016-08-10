//
//  SampleDataFilter.swift
//  WaveformView
//
//  Created by XB on 16/8/10.
//  Copyright © 2016年 XB. All rights reserved.
//  SampleDataProvider从一个给定的视频资源中提取全部的样本集合,即使是非常小的音频文件,都可能是数十万个样本,所以需要进行筛选

import Foundation
import CoreGraphics

class SampleDataFilter {
    var data:NSData!
    convenience init(sampleData:NSData){
        self.init()
        self.data = sampleData
    }
    
    func filteredSamplesForSize(size:CGSize) -> [Float] {
        var filteredSamples = [Float]()
        //每个样本为16字节,得到样本数量
        let samplesCount = self.data.length/sizeof(Int16.self)
        //某个宽度范围内显示多少个样本数量
        let binSize = Int(samplesCount / Int(size.width))
        var bytes = [Int16](count:self.data.length,repeatedValue:0)
        self.data.getBytes(&bytes, length: self.data.length * sizeof(Int16.self))
        var maxSample: Int16 = 0
        //遍历所有样本,
        for i in 0.stride(to: samplesCount-1, by: binSize) {
            var sampleBin = [Int16](count:binSize,repeatedValue:0)
            for j in 0..<binSize {
                sampleBin[j] = bytes[i + j].littleEndian
            }
            let value = self.maxValue(in: sampleBin, ofSize: binSize)
            filteredSamples.append(Float(value))
            if value > maxSample {
                maxSample = value
            }
        }
        
        let scaleFactor = (size.height / 2.0) / CGFloat(maxSample)
        for i in 0..<filteredSamples.count {
            filteredSamples[i] = filteredSamples[i] * Float(scaleFactor)
        }
        return filteredSamples
    }
    
    func maxValue(in values: [Int16], ofSize size: Int) -> Int16 {
        var maxValue: Int16 = 0
        for i in 0..<size {
            if abs(values[i]) > maxValue {
                maxValue = abs(values[i])
            }
        }
        return maxValue
    }
}
