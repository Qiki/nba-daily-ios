//
//  BannerCell.m
//  NBADaily
//
//  Created by kiki on 2/19/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import "BannerCell.h"

#import <UIImageView+WebCache.h>

@implementation BannerCell

- (void)updateWithInfo:(NSDictionary *)Info {
    self.imageURL = Info[@"metadata"][@"media"][@"600x336"][@"uri"] ? : @"";
    self.title.text = Info[@"title"] ? : @"";
}

- (void)setImageURL:(NSString *)imageURL {
    if (![ _imageURL isEqualToString:imageURL]) {
        _imageURL = imageURL;
        
        self.image.alpha = 0.0f;
        [(UIImageView *)self.image sd_setImageWithURL:[NSURL URLWithString:self.imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:0.3 animations:^{
                self.image.alpha = 1.f;
            }];
        }];
    }
}

@end
