//
//  XXBaseUIViewController.m
//  MyProjectModule
//
//  Created by zhangxinxin on 2020/8/25.
//  Copyright © 2020 xinxin. All rights reserved.
//

#import "XXBaseUIViewController.h"

@interface XXBaseUIViewController ()

@end

@implementation XXBaseUIViewController
// TODO: 标示处有功能代码待编写
// FIXME: 标示处代码需要修正
// !!!: 标示处代码需要注意
// ???: 标示处代码有疑问

// MARK: - LifeCycle
-(void)dealloc {
    NSLog(@"%@销毁啦。。。。。。",NSStringFromClass(self.class));
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self configVC];
    [self configSubview];
}

// MARK: - View config
-(void)configVC {
    
}

-(void)configSubview {
    
}
// MARK: - Make Data

// MARK: - Private Method

// MARK: - Target Methods

// MARK: - Delegate

// MARK: - Getter / Setter

@end
