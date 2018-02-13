//
//  blueToothViewController.m
//  blueToothDemo
//
//  Created by ChenHong on 2018/1/23.
//  Copyright © 2018年 macro-c. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "blueToothViewController.h"
#import "macros.h"
#import "Masonry.h"
//#import "serviceCell.h"

//#define serviceCellID @"bluetoothServicesID"

@interface blueToothViewController()

@property (nonatomic, strong) CBPeripheral *per;
@property (nonatomic, strong) CBCharacteristic *cha;
@property (nonatomic, strong) CBCentralManager *manager;

@property (nonatomic, strong) UILabel *serviceLabel;
@property (nonatomic, copy) NSArray *servicesArray;

@property (nonatomic ,strong) UILabel *characterLabel;

@property (nonatomic ,strong) UIButton *sendBtn;
@property (nonatomic, strong) UITextView *textToSend;
@property (nonatomic, strong) UILabel *receivedText;

@property (nonatomic, strong) NSTimer *checkRSSI;

@end


@implementation blueToothViewController


- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 退出时  关闭当前连接
    [self.manager cancelPeripheralConnection:self.per];
}

- (instancetype) initWithManager : (CBCentralManager *)manager {
    
    self = [super init];
    self.manager = manager;
    return self;
}

- (void) loadView {
    
    [super loadView];
    self.view.backgroundColor = GRAY_COLOR;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 服务数量
    self.servicesArray = [[NSArray alloc] init];
    [self addObservers];
    
    // 添加timer 检查信号质量
    self.checkRSSI = [NSTimer timerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(checkRSSITimer)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.checkRSSI forMode:NSRunLoopCommonModes];
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    [self createUI];
}

- (void) addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionIsOver)
                                                 name:@"connectionIsOverNotification"
                                               object:nil];
}

- (void) createUI {
    
    //serviceLabel 记录当前通信的服务名称
    self.serviceLabel = [[UILabel alloc] init];
    [self.view addSubview:self.serviceLabel];
    [self.serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view).priorityHigh();
        make.height.equalTo(@50).priorityMedium();
    }];
    self.serviceLabel.numberOfLines = 2;
    [self.serviceLabel setText:@"连接服务ID："];
    
    self.characterLabel = [[UILabel alloc] init];
    [self.view addSubview:self.characterLabel];
    [self.characterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.serviceLabel.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    self.characterLabel.numberOfLines = 2;
    [self.characterLabel setText:@"读写特征ID："];
    
//    self.servicesTable = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStylePlain];
//    self.servicesTable.delegate = self;
//    self.servicesTable.dataSource = self;
//    [self.servicesTable registerClass:[serviceCell class] forCellReuseIdentifier:serviceCellID];
//    [self.view addSubview:self.servicesTable];
//    [self.servicesTable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).priorityHigh();
//        make.left.right.equalTo(self.view).priorityMedium();
//        make.height.equalTo(@150).priorityMedium();
//    }];
//    self.servicesTable.userInteractionEnabled = YES;
    
//    self.navigationController.title = @"当前已经连接设备";
    
    
    self.receivedText = [[UILabel alloc] init];
    self.receivedText.backgroundColor = WHITE_COLOR;
    [self.view addSubview:self.receivedText];
    [self.receivedText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.characterLabel.mas_bottom).priorityHigh();
        make.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    [self.receivedText setText:@"收到消息："];
    self.receivedText.numberOfLines = 2;
    
    self.textToSend = [[UITextView alloc]init];
    [self.view addSubview:self.textToSend];
    [self.textToSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.receivedText.mas_bottom).offset(10);
        make.width.equalTo(self.view).offset(-60);
        make.height.equalTo(@60);
    }];
    
    self.sendBtn = [[UIButton alloc] init];
    [self.view addSubview:self.sendBtn];
    [self.sendBtn setTitle:@" 发送 " forState: UIControlStateNormal];
    [self.sendBtn setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    self.sendBtn.backgroundColor = YELLOW_COLOR;
    self.sendBtn.layer.borderWidth = 0.5;
    self.sendBtn.layer.borderColor = BLACK_COLOR.CGColor;
    self.sendBtn.layer.cornerRadius = 5;
    [self.sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textToSend.mas_right).offset(5);
        make.bottom.equalTo(self.textToSend.mas_bottom).offset(-10);
        make.right.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    
//    UIGestureRecognizer *endEditting = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(endEdittingGes)];
//    [self.view addGestureRecognizer:endEditting];
    
}

