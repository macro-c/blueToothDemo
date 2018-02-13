//
//  deviceCell.m
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deviceCell.h"
#import "ViewController1.h"
#import "Masonry.h"

@interface deviceCell()

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *RSSI;

@end


@implementation deviceCell

- (instancetype) initWithStyle:(UITableViewStyle *)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.name = [[UILabel alloc]init];
    self.RSSI = [[UILabel alloc]init];
    
//    self.name.text = @"!!!!!!!!!!!!!!";
//    self.RSSI.text = @"@@@@@@@@@@@@@@@";
    self.RSSI.textAlignment = UITextAlignmentRight;
    
    [self addSubview:self.name];
    [self addSubview:self.RSSI];
    
    [self UIAddConstraint];
    
    return self;
}

- (void) UIAddConstraint {
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).priorityMedium();
        make.bottom.equalTo(self.name).priorityMedium();
        make.left.right.equalTo(self).priorityMedium();
        make.height.equalTo(self.RSSI).priorityMedium();
    }];
    
    [self.RSSI mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.name).priorityMedium();
        make.top.equalTo(self.RSSI).priorityMedium();
        make.bottom.equalTo(self).priorityMedium();
    }];
}

- (void) updateCellWithInfo :(NSDictionary *)info {
    
    CBPeripheral *peripheral = [info objectForKey:@"peripheral"];
    NSString *name = peripheral.name;
    NSNumber *rssiNum = [info objectForKey:@"RSSI"];
    NSString *RSSI = [rssiNum stringValue];
    NSInteger rssi = abs([rssiNum intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    CGFloat distance = pow(10, ci);
    
    self.name.text = name;
    self.RSSI.text = [NSString stringWithFormat:@"强度：%@,距离约：%0.1f米",RSSI,distance];
}

@end


