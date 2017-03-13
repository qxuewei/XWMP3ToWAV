//
//  XWMP3ToPCM.m
//  XWMP3ToWAV
//
//  Created by 邱学伟 on 2017/3/13.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "XWMP3ToPCM.h"

#import <AVFoundation/AVFoundation.h>

@implementation XWMP3ToPCM
/// 用mp3文件创建一个AVAsset实例
+ (AVAsset *)readMp3FileWithMp3FilePath:(NSString *)mp3FilePath {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:mp3FilePath]];
    if (!asset) {
        NSLog(@"不存在MP3文件!");
        return NULL;
    }
    return asset;
}

//// 用一个AVAsset实例创建一个AVAssetReader实例
+ (AVAssetReader *)initAssetReader:(AVAsset *)avasset {
    
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:avasset error:&error];
    if (error) {
        NSLog(@"initAssetReader - error:%@",error);
    }
    return assetReader;
}

/// 创建一个AVAssetWriter实例
+ (AVAssetWriter *)initAssetWriterWithPcmFilePath:(NSString *)pcmFilePath {
    
    NSError *error = nil;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:pcmFilePath] fileType:AVFileTypeWAVE error:&error];
    if (error) {
        NSLog(@"initAssetWriterWithPcmFilePath -- error:%@",error);
    }
    return assetWriter;
}

+ (void)mp3ToPcmWithMp3FilePath:(NSString *)mp3FilePath pcmFilePath:(NSString *)pcmFilePath {
    
    NSLog(@"+++ mp3FilePath:\(%@) -> pcmFilePath:\(%@)",mp3FilePath,pcmFilePath);
    
    // 1.创建AVAsset实例
    AVAsset *asset = [self readMp3FileWithMp3FilePath:mp3FilePath];
    // 2.创建AVAssetReader实例
    AVAssetReader *assetReader = [self initAssetReader:asset];
    
   // 3.配置转码参数
    AudioChannelLayout channelLayout;// =  AudioChannelLayout()
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)];

    /*
         AVFormatIDKey :  @"lpcm",    // 音频格式
         AVSampleRateKey : [NSNumber numberWithFloat:44100.0],    // 采样率
         AVNumberOfChannelsKey : @2,    // 通道数 1 || 2
         AVChannelLayoutKey : [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)],  // 声音效果（立体声）
         AVLinearPCMBitDepthKey : @16  // 音频的每个样点的位数
         AVLinearPCMIsNonInterleaved : noNumber,  // 音频采样是否非交错
         AVLinearPCMIsFloatKey : noNumber,    // 采样信号是否浮点数
         AVLinearPCMIsBigEndianKey : noNumber // 音频采用高位优先的记录格式
     */
    NSNumber *noNumber = [NSNumber numberWithBool:NO];
    NSMutableDictionary *outputSettings = [[NSMutableDictionary alloc] init];
    [outputSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [outputSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [outputSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [outputSettings setValue:[NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)] forKey:AVChannelLayoutKey];
    [outputSettings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [outputSettings setValue:noNumber forKey:AVLinearPCMIsNonInterleaved];
    [outputSettings setValue:noNumber forKey:AVLinearPCMIsFloatKey];
    [outputSettings setValue:noNumber forKey:AVLinearPCMIsBigEndianKey];
    
    AVAssetReaderAudioMixOutput *readerAudioMixOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:asset.tracks audioSettings:outputSettings];
    
    // 4.创建AVAssetReaderAudioMixOutput实例并绑定到assetReader上
    if (![assetReader canAddOutput:readerAudioMixOutput]) {
        
        NSLog(@"can't add readerAudioMixOutput");
        return;
    }
    [assetReader addOutput:readerAudioMixOutput];
    
    // MARK: 1.保存到文件
    // 5.创建AVAssetWriter实例
    AVAssetWriter *assetWriter = [self initAssetWriterWithPcmFilePath:pcmFilePath];
    
    // 6.创建AVAssetWriterInput实例并绑定到assetWriter上
    if (![assetWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeAudio]) {
        
        NSLog(@"can't apply outputSettings");
        return;
    }
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    // 是否让媒体数据保持实时。在此不需要开启
    writerInput.expectsMediaDataInRealTime = NO;
    
    
    if (![assetWriter canAddInput:writerInput]) {
        NSLog(@"can't add writerInput");
        return;
    }
    [assetWriter addInput:writerInput];
    
    // 7.启动转码
    [assetReader startReading];
    [assetWriter startWriting];
    
    // 开启session
    AVAssetTrack *track = asset.tracks.firstObject;
    if (!track) { return; }
    
    CMTime startTime = CMTimeMakeWithSeconds(0, track.naturalTimeScale);
    
    [assetWriter startSessionAtSourceTime:startTime];
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) usingBlock:^{
        while ([writerInput isReadyForMoreMediaData]) {
            CMSampleBufferRef nextBuffer = [readerAudioMixOutput copyNextSampleBuffer];
            if (nextBuffer) {
                [writerInput appendSampleBuffer:nextBuffer];
            }else{
                [writerInput markAsFinished];
                [assetReader cancelReading];
                [assetWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"whrite complete");
                }];
                break;
            }
        }
    }];
}


@end
