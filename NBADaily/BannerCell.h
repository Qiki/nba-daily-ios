//
//  BannerCell.h
//  NBADaily
//
//  Created by kiki on 2/19/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *titleLabel;

- (void)updateWithInfo:(NSDictionary *)Info;

@end
