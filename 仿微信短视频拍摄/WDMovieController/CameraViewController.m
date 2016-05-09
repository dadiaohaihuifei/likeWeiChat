//
//  CameraViewController.m
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/9.
//  Copyright © 2016年 MrWu. All rights reserved.
//
#define KSCREENW [UIScreen mainScreen].bounds.size.width
#define KSCREENH [UIScreen mainScreen].bounds.size.height

#import "CameraViewController.h"
#import "Camera.h"
#import "StartButton.h"
#import <QuartzCore/QuartzCore.h>

@interface CameraViewController ()<UIGestureRecognizerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate> {
    Camera *_camera;
    StartButton *_startButton;
    UIView *_cameraView;
    NSMutableArray *_imagesArray;
    UIImageView *_preImageView;
    BOOL _isStart;
    BOOL _isCancel;
    CALayer *_progressViewLayer;
    UILabel *_tip;
    NSTimer *_timer;
    NSInteger _time;
}

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //是否通过图片渲染透明背景
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    _isStart = NO;
    _imagesArray = [NSMutableArray arrayWithCapacity:10];
    
    //相机权限受限提示
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied ||
        status == AVAuthorizationStatusRestricted) {
        NSLog(@"相机权限受限");
    }

    UIBarButtonItem *redoItem = [[UIBarButtonItem alloc] initWithTitle:@"重拍" style:UIBarButtonItemStylePlain target:self action:@selector(resetCamera:)];
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneCamera:)];
    self.navigationItem.rightBarButtonItems = @[finishItem,redoItem];
    
    [self initCameraView];
    [self initPreView];
    [self initStartButton];
    
}

#pragma mark - initalize
- (void)initCameraView {
    _cameraView = [[UIView alloc] initWithFrame:CGRectMake(0,0, KSCREENW, KSCREENH * 0.5)];
    [self.view insertSubview:_cameraView atIndex:0];
    
    _camera = [[Camera alloc] init];
    _camera.frameNumber = self.frameNumber;
    [_camera enbedLayerWithView:_cameraView];
    
    dispatch_queue_t queue = dispatch_queue_create("MYQUEUE", NULL);
    [_camera.videoDataOutput setSampleBufferDelegate:self queue:queue];
    
    NSLog(@"%@",_camera.videoDataOutput);
    [_camera startCamera];
}

- (void)initPreView {
    _preImageView = [[UIImageView alloc] initWithFrame:_cameraView.bounds];
    _preImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_preImageView];
    _preImageView.hidden = YES;
}

- (void)initStartButton {
    _startButton = [[StartButton alloc] initWithFrame:CGRectMake(KSCREENW * 0.25, KSCREENH * 0.5 + KSCREENH / 16, KSCREENW * 0.5, KSCREENH * 0.5)];
    _startButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_startButton];
    //添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [_startButton addGestureRecognizer:pan];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 0.1;
    [_startButton addGestureRecognizer:longPress];
}

- (void)initPrgress {
    _progressViewLayer = [CALayer layer];
    _progressViewLayer.backgroundColor = [UIColor greenColor].CGColor;
    _progressViewLayer.frame = CGRectMake(0, KSCREENH * 0.5, KSCREENW, 5);
    [self.view.layer addSublayer:_progressViewLayer];
    CABasicAnimation *countTime = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    countTime.toValue = @0;
    countTime.duration = _cameraTime;
    countTime.removedOnCompletion = NO;
    countTime.fillMode = kCAFillModeForwards;
    [_progressViewLayer addAnimation:countTime forKey:@"progressAnim"];
}