//- (void)endEdittingGes {
//
//    [self.view endEditing:YES];
//}

#pragma mark 时钟事件

- (void) checkRSSITimer {
    
    [self.per readRSSI];
    if(!self.view.window) {
        
        // 直至当前view退出时停止
        [self.checkRSSI invalidate];
        self.checkRSSI= nil;
    }
}

#pragma mark 相关按钮点击事件

- (void) sendBtnClick {
    
    // 测试单次发送上限
    // 测试 向外设单次写入数据的上限，外设端得知--当前manager单次通知的最大数据长度是 182bytes
    // 结论：经过对 ip6 和ip6s两种内存，测试，单次成功发送的最大长度都是512bytes
//    static NSInteger times = 0;
//    ++times;
//    NSInteger length = times * 1;
//    char *a = (char*) malloc(510 + length);
//    NSData *infoData = [NSData dataWithBytes:a length:510+length];
//    NSLog(@"当前长度%ld",510+length);
//    [self.per writeValue:infoData forCharacteristic:self.cha type:CBCharacteristicWriteWithResponse];
    
    
    if(self.per == nil || self.cha == nil)
    {
        self.receivedText.text = @"!!当前外设不可用 或者特征值不可用";
        return;
    }
    if(self.cha.properties & CBCharacteristicPropertyWriteWithoutResponse || self.cha.properties & CBCharacteristicPropertyWrite)
    {
        NSLog(@" 可写  可以双向通信 ");
        NSString *send = self.textToSend.text;
        if(send.length == 0)
        {
            self.receivedText.text = @" 不可以发送空！！！ ";
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                self.receivedText.text = @"";
            });
            return;
        }

        NSData *infoData = [send dataUsingEncoding:NSUTF8StringEncoding];
        
        // 第三参数表示如果写入成功,或失败  会收到通知--代理--didWriteValueForCharacteristic
        // 一定是 withresponse 做参数，否则发送状态未知
        [self.per writeValue:infoData forCharacteristic:self.cha type:CBCharacteristicWriteWithResponse];
//        [self.per writeValue:infoData forCharacteristic:self.cha type:CBCharacteristicWriteWithoutResponse];
    }
}

#pragma mark notification callback

- (void) connectionIsOver {
    
    [self.textToSend setText:@"当前连接已关闭"];
    self.textToSend.font = [UIFont systemFontOfSize:25];
//    self.view.alpha = 0.5;
    
    [self.textToSend setBackgroundColor:RED_COLOR];
    [self.view endEditing:YES];
    self.view.userInteractionEnabled = NO;
}

#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark tableView datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.servicesArray.count;
}

// 当前完成打印出 设备支持的service UUID--单向
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

//    serviceCell *cell = [tableView dequeueReusableCellWithIdentifier:serviceCellID forIndexPath:indexPath];
//
//    NSInteger index = indexPath.row;
//    // draw cells
//    NSString *UUID = [((CBService *)self.servicesArray[index]).UUID UUIDString];
//    [cell updateCell:UUID];
//    return cell;
//}

#pragma mark CBPeripheralDelegate

// 查找peripheral 设备支持的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    
    if (error) {
        NSLog(@"出错");
        return;
    }
    NSString *UUID = [peripheral.identifier UUIDString];
    NSLog(@"外设的UUID--:%@",UUID);
    
    CBUUID *cbUUID = [CBUUID UUIDWithString:UUID];
    NSLog(@"外设的CBUUID--:%@",cbUUID);
    
    self.servicesArray = peripheral.services;
