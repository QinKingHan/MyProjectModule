//
//  CustomAlertView.m
//  MyProjectModule
//
//  Created by 鑫鑫 on 2018/6/25.
//  Copyright © 2018年 xinxin. All rights reserved.
//

#import "CustomAlertManagerView.h"

@interface CustomAlertManagerView()<CAAnimationDelegate>{
    
}

@property(nonatomic,strong) AbstractAlertView *alertView;
@end

@implementation CustomAlertManagerView

-(void)dealloc{
    NSLog(@"%@======销毁",NSStringFromClass(self.class));
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self initView];
    
    return self;
}

-(void)initView{
    //     TODO 默认
    
}

#pragma mark --PrivateM
-(void)popTabel{
    
    [self hidden];
}

#pragma mark --- PublicMethod
- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self showInView:keyWindow];
}
- (void)showInView:(UIView*)view
{
    self.frame= view.bounds;
    [view addSubview:self];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
}

-(void)showInView:(UIView *)view dely:(NSTimeInterval )time{
    self.frame= view.bounds;
    [view addSubview:self];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    NSTimer *timer = [NSTimer timerWithTimeInterval:(time) target:self selector:@selector(hidden) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)showCustomView:(UIView *)customView InView:(UIView*)view{
    self.frame= view.bounds;
    [self addSubview:customView];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];

    if (self.transferType == DefaultTransfer) {
        
        [customView setFrame:CGRectMake((view.frame.size.width-customView.frame.size.width) / 2 + self.FromPoint.x, (view.frame.size.height-customView.frame.size.height) / 2 + self.FromPoint.y, customView.frame.size.width, customView.frame.size.height)];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        
    }else if (self.transferType == TopTransferDown){
        [customView setFrame:CGRectMake((view.frame.size.width-customView.frame.size.width) / 2, -customView.frame.size.height, customView.frame.size.width, customView.frame.size.height)];
        
        [UIView animateWithDuration:0.4 animations:^{
            [customView setFrame:CGRectMake((view.frame.size.width-customView.frame.size.width) / 2, (view.frame.size.height-customView.frame.size.height) / 2, customView.frame.size.width, customView.frame.size.height)];
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
            
        }];
    }else if (self.transferType == DownTransferTop){
        [customView setFrame:CGRectMake((view.frame.size.width-customView.frame.size.width) / 2, view.frame.size.height + customView.frame.size.height, customView.frame.size.width, customView.frame.size.height)];
        
        [UIView animateWithDuration:0.4 animations:^{
            [customView setFrame:CGRectMake((view.frame.size.width-customView.frame.size.width) / 2, (view.frame.size.height-customView.frame.size.height)-1, customView.frame.size.width, customView.frame.size.height)];
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
            
        }];
        
    }else if (self.transferType == ZoomTransfer){
        
        [customView setFrame:CGRectMake((view.frame.size.width-customView.frame.size.width) / 2, (view.frame.size.height-customView.frame.size.height) / 2, customView.frame.size.width, customView.frame.size.height)];
        
        CABasicAnimation *Animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        Animation.duration= 0.4;
        Animation.fromValue= [NSNumber numberWithFloat:0.0];
        Animation.toValue  = [NSNumber numberWithFloat:1.0];
        Animation.delegate = self;
        [customView.layer addAnimation:Animation forKey:@"scale-layer"];
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
        
    }
    
    [self removeFromSuperview];
    [view addSubview:self];
}


// 自定义View
-(void)showCustomView:(void(^)(AbstractAlertView *customView))config completionBlock:(void (^)(NSInteger index))block{
    
    __block AbstractAlertView *alertView = [[AbstractAlertView alloc] init];
    if (config)
    {
        config(alertView);
    }
    alertView.handleBlock = block;
    [self showCustomView:alertView InView:[UIApplication sharedApplication].keyWindow];
}


-(void)showCustomViews:(AbstractAlertView *)customView InView:(UIView*)view completionBlock:(void (^)(NSInteger index))block{
    
    customView.handleBlock = block;
    [self showCustomView:customView InView:customView];
}


- (void)hidden
{
    
    [self.layer removeAllAnimations];
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeAllAnimations];
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self removeFromSuperview];
}

//点击事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //    背景 alertView button  各自的响应处理
    UITouch *touch = [touches anyObject];
    NSLog(@"touch>>>>>>>%@",NSStringFromClass([touch.view class]));
    if([NSStringFromClass([touch.view class]) isEqualToString:NSStringFromClass([self class])]){
        [self hidden];
        self.customCallBack ? self.customCallBack() : nil;
    }
}



@end
