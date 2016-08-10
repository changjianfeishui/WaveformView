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
    
    //按照指定的尺寸约束来筛选数据
    func filteredSamplesForSize(size:CGSize) -> [Float] {
        /* 最终需要展示的样本集 */
        var filteredSamples = [Float]()
        //1. 每个样本为16字节,得到样本数量
        let samplesCount = self.data.length/sizeof(Int16.self)
        //2. 某个宽度范围内显示多少个样本数量
        let binSize = Int(samplesCount / Int(size.width))
        //3. 得到所有字节数据
        /* 注意创建数组作为buffer时,要先分配好内存,即需要指定数组长度 */
        var bytes = [Int16](count:self.data.length,repeatedValue:0)
        self.data.getBytes(&bytes, length: self.data.length)
        //4. 以binSize为步长遍历所有样本,
        var maxSample: Int16 = 0
        for i in 0.stride(to: samplesCount-1, by: binSize) {
            
            var sampleBin = [Int16](count:binSize,repeatedValue:0)
            for j in 0..<binSize {
                /*小端存储,低字节序*/
                sampleBin[j] = bytes[i + j].littleEndian
            }
            //5. 获取每个尺寸单位样本集binSize中的最大样本
            let value = self.maxValue(in: sampleBin, ofSize: binSize)
            //6. 添加到需要最终需要绘制展示的样本中
            filteredSamples.append(Float(value))
            if value > maxSample {
                maxSample = value
            }
        }
        //7 .根据所有样本中的最大样本值进行缩放
        let scaleFactor = (size.height / 2.0) / CGFloat(maxSample)
        //8. 对需要展示的样本进行缩放
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
