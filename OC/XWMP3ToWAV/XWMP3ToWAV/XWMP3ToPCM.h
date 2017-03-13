//
//  XWMP3ToPCM.h
//  XWMP3ToWAV
//
//  Created by 邱学伟 on 2017/3/13.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWMP3ToPCM : NSObject

+ (void)mp3ToPcmWithMp3FilePath:(NSString *)mp3FilePath pcmFilePath:(NSString *)pcmFilePath;

@end
