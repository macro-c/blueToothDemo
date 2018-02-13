//
//  serviceCell.h
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/26.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface serviceCell : UITableViewCell

- (void)updateCell :(NSString *)service;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier ;

@end
