//
//  ViewController.m
//  HomeKitDemo
//
//  Created by Dylan Chen on 2017/8/30.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//

#import "ViewController.h"
#import <HomeKit/HomeKit.h>

@interface ViewController ()<HMAccessoryBrowserDelegate,UITableViewDelegate,UITableViewDataSource,HMHomeManagerDelegate,HMAccessoryDelegate>

@property (strong, nonatomic)HMHomeManager * homeManager;

@property (strong, nonatomic)NSMutableArray * dataArray;

@property (strong, nonatomic)UITableView * tableView;

@property (strong, nonatomic)HMAccessoryBrowser * broswer;

@property (strong, nonatomic)UIView * headerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configSubViews];
    
    [self layoutSubViews];
    
}

- (void)configSubViews{
    
    //配置子视图
    [self.view addSubview:self.tableView];
}

- (void)layoutSubViews{
    
    //布局子视图
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    //停止扫描
    //[self.broswer stopSearchingForNewAccessories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)scanAccess{
    //开始扫描新硬件
    [self.broswer startSearchingForNewAccessories];
    NSLog(@"开始扫描");
}

- (void)stopScanAccess{
    //停止扫描新硬件
    [self.broswer stopSearchingForNewAccessories];
    NSLog(@"结束扫描");
}

- (void)homeAccessAction{
    
//    HMAccessory * acc =
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"abcCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abcCell"];
    }

    
    if (indexPath.section == 0) {
        HMAccessory * accessory = self.dataArray[indexPath.row];
        cell.textLabel.text = accessory.name;
    }
    else
    {
        HMAccessory * accessory = self.homeManager.primaryHome.accessories[indexPath.row];
        cell.textLabel.text = accessory.name;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return self.dataArray.count;
    }else{
        return self.homeManager.primaryHome.accessories.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        HMAccessory * access = self.dataArray[indexPath.row];
        [self.homeManager.primaryHome addAccessory:access completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@",error);
            }
        }];
    }else{
        
        HMAccessory * access = self.homeManager.primaryHome.accessories[indexPath.row];
        access.delegate = self;
        for (HMService * service in access.services) {
            
            //这里要根据不同类型的 特征属性 来设置不同类型的值,下面只是举个栗子
            for(HMCharacteristic * character in service.characteristics)
            {
                //特征属性为
                NSLog(@"属性类型为:%@",character.characteristicType);
                NSLog(@"特征属性有:%@",character.properties);
                [character readValueWithCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
                [character writeValue:@(1) completionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"设置成功");
                    }else{
                        NSLog(@"设置失败");
                    }
                }];
            }
//            NSLog(@"%@",service.characteristics);
        }
    }

    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"未添加的设备";
    }else{
        return @"已添加的设备";
    }
}
#pragma mark - HMHomeManagerDelegate
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager
{
    //更新home
    NSLog(@"更新了home");
}

#pragma mark - HMAccessoryBrowserDelegate
- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory{
    //获取到新硬件
    [self.dataArray addObject:accessory];
    [self.tableView reloadData];
    NSLog(@"发现一个新硬件");

}

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didRemoveNewAccessory:(HMAccessory *)accessory{
    //移除新硬件
    [self.dataArray removeObject:accessory];
    [self.tableView reloadData];
    
    NSLog(@"失去一个新硬件");
}

- (void)accessory:(HMAccessory *)accessory service:(HMService *)service didUpdateValueForCharacteristic:(HMCharacteristic *)characteristic
{
    //更新了属性
    
}
#pragma mark - Lazy

- (HMAccessoryBrowser *)broswer{
    
    if (_broswer == nil) {
        _broswer = [HMAccessoryBrowser new];
        _broswer.delegate = self;
        
        [self.dataArray addObjectsFromArray:_broswer.discoveredAccessories];
        [self.tableView reloadData];
    }
    return _broswer;
}

- (UITableView *)tableView{
    
    if (_tableView == nil) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [UIView new];
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"abcCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)headerView{
    if (_headerView == nil) {
        
        _headerView = [UIView new];
        _headerView.backgroundColor = [UIColor redColor];
        
        UIButton * startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [startBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
        [startBtn addTarget:self action:@selector(scanAccess) forControlEvents:UIControlEventTouchUpInside];
        startBtn.backgroundColor = [UIColor blueColor];
        
        UIButton * stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [stopBtn setTitle:@"停止扫描" forState:UIControlStateNormal];
        [stopBtn addTarget:self action:@selector(stopScanAccess) forControlEvents:UIControlEventTouchUpInside];
        stopBtn.backgroundColor = [UIColor purpleColor];
        
        [_headerView addSubview:startBtn];
        [_headerView addSubview:stopBtn];
        
        _headerView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 150);
        startBtn.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width/2, 50);
        stopBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2, 100, [UIScreen mainScreen].bounds.size.width/2, 50);

    }
    return _headerView;
}

- (HMHomeManager *)homeManager
{
    if (_homeManager == nil) {
        _homeManager =  [HMHomeManager new];
        _homeManager.delegate = self;
    }
    return _homeManager;
}








@end
