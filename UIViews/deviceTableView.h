//
//  deviceTableView.h
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController1.h"

@interface deviceTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic ,weak) UIViewControllerTest1 *tableDataSource;

- (instancetype) initWithFrame:(CGRect)frame style:(UITableViewStyle)style dataSource:(UIViewControllerTest1 *)dataSource;

@end
