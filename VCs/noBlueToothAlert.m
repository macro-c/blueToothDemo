//
//  noBlueToothAlert.m
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/24.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "noBlueToothAlert.h"


@interface noBlueToothAlert()

@end



@implementation noBlueToothAlert

+ (instancetype) shareAlertWithDelegate:(id<noBlueToothAlertDelegate> )delegate {
    
    static dispatch_once_t onceToken;
    static noBlueToothAlert *ret;
    dispatch_once(&onceToken, ^{
        UIAlertAction *openBlue = [UIAlertAction actionWithTitle:@"打开蓝牙" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            delegate.manager = [[CBCentralManager alloc] initWithDelegate:(id<CBCentralManagerDelegate>)delegate
                                                                    queue:dispatch_get_main_queue()];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        ret = (noBlueToothAlert *)[UIAlertController alertControllerWithTitle:@" 当前蓝牙不可用 " message:@" 请打开蓝牙 " preferredStyle: UIAlertControllerStyleAlert];
        [ret addAction:openBlue];
        [ret addAction:cancel];
    });
    [(UIViewController *)delegate presentViewController:ret animated:YES completion:nil];
    return ret;
}


@end
