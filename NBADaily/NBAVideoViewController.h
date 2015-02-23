//
//  NBAVideoViewController.h
//  NBADaily
//
//  Created by kiki on 2/22/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NBAVideoViewController : UITableViewController <UIWebViewDelegate>

@property (nonatomic, copy) NSDictionary *json;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, weak) IBOutlet UIWebView *videoPlayer;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end
