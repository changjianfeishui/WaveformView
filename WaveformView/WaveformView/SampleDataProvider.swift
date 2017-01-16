//
//  SampleDataProvider.swift
//  WaveformView
//
//  Created by XB on 16/8/10.
//  Copyright © 2016年 XB. All rights reserved.


//  使用AVAssetReader从AVAsset中读取音频样本并返回一个NSData对象
//  将从一个给定的视频资源中提取全部的样本集合

import AVFoundation

typealias SampleDataProviderCompletionBlock = (Data)->Void

class SampleDataProvider {
    static func loadAudioSamplesFormAsset(_ asset:AVAsset, completionBlock:@escaping SampleDataProviderCompletionBlock) {
        //1. 异步载入所需的tracks资源
        let tracks = "tracks"
        asset.loadValuesAsynchronously(forKeys: [tracks]) { 
            let status = asset.statusOfValue(forKey: tracks, error: nil)
            var sampleData:Data?
            //2. 载入成功后从资源音频轨道读取样本数据
            if status == AVKeyValueStatus.loaded{
                sampleData = self.readAudioSamplesFromAVsset(asset)
            }
            //3. 返回主线程
            if sampleData != nil{
                DispatchQueue.main.async(execute: {
                    completionBlock(sampleData!)
                })
            }else{
                print("读取音轨失败")
            }
        }
    }
    
    
    static func readAudioSamplesFromAVsset(_ asset:AVAsset) -> Data? {
        //1. 创建一个AVAssetReader对象读取资源
        guard let assetReader = try? AVAssetReader(asset: asset) else{
            print("Unable to create AVAssetReader")
            return nil
        }
        //2. 获取资源中找到的第一个音频轨道
        guard let track = asset.tracks(withMediaType: AVMediaTypeAudio).first else{
            print("No audio track found in asset")
            return nil
        }
        //3. 从资源轨道读取音频样本时使用的解压设置
        //样本需要以未被压缩的格式读取(kAudioFormatLinearPCM)
        //样本以16位的little-endian字节顺序的有符号整型方式读取
        let outputSetting:[String:AnyObject] = [AVFormatIDKey:Int(kAudioFormatLinearPCM) as AnyObject,
                             AVLinearPCMIsBigEndianKey:false as AnyObject,
                             AVLinearPCMIsFloatKey:false as AnyObject,
                             AVLinearPCMBitDepthKey:16 as AnyObject
                             ]
        //4. 创建AVAssetReaderTrackOutput对象作为assetReader的输出
        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSetting)
        assetReader.add(trackOutput)
        //5. 允许预收取样本数据
        assetReader.startReading()
        
        let sampleData = NSMutableData()

        while assetReader.status == .reading {
            //6. 迭代返回包含一个音频样本的CMSampleBuffer
            if let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                //7. CMSampleBuffer的音频样本被包含在一个CMBlockBuffer类型中
                if let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                    //8. 获取blockBuffer数据长度
                    let length = CMBlockBufferGetDataLength(blockBuffer)
                    //9. 拼接sampleData
                    let sampleBytes = UnsafeMutablePointer<Int16>.allocate(capacity: length)
                    CMBlockBufferCopyDataBytes(blockBuffer, 0, length, sampleBytes)
                    sampleData.append(sampleBytes, length: length)
                }
            }
        }
        //10. 读取成功,返回数据
        if assetReader.status == .completed {
            return sampleData as Data
        }
        return nil
    }
    
}
