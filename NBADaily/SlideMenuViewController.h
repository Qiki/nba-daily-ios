//
//  SlideMenuViewController.h
//  NBADaily
//
//  Created by kiki on 3/4/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideMenuViewControllerDelegate

@optional
- (void)resetCenterViewControllerWithType:(NSString *)type;

@end

@interface SlideMenuViewController : UITableViewController

@property (nonatomic, assign) id<SlideMenuViewControllerDelegate> delegate;

@end