//    [self.servicesTable reloadData];
    
    for (CBService *service in peripheral.services) {
        NSLog(@"service:%@",service.UUID);
        
        //如果我们知道要查询的特性的CBUUID，可以在参数一中传入CBUUID数组。
        NSString *str = [NSString stringWithFormat:@"UUID:%@",service.UUID];
        NSLog(@"%@",str);
        if([service.UUID isEqual:[CBUUID UUIDWithString: @"68753A44-4D6F-1226-9C60-0050E4C00067"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
            NSString *serviceText = [NSString stringWithFormat:@"连接服务ID：%@",service.UUID];
            [self.serviceLabel setText: serviceText];
            self.per =peripheral;
            
        }
    }
    
}

/**
函数中参数--服务 和上面代理方法中的服务有区别吗？？？
***/

//函数作用是发现并返回  外设中的某个服务的所有特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    
    if(error)
    {
        NSLog(@" 出错了 ");
        return;
    }
    for (CBCharacteristic *character in service.characteristics) {
        
        //筛选特征值  将某个特征值  加入监听  特征值改定会回调
        if([character.UUID isEqual:[CBUUID UUIDWithString: @"68753A44-4D6F-1226-9C60-0050E4C00068"]])
        {
            // 需要监听的特征值  一定要手动添加监听  之后收到特征值的改变，才会走相应代理方法
            // 相应的  外设会调用 - (void)peripheralManager: central: didSubscribeToCharacteristic: 方法记录此时的central
            [peripheral setNotifyValue:YES forCharacteristic:character];
            
            
            NSString *chaLabelText = [NSString stringWithFormat:@"读写特征ID：%@",character.UUID];
            [self.characterLabel setText:chaLabelText];
            self.cha = character;
            
            return;
        }
        
        CBCharacteristicProperties property = character.properties;
        if(property & CBCharacteristicPropertyBroadcast)
        {
            // 理解广播特征
            NSLog(@" 特征是广播特征，特征内容是： %@ ",character);
        }
        if(property & CBCharacteristicPropertyRead) {
            
            // 特征可读 表示外设一开始就有数据
            NSLog(@" 表示当前外设可能发送了数据，特征内容是： %@ ",character);
            
            // 读取当前服务的特征内数据
            [peripheral readValueForCharacteristic:character];
        }
        if(property & CBCharacteristicPropertyWriteWithoutResponse) {
            
            // 表示当前服务的特征允许写入数据
        }
        if(property & CBCharacteristicPropertyWrite) {
            
            // 表示当前特征可写，且写入之后，需要对方回复--当前外设的属性是可读且需要回复，则写入数据之后，超时10秒等待外设做出回应
            // 否则didWriteValueForCharacteristic，状态为未知错误
        }
        else
        {
            self.textToSend.userInteractionEnabled = NO;
            [self.textToSend setText:@" 当前连接的设备，不可写 "];
        }
        if(property & CBCharacteristicPropertyNotify) {
            
        }
        if(property & CBCharacteristicPropertyIndicate) {
            
        }
        if(property & CBCharacteristicPropertyAuthenticatedSignedWrites) {
            
        }
        if(property & CBCharacteristicPropertyExtendedProperties) {
            
        }
        if(property & CBCharacteristicPropertyNotifyEncryptionRequired) {
            
        }
        if(property & CBCharacteristicPropertyIndicateEncryptionRequired) {
            
        }
    }
}

// 当前代理  表示手动更改了 某个特征值的通知状态  特么没什么意义  方法setNotifyValue:YES forCharacteristic:character
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString: @"68753A44-4D6F-1226-9C60-0050E4C00068"]]) {
        
    }
}

// 代理方法表示 读取服务中的某个变化的特征数据
// 在1.peripheral readValueForCharacteristic:character 调用之后调用--（首次连接，特征可读时调用）2.监听了相关特征值之后，特征值改变
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    if (error)
    {
        NSLog(@" 错误发生 ");
        return;
    }
    
    NSData *data = characteristic.value;
    if (data.length <= 0) {
        return;
    }
    
    // 测试发送数据长度************************** 结果是182（在发送长度超过182时）
//    NSInteger a = data.length;
    
    // 读取特征中携带的数据
    NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@" 可读特征中携带的数据内容是 :%@",info);
    NSString *textToShow = [NSString stringWithFormat:@"收到消息：%@",info];
    self.receivedText.text = textToShow;
}

// 查看上方法的结果  type设置为CBCharacteristicWriteWithResponse时 , 否则不调用此方法
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    // 如果 writeValue 的type参数是withresponse 但接收方（外设）并没有respondToRequest，超时10秒，出现错误
    if(error)
    {
        // 表示 向外设中某服务 某特性中写数据
        NSLog(@"error is ..%@",error);
        return;
    }
    NSLog(@" 写入成功 ");
}

// 此方法在向外设写入数据出错时，
- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral {
    
    NSLog(@" 现在可以写了 ");
}


// 方法在 readRSSI 方法调用后调用
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
    NSInteger rssi = abs([RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    CGFloat distance = pow(10, ci);
    
    if(distance > 1)
    {
        NSString *dis = [NSString stringWithFormat:@"当前距离：%0.1f",distance];
        NSLog(dis);
    }
    else
    {
        [self.navigationController setTitle:@"当前连接信号稳定"];
    }
}


@end

