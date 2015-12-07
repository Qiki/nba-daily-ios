//
//  StandingsViewController.m
//  NBADaily
//
//  Created by Qi.Wang on 12/6/15.
//  Copyright © 2015 kiki. All rights reserved.
//

#import "StandingsViewController.h"

#import "StandingsCell.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface StandingsViewController ()

@property (nonatomic, copy) NSDictionary *responseData;
@property (nonatomic, copy) NSArray *easternArray;
@property (nonatomic, copy) NSArray *westernArray;

@end

@implementation StandingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.title = @"Standings";
    
    [self sendRequest:@"http://nba-daily.herokuapp.com/standings"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.alpha = 0.0f;
}

- (void)sendRequest:(NSString *)request {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    [manager GET:request parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if (response[@"eastern"] != nil) {
            self.easternArray = response[@"eastern"];
        }
        
        if (response[@"western"] != nil) {
            self.westernArray = response[@"western"];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1.0f;
            [self.tableView reloadData];
        }];

        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SectionTypeWestern) {
        return self.westernArray.count;
    } else if (section == SectionTypeEastern) {
        return self.easternArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StandingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StandingsCell" forIndexPath:indexPath];
    
    NSString *teamName;
    NSString *teamStandings;
    NSDictionary *data;
    
    if (indexPath.section == SectionTypeWestern) {
        data = self.westernArray[indexPath.row];
    } else if (indexPath.section == SectionTypeEastern) {
        data = self.easternArray[indexPath.row];
    }
    
    teamName = [NSString stringWithFormat:@"%ld.  %@", (long)indexPath.row + 1, data[@"team"]];
    teamStandings = [NSString stringWithFormat:@"%@   %@", data[@"win"], data[@"lose"]];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:teamStandings];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:0.0 / 255.0 green:102.0 / 255 blue:0.0 / 255 alpha:1.0]
                 range:NSMakeRange(0, [data[@"win"] length])];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:95.0 / 255.0f green:0.0 / 255 blue:0.0 / 255 alpha:1.0]
                 range:NSMakeRange([teamStandings length] - [data[@"lose"] length], [data[@"lose"] length])];
    
    cell.teamName.text = teamName;
    [cell.teamStandings setAttributedText: text];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SectionTypeEastern) {
        return @"Eastern";
    } else if (section == SectionTypeWestern) {
        return @"Western";
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0f;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
