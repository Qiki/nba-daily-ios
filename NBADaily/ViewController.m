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
#import "SlideMenuViewController.h"

@interface ViewController () <SlideMenuViewControllerDelegate>

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *sectionTitleArray;
@property (nonatomic, strong) NSMutableArray *sectionContentArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationItem.title = @"NBA Highlights";

    [self sendRequest:@""];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"did become active notification");
    
    [self sendRequest:@""];
    
    [self.tableView reloadData];
}

- (void)reloadDataWithType:(NSString *)type {
    [self sendRequest:type];
}

#pragma mark - UITableView Delegate and Datasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *contentArray = self.sectionContentArray[section];
    
    return contentArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString static *bannerIdentifier = @"BannerCell";
    
    BannerCell *cell = (BannerCell *)[tableView dequeueReusableCellWithIdentifier:bannerIdentifier];
    
    //[cell updateWithInfo:self.dataArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (336 * self.view.frame.size.width) / 600;;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitleArray[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"PUSH_VIDEO" sender:@{@"url" : self.dataArray[indexPath.row][@"url"]}];
}

#pragma mark - Send request to get data

- (void)sendRequest:(NSString *)request {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    NSString *url = @"";
    
    self.sectionTitleArray = [[NSMutableArray alloc] init];
    self.sectionContentArray = [[NSMutableArray alloc] init];
    
    if ([request isEqualToString:@""]) {
        url = @"http://nba-daily.herokuapp.com";
    } else {
        url = [NSString stringWithFormat:@"http://nba-daily.herokuapp.com%@", request];
    }
   
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        if (responseDictionary != nil) {
            for (id key in responseDictionary) {
                [self.sectionTitleArray addObject:key];
                [self.sectionContentArray addObject:responseDictionary[key]];
            }
        }
        
        [self.tableView reloadData];
        
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (IBAction)indexChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self sendRequest:@""];
    } else if (sender.selectedSegmentIndex == 1) {
        [self sendRequest:@"/top-10"];
    }
}

#pragma mark - Perform segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
    if ([[segue identifier] isEqualToString:@"PUSH_VIDEO"]) {
         NBAVideoViewController *videoViewController = (NBAVideoViewController *)[segue destinationViewController];
        videoViewController.url = sender[@"url"];
    }
}

@end
