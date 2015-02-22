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

@end
