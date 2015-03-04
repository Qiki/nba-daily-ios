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

@interface MainViewController ()

@property (nonatomic, strong) ViewController *centerViewController;
@property (nonatomic, strong) SlideMenuViewController *slideMenuViewController;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    // Do any additional setup after loading the view.
}
- (IBAction)showSlideMenu {
    [self showSlideMenuViewController];
    
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
    [self.centerViewController didMoveToParentViewController:self];
}


- (UIView *)getSlideMenuView {
 
    if (self.slideMenuViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.slideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuViewController"];
        [self addChildViewController:self.slideMenuViewController];
        [self.view addSubview:self.slideMenuViewController.view];
        [self.slideMenuViewController didMoveToParentViewController:self];
        
        self.slideMenuViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
