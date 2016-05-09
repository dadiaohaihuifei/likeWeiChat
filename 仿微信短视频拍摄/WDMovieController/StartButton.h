//
//  startButton.h
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/9.
//  Copyright © 2016年 MrWu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartButton : UIView

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UILabel *label;

/** 开始动画 */
- (void)appearAnimation;
/** 结束动画 */
- (void)disappearAnimation;

@end
