//
//  deviceCell.h
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface deviceCell : UITableViewCell


- (instancetype) initWithStyle:(UITableViewStyle *)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void) updateCellWithInfo :(NSDictionary *)info;

@end
