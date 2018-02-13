//
//  blueToothViewController.h
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface blueToothViewController : UIViewController <CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>

- (instancetype) initWithManager : (CBCentralManager *)manager;

@end
