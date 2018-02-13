//
//  noBlueToothAlert.h
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/24.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol noBlueToothAlertDelegate

//@optional  //代理的用处目前只有 1.传递 presentAlertVC 的VC对象；  2.使用代理类中的 CBmanager对象，以达到弹出对话框

// 属性为了获得 manager的读方法
@property (nonatomic, strong) CBCentralManager *manager;

@end


@interface noBlueToothAlert : UIAlertController

@property (nonatomic, weak) id<noBlueToothAlertDelegate> delegate;

+ (instancetype) shareAlertWithDelegate :(id<noBlueToothAlertDelegate>) delegate;

@end

