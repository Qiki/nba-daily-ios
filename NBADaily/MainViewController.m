//
//  MainViewController.m
//  NBADaily
//
//  Created by kiki on 3/1/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import "MainViewController.h"

#import "ViewController.h"
#import "SlideMenuViewController.h"

@interface MainViewController () <SlideMenuViewControllerDelegate>

@property (nonatomic, strong) ViewController *centerViewController;
@property (nonatomic, strong) SlideMenuViewController *slideMenuViewController;
@property (nonatomic, assign) BOOL openSlideMenu;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    self.openSlideMenu = YES;
    // Do any additional setup after loading the view.
}

- (IBAction)showSlideMenu {
    if (self.openSlideMenu) {
        [self showSlideMenuViewController];
        self.openSlideMenu = NO;
    } else {
        [self resetCenterView];
        self.openSlideMenu = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"CenterViewController"];
    [self addChildViewController:self.centerViewController];
    [self.view addSubview:self.centerViewController.view];
    self.delegate = self.centerViewController;
    [self.centerViewController didMoveToParentViewController:self];
}


- (UIView *)getSlideMenuView {
    if (self.slideMenuViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.slideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuViewController"];
        [self addChildViewController:self.slideMenuViewController];
        [self.view addSubview:self.slideMenuViewController.view];
        self.slideMenuViewController.delegate = self;
        [self.slideMenuViewController didMoveToParentViewController:self];
        
        self.slideMenuViewController.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    UIView *view = self.slideMenuViewController.view;
    
    return view;
}

- (void)showSlideMenuViewController {
    UIView *childView = [self getSlideMenuView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(self.view.frame.size.width - 60, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
                         
    }];
}

- (void)resetCenterViewControllerWithType:(NSString *)type {
    [self resetCenterView];
    [self.delegate reloadDataWithType:type];
}

- (void)resetCenterView {
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        self.openSlideMenu = YES;
    }];
}

@end
