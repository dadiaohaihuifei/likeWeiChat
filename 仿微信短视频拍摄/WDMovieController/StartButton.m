//
//  startButton.m
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/9.
//  Copyright © 2016年 MrWu. All rights reserved.
//

#import "StartButton.h"

@implementation StartButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = self.bounds;
        //画弧线
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:_circleLayer.position radius:frame.size.width * 0.5 startAngle:-M_PI endAngle:M_PI clockwise:YES];
        _circleLayer.path = circlePath.CGPath;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor greenColor].CGColor;
        _circleLayer.lineWidth = 3;
        [self.layer addSublayer:_circleLayer];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.5, 20)];
        _label.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"按住拍";
        _label.textColor = [UIColor greenColor];
        _label.font = [UIFont systemFontOfSize:20];
        [self addSubview:_label];
    }
    return self;
}

- (void)appearAnimation {
    CABasicAnimation *animation_scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_scale.toValue = @1;
    
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.toValue = @1;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation_scale,animation_opacity];
    group.duration = 0.2;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [_circleLayer addAnimation:group forKey:@"resetCircle"];
    [_label.layer addAnimation:group forKey:@"resetLabel"];
}

- (void)disappearAnimation {
    CABasicAnimation *animation_scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_scale.toValue = @1.5;
    
    CABasicAnimation *animation_opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation_opacity.toValue = @0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation_scale,animation_opacity];
    group.duration = 0.2;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [_circleLayer addAnimation:group forKey:@"startCircle"];
    [_label.layer addAnimation:group forKey:@"startLabel"];

}

@end