#pragma mark - Gesture
- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self.view];
    //手势移动到屏幕上方
    if (point.y < KSCREENH * 0.5) {
        _isCancel = YES;
        _progressViewLayer.backgroundColor = [UIColor redColor].CGColor;
        [self.view.layer addSublayer:_progressViewLayer];

        _tip.text = @"松手取消";
        _tip.textColor = [UIColor whiteColor];
        _tip.backgroundColor = [UIColor redColor];
        
     
    }else {
        _isCancel = NO;
        _progressViewLayer.backgroundColor = [UIColor greenColor].CGColor;
        _tip.textColor = [UIColor greenColor];
        _tip.backgroundColor = [UIColor clearColor];
        _tip.text = @"⬆️上移取消";
        [self.view addSubview:_tip];
    
    }
    
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        _isStart = YES;
        _isCancel = NO;
        [_startButton disappearAnimation];
        [self initPrgress];
        _tip = [[UILabel alloc] init];
        _tip.frame = CGRectMake(KSCREENW * 0.5 - 42, KSCREENH * 0.5 - 30, 84, 20);
        _tip.text = @"⬆️上移取消";
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.font = [UIFont systemFontOfSize:14];
        _tip.textColor = [UIColor greenColor];
        [self.view addSubview:_tip];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        _time = 0;
        NSLog(@"start!!");
        //---------------- 【开始】  --------------
    }
    if (longPress.state == UIGestureRecognizerStateCancelled ||
        longPress.state == UIGestureRecognizerStateEnded) {
        if (_isCancel) {
            _isStart = NO;
            //-----------【取消了】------------
            [_timer invalidate];
            [_progressViewLayer removeFromSuperlayer];
             [_tip removeFromSuperview];
            [_startButton appearAnimation];     
            NSLog(@"cancel!!");
            return;
        }else {
            if (_time < 1) {
                [_timer invalidate];
                [_imagesArray removeAllObjects];
                [_progressViewLayer removeFromSuperlayer];
                [_startButton appearAnimation];
                _tip.text = @"手指不要放开";
                _tip.textColor = [UIColor redColor];
                _tip.backgroundColor = [UIColor whiteColor];
                [UIView animateWithDuration:0.2 animations:^{
                    _tip.alpha = 0;
                } completion:^(BOOL finished) {
                    [_tip removeFromSuperview];
                }];
                NSLog(@"cancel!!");
                return;
            }else if(_time < _cameraTime) {
                [self finishCamera];
                
            }
        }
        
    }
}

#pragma mark - Navigationbar
/** 重置 */
- (void)resetCamera:(UIBarButtonItem *)item {
    _cameraView.hidden = NO;
    [_camera startCamera];
    _startButton.hidden = NO;
    [_startButton appearAnimation];
    _preImageView.hidden = YES;
    [_imagesArray removeAllObjects];
}
/** 完成 */
- (void)doneCamera:(UIBarButtonItem *)item {

}

#pragma mark - Timer
- (void)countDown:(NSTimer *)timer {
    _time++;
    if (_time >= _cameraTime) {
        [self finishCamera];
    }
}
//录制完成
- (void)finishCamera {
    [_timer invalidate];
    NSLog(@"%@------",_imagesArray);
    NSLog(@"total=====%ld",(unsigned long)_imagesArray.count);
    [_camera stopCamera];
    _isStart = NO;
    [_progressViewLayer removeFromSuperlayer];
    [_tip removeFromSuperview];
    _startButton.hidden = YES;
    //预览gif动画
    _preImageView.animationImages = _imagesArray;
    _preImageView.animationDuration = _time;
    _preImageView.animationRepeatCount = 0;
    _preImageView.hidden = NO;
    _cameraView.hidden = YES;
    [_preImageView startAnimating];
}
//允许多手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
//码流转图片
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_isStart) {
        UIImage *image = [self imageFromSampleBuffer:&sampleBuffer];
        image = [self normalizedImage:image];
        [_imagesArray addObject:image];
    }
}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    if (_isStart) {
//        UIImage *image = [self imageFromSampleBuffer:&sampleBuffer];
//        image = [self normalizedImage:image];
//        [_imagesArray addObject:image];
//    }
//}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef *)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(*sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image  = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(quartzImage);
    return (image);
}
//保证图片方向
- (UIImage *)normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}
@end
