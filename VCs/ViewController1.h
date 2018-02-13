//
//  ViewController1.h
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "noBlueToothAlert.h"

#define BLUE_TOOTH_TABLE_ID @"blueToothDevices"

@interface UIViewControllerTest1 : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, noBlueToothAlertDelegate>

@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) CBCentralManager *CBCenterManager;

@end

