//
//  ViewController.m
//  仿微信短视频拍摄
//
//  Created by MrWu on 16/5/8.
//  Copyright © 2016年 MrWu. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *timeText;
@property (weak, nonatomic) IBOutlet UITextField *frameText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)time:(id)sender {
    CameraViewController *vc = [CameraViewController new];
    vc.frameNumber = [self.frameText.text intValue];
    vc.cameraTime = [self.timeText.text intValue];
    [self.view endEditing:YES];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
