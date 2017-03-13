//
//  ViewController.m
//  XWMP3ToWAV
//
//  Created by 邱学伟 on 2017/3/13.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "XWMP3ToPCM.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testMP3ToPCM];
}

- (void)testMP3ToPCM {
    
    NSString *mp3FilePath = [[NSBundle mainBundle] pathForResource:@"libai.mp3" ofType:nil];
    NSString *pcmFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    pcmFilePath = [pcmFilePath stringByAppendingPathComponent:@"libai.mp3.wav"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XWMP3ToPCM mp3ToPcmWithMp3FilePath:mp3FilePath pcmFilePath:pcmFilePath];
    });
}


@end
