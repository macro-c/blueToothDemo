//
//  serviceCell.m
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/26.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "serviceCell.h"

@interface serviceCell()

@property (nonatomic, strong) UILabel *service;

@end

@implementation serviceCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.service = [[UILabel alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.service];
    return self;
}


- (void)updateCell:(NSString *)service {
    
    [self.service setText:service];
}

@end
