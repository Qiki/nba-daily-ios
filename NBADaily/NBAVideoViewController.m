//
//  NBAVideoViewController.m
//  NBADaily
//
//  Created by kiki on 2/22/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import "NBAVideoViewController.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface NBAVideoViewController ()

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation NBAVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.userInteractionEnabled = YES;
    [self.view addSubview:self.loadingView];
    
    [self loadRequest];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 200.0f;
    }
    
    return 96.0f;
}




#pragma mark - Update data

- (void)updateData:(NSDictionary *)json {
    self.navigationItem.title = json[@"title"] ? : @"";
    self.descriptionLabel.text = json[@"description"] ? : @"";
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><center><video width=\"%ld\" height=\"%ld\" controls poster=%@ src=%@></video></center></body></html>", (long)self.view.frame.size.width - 15, (long)self.videoPlayer.frame.size.height, json[@"thumbnailUrl"], json[@"video"]];
    
    self.videoPlayer.scrollView.scrollEnabled = NO;
    [self.videoPlayer loadHTMLString:htmlString baseURL:nil];
}

- (void)loadRequest {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];

    NSString *url = [NSString stringWithFormat:@"http://nba-daily.herokuapp.com%@", self.url];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self updateData:(NSDictionary *)responseObject];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.loadingView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.loadingView removeFromSuperview];
        }];
        
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
