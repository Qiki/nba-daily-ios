//
//  ViewController.m
//  NBADaily
//
//  Created by kiki on 2/18/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

#import "ViewController.h"

#import "BannerCell.h"

@interface ViewController ()

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self reloadNBAData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate and Datasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString static *bannerIdentifier = @"BannerCell";
    
    BannerCell *cell = (BannerCell *)[tableView dequeueReusableCellWithIdentifier:bannerIdentifier];
    
    [cell updateWithInfo:self.dataArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 168.0f;
}

- (void)reloadNBAData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    [manager GET:@"http://localhost:3000" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dataArray = (NSArray *)responseObject;
        NSLog(@"JSON: %@", responseObject);
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
