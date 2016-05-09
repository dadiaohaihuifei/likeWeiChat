//
//  Camera.m
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/8.
//  Copyright © 2016年 MrWu. All rights reserved.
//

#import "Camera.h"

@implementation Camera

/** 初始化创建实例 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _session = [[AVCaptureSession alloc] init];
        //设置传输质量
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //添加输入设备
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if ([_session canAddInput:deviceInput]) {
            [_session addInput:deviceInput];
        }
        
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        //设置输出像素和格式
        [_videoDataOutput setVideoSettings:[NSDictionary
                                            dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        //视频阻塞是否跳过播放
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        //添加输出设备
        if ([_session canAddOutput:_videoDataOutput]) {
            [_session addOutput:_videoDataOutput];
        }
        
        //配置session
        [_session beginConfiguration];
        
        //配置默认帧数1~10秒
        if ([_device lockForConfiguration:&error]) {
            [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, 10)];
            [_device setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
            [_device unlockForConfiguration];
        }
        [_session commitConfiguration];
        NSLog(@"error---%@",error);
    }
    
    return self;
}

//嵌入预览层
- (void)enbedLayerWithView:(UIView *)view {
    _cameraView = view;
    
    if (_session == nil) return;
    
    _VideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _VideoPreviewLayer.frame = view.bounds;
    //填充状态
    _VideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //摄像头朝向
    _VideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [view.layer addSublayer:_VideoPreviewLayer];
    
    //创建对焦手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    tap.delegate = self;
    [view addGestureRecognizer:tap];
    //创建对焦图框
    _focusView = [[UIView alloc] init];
    _focusView.layer.borderWidth = 2;
    _focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [_VideoPreviewLayer addSublayer:_focusView.layer];
    
    [self focusViewAnimationWithTouchPoint:view.center];
}

/** 轻点手势方法 */
- (void)tapToFocus:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:_cameraView];
    CGPoint focusPoint = CGPointMake(point.x / _cameraView.bounds.size.width, _cameraView.bounds.size.height);
    
    [self focusAtPoint:focusPoint];
    
    [self continueFocusAtPoint:focusPoint];
    [self focusViewAnimationWithTouchPoint:point];
    
}
/** 轻点对焦 */
- (void)focusAtPoint:(CGPoint)point {
    if ([_device isFocusPointOfInterestSupported] && [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error = nil;
        if ([_device lockForConfiguration:&error]) {
            [_device setFocusPointOfInterest:point];
            [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus];
            //闪光灯
//            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto])
//                [_device isFlashModeSupported:AVCaptureFlashModeAuto];
        }
        [_device unlockForConfiguration];
    }
}

/** 连续对焦 */
- (void)continueFocusAtPoint:(CGPoint)point {
    if ([_device isFocusPointOfInterestSupported] && [_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error = nil;
        if ([_device lockForConfiguration:&error]) {
            [_device setFocusPointOfInterest:point];
            [_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
            //闪光灯
//            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto])
//            [_device isFlashModeSupported:AVCaptureFlashModeAuto];
        }
        [_device unlockForConfiguration];
    }
}

/** 配置对焦图框 */
- (void)focusViewAnimationWithTouchPoint:(CGPoint)point {
    _focusView.frame = CGRectMake(0, 0, 80, 80);
    _focusView.center = point;
    _focusView.alpha = 1;
    
    [UIView animateWithDuration:0.5 animations:^{
        _focusView.frame = CGRectMake(0, 0, 60, 60);
        _focusView.center = point;
    } completion:^(BOOL finished) {
        _focusView.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            _focusView.alpha = 1;
        } completion:^(BOOL finished) {
            _focusView.alpha = 0;
        }];
    }];
}

/** 配置自定义拍摄帧数 */
- (void)setFrameNumber:(NSInteger)frameNumber {
    _frameNumber = frameNumber;
    [_session beginConfiguration];
    NSError *error = nil;
    if ([_device lockForConfiguration:&error]) {
        [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, (int)_frameNumber)];
        [_device setActiveVideoMinFrameDuration:CMTimeMake(1, (int)_frameNumber)];
    }
    [_session commitConfiguration];
    
    NSLog(@"frameError --- %@",error);
}
/** 开始摄像 */
- (void)startCamera {
    [_session startRunning];
}
/** 结束摄像 */
- (void)stopCamera {
    [_session stopRunning];
}

@end
