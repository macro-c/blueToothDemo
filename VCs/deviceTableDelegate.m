////
////  deviceTableDelegate.m
////  blueToothDemo
////
////  Created by ChenHong on 2018/1/23.
////  Copyright © 2018年 macro-c. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "deviceTableDelegate.h"
//#import "ViewController1.h"
//#import "deviceCell.h"
//
//@interface deviceTableDelegate()
//
//@end
//
//
//@implementation deviceTableDelegate
//
//- (instancetype)initWithDataSource :(UIViewControllerTest1 *)dataSource {
//
//    self = [super init];
//    self.dataSource = dataSource;
//    return self;
//}
//
//
//#pragma mark makeCells
//
//- (UITableViewCell *)makeCellsWithInfo :(NSDictionary *)info {
//
//    deviceCell *cell = [[deviceCell alloc] initWithStyle:UITableViewStylePlain
//                                         reuseIdentifier:BLUE_TOOTH_TABLE_ID
//                                                withInfo:info];
//
//
//
//    return cell;
//}
//
//#pragma mark tableview datasource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//    return self.dataSource.deviceArray.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    return 50.0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BLUE_TOOTH_TABLE_ID forIndexPath:indexPath];
//    NSInteger *index = indexPath.row;
//
//}
//
//
//#pragma mark tableView delegate
//
//
//
//@end
//
