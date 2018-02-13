//
//  ViewController1.m
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Masonry.h"
#import "ViewController1.h"
#import "macros.h"
//#import "deviceTableDelegate.h"
#import "deviceTableView.h"
#import "deviceCell.h"
#import "blueToothViewController.h"
#import "noBlueToothAlert.h"


@interface UIViewControllerTest1()


@property (nonatomic, strong) UIButton *scanPeripherals;
@property (nonatomic, strong) UIButton *autoScanPeripherals;
@property (nonatomic, strong) UILabel *autoScanTimes;
@property (nonatomic, strong) deviceTableView *deviceTable;
@property (nonatomic, assign) BOOL blueToothAvailable;

@property (nonatomic, strong) NSTimer *autoScanTimer;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, assign) BOOL autoScanning;

@end


@implementation UIViewControllerTest1


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    
    [super loadView];
    
    self.navigationController.title = @" 扫描外设页 ";
    
    self.blueToothAvailable = NO;
    self.autoScanning = NO;
    self.times = 0;
    
    self.CBCenterManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    self.deviceArray = [[NSMutableArray alloc] init];
    [self addObservers];
    self.view.backgroundColor = GRAY_COLOR;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.title = @" blueTooth testing ";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self createUI];
}



- (void)createUI {
    
    self.scanPeripherals = [[UIButton alloc] init];
    self.scanPeripherals.backgroundColor = GREEN_COLOR;
    [self.scanPeripherals setTitle:@"扫描设备" forState:UIControlStateNormal];
    self.scanPeripherals.titleLabel.textColor = BLACK_COLOR;
    self.scanPeripherals.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.scanPeripherals addTarget:self
                             action:@selector(scanPeripheralsBtnClick:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanPeripherals];
    
    self.autoScanPeripherals = [[UIButton alloc] init];
    self.autoScanPeripherals.backgroundColor = GREEN_COLOR;
    [self.autoScanPeripherals setTitle:@"自动扫描" forState:UIControlStateNormal];
    self.autoScanPeripherals.titleLabel.textColor = BLACK_COLOR;
    self.autoScanPeripherals.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.autoScanPeripherals addTarget:self
                             action:@selector(autoScanBtnClick:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.autoScanPeripherals];
    
    self.autoScanTimes = [[UILabel alloc] init];
    self.autoScanTimes.text = @"0次";
    self.autoScanTimes.layer.borderWidth = 0.9;
    self.autoScanTimes.layer.borderColor = BLACK_COLOR.CGColor;
    self.autoScanTimes.backgroundColor = GREEN_COLOR;
    [self.view addSubview:self.autoScanTimes];
    
    
    self.deviceTable = [[deviceTableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain dataSource:self];
    [self.view addSubview:self.deviceTable];
    self.deviceTable.backgroundColor = GRAY_COLOR;
    [self.deviceTable reloadData];
    [self.deviceTable registerClass:[deviceCell class] forCellReuseIdentifier:BLUE_TOOTH_TABLE_ID];
    
    self.deviceTable.delegate = self.deviceTable;
    self.deviceTable.dataSource = self.deviceTable;
    
    [self addUIContraints];
}

- (void)addUIContraints {
    
    [self.scanPeripherals mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(10).priorityMedium();
        make.width.equalTo(@100).priorityMedium();
        make.height.equalTo(@20).priorityMedium();
    }];
    
    [self.autoScanPeripherals mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scanPeripherals.mas_right).offset(10).priorityMedium();
        make.height.width.top.equalTo(self.scanPeripherals).priorityMedium();
        
    }];
    
    [self.autoScanTimes mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.autoScanPeripherals.mas_right).offset(10).priorityMedium();
        make.height.top.equalTo(self.autoScanPeripherals).priorityMedium();
        make.width.mas_equalTo(self.autoScanPeripherals.frame.size.width * 0.7).priorityMedium();
    }];
    
    [self.deviceTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanPeripherals.mas_bottom).offset(10).priorityMedium();
        make.left.right.bottom.equalTo(self.view).priorityMedium();
    }];
    
}

- (void)addObservers {
    
    
}

//根据信号强度排序
- (void)sortDeviceArray {
    
    if(self.deviceArray.count < 2)
    {
        return;
    }
    [self.deviceArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *ob1 = (NSDictionary *)obj1;
        NSDictionary *ob2 = (NSDictionary *)obj2;
        
        NSNumber *RSSI1 = [ob1 objectForKey:@"RSSI"];
        NSNumber *RSSI2 = [ob2 objectForKey:@"RSSI"];
        
        if(RSSI1 >= RSSI2){
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
}

#pragma mark buttons'click action

- (void)scanPeripheralsBtnClick :(UIButton *)btn {
    
    if(self.blueToothAvailable)
    {
        //表示在蓝牙可用时，进行外设扫描
        //首参数指定 service标识，用于筛选外设
        //options未清楚
        [self.CBCenterManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
    }
    else
    {
        [noBlueToothAlert shareAlertWithDelegate:self];
        NSLog(@" 当前蓝牙不好使啊 ");
        return;
    }
}


- (void)autoScanBtnClick :(UIButton *)btn {
    
    if(!self.blueToothAvailable)
    {
        self.autoScanning = NO;
        [noBlueToothAlert shareAlertWithDelegate:self];
        return;
    }
    
    if(!self.autoScanning)
    {
        if(!self.blueToothAvailable)
        {
            // 如果蓝牙中途关闭 则会在外层委托方法中
            return;
        }
        self.autoScanning = YES;
        [self.autoScanPeripherals setTitle:@"停止自动" forState: UIControlStateNormal];
        self.autoScanTimer = [NSTimer timerWithTimeInterval:1.5
                                                     target:self
                                                   selector:@selector(timerTick)
                                                   userInfo:nil
                                                    repeats:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSRunLoop currentRunLoop] addTimer:self.autoScanTimer forMode:NSRunLoopCommonModes];
        });
    }
    else
    {
        self.autoScanning = NO;
        [self.autoScanPeripherals setTitle:@"自动扫描" forState: UIControlStateNormal];
        [self.autoScanTimer invalidate];
        self.autoScanTimer = nil;
        self.times = 0;
        NSString *text = [NSString stringWithFormat:@"%ld次",self.times];
        [self.autoScanTimes setText:text];
    }
    
}

