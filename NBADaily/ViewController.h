//
//  ViewController.h
//  NBADaily
//
//  Created by kiki on 2/18/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MainViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoSegementControl;

@end

