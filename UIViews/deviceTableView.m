//
//  deviceTableView.m
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deviceTableView.h"
#import "deviceCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface deviceTableView()


@end


@implementation deviceTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style dataSource:(UIViewControllerTest1 *)dataSource {
    
    self = [super initWithFrame:frame style:style];
    
    self.tableDataSource = dataSource;
    
    return self;
}


#pragma mark makeCells


#pragma mark tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.tableDataSource.deviceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    deviceCell *cell = [tableView dequeueReusableCellWithIdentifier:BLUE_TOOTH_TABLE_ID forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    [cell updateCellWithInfo:self.tableDataSource.deviceArray[index]];
    
    return cell;
}


#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //避免重复点
//    tableView.userInteractionEnabled = NO;
    NSLog(@" 当前table已经不可点击 ");
    
    NSInteger index = indexPath.row;
    NSDictionary *info = self.tableDataSource.deviceArray[index];
    CBPeripheral *per = [info objectForKey:@"peripheral"];
    [self.tableDataSource.CBCenterManager connectPeripheral:per options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];
    // 设置外设的代理是为了后面查询外设的服务和外设的特性，以及特性中的数据。
}


@end
