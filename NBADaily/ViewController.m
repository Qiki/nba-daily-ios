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
#import "NBAVideoViewController.h"

@interface ViewController ()

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationItem.title = @"NBA Highlights";

    [self sendRequest:nil];
    
    [self.tableView reloadData];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"did become active notification");
    
    [self sendRequest:nil];
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
    return 190.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self sendRequest:self.dataArray[indexPath.row][@"url"]];
}




#pragma mark - Send request to get data

- (void)sendRequest:(NSString *)request {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    NSString *url = @"";
    
    if (request) {
        url = [NSString stringWithFormat:@"http://nba-daily.herokuapp.com%@", request];
    } else {
        url = @"http://nba-daily.herokuapp.com";
    }
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (request) {
            NSDictionary *response = (NSDictionary *)responseObject;
            [self performSegueWithIdentifier:@"PUSH_VIDEO" sender:@{@"json" : response}];
        } else {
            self.dataArray = (NSArray *)responseObject;
            [self.tableView reloadData];
        }

        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}




#pragma mark - Perform segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
    if ([[segue identifier] isEqualToString:@"PUSH_VIDEO"]) {
         NBAVideoViewController *videoViewController = (NBAVideoViewController *)[segue destinationViewController];
        videoViewController.json = sender[@"json"];
    }
}

@end
