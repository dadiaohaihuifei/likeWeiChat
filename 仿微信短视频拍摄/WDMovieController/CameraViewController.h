//
//  CameraViewController.h
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/9.
//  Copyright © 2016年 MrWu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController
/** 帧数 */
@property (nonatomic, assign) NSInteger frameNumber;
/** 摄像时长 */
@property (nonatomic, assign) NSInteger cameraTime;
@end