//times 属性懒加载
//
//- (NSInteger) times {
//
//    return _times;
//}
//
//- (void) setTimes:(NSInteger)times {
//
//    _times = times;
//    NSString *text = [NSString stringWithFormat:@"%ld次",(long)_times];
//    [self.autoScanTimes setText:text];
//}

//timer 的回调函数
- (void) timerTick {
    
    if( !self.blueToothAvailable)
    {
        self.autoScanning = NO;
        [self.autoScanTimer invalidate];
        self.autoScanTimer = nil;
        self.times = 0;
        NSString *text = [NSString stringWithFormat:@"%ld次",self.times];
        [self.autoScanTimes setText:text];
        
        [noBlueToothAlert shareAlertWithDelegate:self];
        NSLog(@" 当前蓝牙不可用 ");
        return;
    }
    
    if(!self.view.window)
    {
        [self.autoScanTimer invalidate];
        self.autoScanTimer = nil;
    }
    
    //没有  在未连接的情况下  检测外设是否存在的接口  所以定时清空列表
    self.times++;
    if(self.times % 4 == 0)
    {
        self.deviceArray = [[NSMutableArray alloc]init];
        [self.deviceTable reloadData];
    }
    NSString *text = [NSString stringWithFormat:@"%ld次",self.times];
    [self.autoScanTimes setText:text];
    
    // 函数首参数  表示限定提供某个服务CBUUID 的外设
    [self.CBCenterManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
}

#pragma mark CBCentralManagerDelegate

//此代理方法 在蓝牙状态 state 属性变化时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSLog(@" our center is %@",central);
    switch (central.state) {
        case CBManagerStatePoweredOn:
            
            NSLog(@"蓝牙为打开，当前center可用");
            self.blueToothAvailable = YES;
            break;
        case CBManagerStatePoweredOff:
        {
            self.blueToothAvailable = NO;
            NSLog(@"可用，未打开");
            break;
        }
        case CBManagerStateUnsupported:
            NSLog(@"SDK不支持");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"程序未授权");
            break;
            
//            表示链接断开  状态即将更新？？
        case CBManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
            
//            状态未知  状态即将更新
        case CBManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        default:
            break;
    }
}


//扫描到设备时  调用此方法  参数 peripheral 表示某 **一个** 设备的处理
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (peripheral.name.length <= 0) {
        return ;
    }
    
    NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
    if (self.deviceArray.count == 0) {
        
        //RSSI 表示信号响度参数
        [self.deviceArray addObject:dict];
    } else {
        BOOL isExist = NO;
        for (int i = 0; i < self.deviceArray.count; i++) {
            NSDictionary *dict = [self.deviceArray objectAtIndex:i];
            CBPeripheral *per = dict[@"peripheral"];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                [_deviceArray replaceObjectAtIndex:i withObject:dict];
            }
        }
        if( !isExist ) {
            [self.deviceArray addObject:dict];
        }
    }
    
    [self sortDeviceArray];
    [self.deviceTable reloadData];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@" 连接设备成功 ");
    
    //查找设备支持的服务 在其代理对象中
    [peripheral discoverServices:nil];
    
    blueToothViewController *btDeviceVC = [[blueToothViewController alloc] initWithManager:self.manager];
    NSString *name = peripheral.name;
    btDeviceVC.title = [NSString stringWithFormat:@"当前连接%@",name];
    [peripheral setDelegate:btDeviceVC];
    [self.navigationController pushViewController:btDeviceVC animated:YES];
    
    [peripheral setDelegate:btDeviceVC];
    self.deviceTable.userInteractionEnabled = YES;
    
    NSLog(@" 表示manager连接外设完成，回调peripheral的代理函数 ");
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@" 连接设备失败了，因为内容是 ");
    NSLog(@"%@",error);
    //恢复点击
    self.deviceTable.userInteractionEnabled = YES;
}


// 当前连接的外设不是由--cancelPeripheralConnection--主动断开连接而断开。 具体原因会显示在 error中!!!!!!!!!!!!!!!
// 查看error内容！！
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    // 连接需要配对的设备，取消配对请求之后，---对方主动关闭连接?????如何做到的?????
    if(error)
    {
        NSLog(@"断开连接的原因是%@",error);
    }
    NSLog(@" 当前连接关闭--不管主动非主动都走此方法。。。 ");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionIsOverNotification" object:nil];
}

#pragma mark UIAlertControllerStyleAlertdelegate
// 此部分代理功能不清晰！！！！！！！！！！！！！！！！！！！！！！


- (CBCentralManager *)manager {
    return self.CBCenterManager;
}

- (void)setManager:(CBCentralManager *)manager {
    self.CBCenterManager = manager;
}


@end

