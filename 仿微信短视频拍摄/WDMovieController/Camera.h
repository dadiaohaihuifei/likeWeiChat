//
//  Camera.h
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/8.
//  Copyright © 2016年 MrWu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Camera : NSObject<UIGestureRecognizerDelegate> {
 
    //会话层
    AVCaptureSession *_session;
    //创建输入设备
    AVCaptureDevice *_device;
    //创建输出层layer
    AVCaptureVideoPreviewLayer *_VideoPreviewLayer;
    /** 聚焦view */
    UIView *_focusView;
}

/** 输入设备 */
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
/** 输出设备 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
/** 摄像图 */
@property (nonatomic, strong) UIView *cameraView;
/** 拍摄帧数 */
@property (nonatomic, assign) NSInteger frameNumber;

/** 开始拍摄 */
- (void)startCamera;
/** 停止拍摄 */
- (void)stopCamera;
/** 嵌入预览层 */
- (void)enbedLayerWithView:(UIView *)view;
@end
