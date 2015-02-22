//
//  NBAVideoViewController.m
//  NBADaily
//
//  Created by kiki on 2/22/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import "NBAVideoViewController.h"

@interface NBAVideoViewController ()

@end

@implementation NBAVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateData:self.json];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}




#pragma mark - Update data

- (void)updateData:(NSDictionary *)json {
    self.titleLabel.text =  json[@"title"] ? : @"";
    self.descriptionLabel.text = json[@"description"] ? : @"";
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><video width=\"%ld\" height=\"%ld\" controls poster=%@ src=%@></video></body></html>", (long)self.view.frame.size.width, (long)self.videoPlayer.frame.size.height, json[@"thumbnailUrl"], json[@"video"]];

    [self.videoPlayer loadHTMLString:htmlString baseURL:nil];
}

@end
