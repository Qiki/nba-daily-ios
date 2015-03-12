//
//  MainViewController.h
//  NBADaily
//
//  Created by kiki on 3/1/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainViewControllerDelegate

- (void)reloadDataWithType:(NSString *)type;

@end

@interface MainViewController : UIViewController

@property (nonatomic, assign) id<MainViewControllerDelegate> delegate;

@end
