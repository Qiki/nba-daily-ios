//
//  ViewController.m
//  NBADaily
//
//  Created by kiki on 2/18/15.
//  Copyright (c) 2015 kiki. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

#import "ViewController.h"

#import "BannerCell.h"
#import "NBAVideoViewController.h"
#import "SlideMenuViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MBProgressHUD/MBProgressHUD.h>
 #import <AVFoundation/AVFoundation.h>
#import <GoogleCast/GoogleCast.h>


@interface ViewController () <SlideMenuViewControllerDelegate, GCKDeviceScannerListener,
GCKDeviceManagerDelegate,
GCKMediaControlChannelDelegate,
UIActionSheetDelegate>

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *sectionTitleArray;
@property (nonatomic, strong) NSMutableArray *sectionContentArray;
@property(nonatomic, strong) GCKDeviceManager *deviceManager;
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *googleCastButton;
@property(nonatomic, strong) GCKMediaInformation *mediaInformation;

@end

static NSString * kReceiverAppID;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"NBA Highlights";
    
     kReceiverAppID=kGCKMediaDefaultReceiverApplicationID;
    // Establish filter criteria.
    GCKFilterCriteria *filterCriteria = [GCKFilterCriteria
                                         criteriaForAvailableApplicationWithID:kReceiverAppID];
    // Initialize device scanner.
    self.deviceScanner = [[GCKDeviceScanner alloc] initWithFilterCriteria:filterCriteria];
    [_deviceScanner addListener:self];
    [_deviceScanner startScan];
    [_deviceScanner setPassiveScan:YES];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (IBAction)chooseDevice:(id)sender {
    if (_selectedDevice == nil) {
        // [START showing-devices]
        [_deviceScanner setPassiveScan:NO];
        // Choose device.
        UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Connect to device", nil)
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        for (GCKDevice *device in _deviceScanner.devices) {
            [sheet addButtonWithTitle:device.friendlyName];
        }
        
        // [START_EXCLUDE]
        // Further customizations
        [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        // [END_EXCLUDE]
        
        // Show device selection.
        [sheet showInView:self.view];
    } else {
        // Gather stats from device.
        [self updateStatsFromDevice];
        
        NSString *mediaTitle = [_mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
        
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.title = _selectedDevice.friendlyName;
        sheet.delegate = self;
        if (mediaTitle != nil) {
            [sheet addButtonWithTitle:mediaTitle];
        }
        
        // Offer disconnect option.
        [sheet addButtonWithTitle:@"Disconnect"];
        [sheet addButtonWithTitle:@"Cancel"];
        sheet.destructiveButtonIndex = (mediaTitle != nil ? 1 : 0);
        sheet.cancelButtonIndex = (mediaTitle != nil ? 2 : 1);
        
        [sheet showInView:self.view];
    }
}

- (void)reloadDataWithType:(NSString *)type {
    [self sendRequest:type isVideo:NO];
}

- (void)reloadRequest {
    [self sendRequest:@"" isVideo:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [self reloadRequest];
}

#pragma mark - UITableView Delegate and Datasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectionContentArray.count > 0) {
        NSArray *contentArray = self.sectionContentArray[section];
        
        return contentArray.count;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString static *bannerIdentifier = @"BannerCell";
    
    BannerCell *cell = (BannerCell *)[tableView dequeueReusableCellWithIdentifier:bannerIdentifier];
    
    if (self.sectionContentArray.count > 0) {
        NSArray *dataArray = self.sectionContentArray[indexPath.section];
        
        [cell updateWithInfo:dataArray[indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (336 * self.view.frame.size.width) / 600;;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sectionTitleArray.count > 0) {
        return self.sectionTitleArray[section];
    } else {
        return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataArray = self.sectionContentArray[indexPath.section];
    
    [self sendRequest:dataArray[indexPath.row][@"url"] isVideo:YES];
}

#pragma mark - Send request to get data

- (void)sendRequest:(NSString *)request isVideo:(BOOL)isVideo {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    
    NSString *url = @"";
    
    self.sectionTitleArray = [[NSMutableArray alloc] init];
    self.sectionContentArray = [[NSMutableArray alloc] init];
    
    if ([request isEqualToString:@""]) {
        url = @"http://nba-daily.herokuapp.com";
    } else {
        url = [NSString stringWithFormat:@"http://nba-daily.herokuapp.com%@", request];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (responseDictionary != nil) {
            if (isVideo) {
                // Show the video on the iphone if not connected.
                if (!_deviceManager
                    || _deviceManager.connectionState != GCKConnectionStateConnected) {
                    [self playVideo:responseDictionary[@"video"]];
                    return;
                }
       
                GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
                
                [metadata setString:responseDictionary[@"title"] ? : @"" forKey:kGCKMetadataKeyTitle];
                
                [metadata setString:responseDictionary[@"description"] ? : @""
                             forKey:kGCKMetadataKeySubtitle];
                
                [metadata addImage:[[GCKImage alloc]
                                    initWithURL:[[NSURL alloc] initWithString:responseDictionary[@"thumbnailUrl"] ? : @""]
                                    width:480
                                    height:360]];
                GCKMediaInformation *mediaInformation =
                [[GCKMediaInformation alloc] initWithContentID:
                 responseDictionary[@"video"]
                                                    streamType:GCKMediaStreamTypeNone
                                                   contentType:@"video/mp4"
                                                      metadata:metadata
                                                streamDuration:0
                                                    customData:nil];
                
                // Cast the video.
                [_mediaControlChannel loadMedia:mediaInformation autoplay:YES playPosition:0];
                
                [self reloadRequest];
            
            } else {
                self.sectionTitleArray = [[responseDictionary allKeys] mutableCopy];
                NSMutableArray *titleArray = [[NSMutableArray alloc] init];
                
                for (NSInteger i = self.sectionTitleArray.count - 1; i >= 0; i--) {
                    [self.sectionContentArray addObject:responseDictionary[self.sectionTitleArray[i]]];
                    [titleArray addObject:self.sectionTitleArray[i]];
                }
                
                self.sectionTitleArray = titleArray;
            }
        }
        
        [self.tableView reloadData];
        
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (IBAction)indexChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self sendRequest:@"" isVideo:NO];
    }
    
    // Waiting for backend update
    
//    else if (sender.selectedSegmentIndex == 1) {
//        [self sendRequest:@"/top-10"];
//    }
}

- (void)playVideo:(NSString *)videoURL {
    MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
    [self.navigationController presentMoviePlayerViewControllerAnimated:mpvc];
}

#pragma mark - Chromecast methods

- (void)updateStatsFromDevice {
    if (_mediaControlChannel &&
        _deviceManager.connectionState == GCKConnectionStateConnected) {
        _mediaInformation = _mediaControlChannel.mediaStatus.mediaInformation;
    }
}

- (void)connectToDevice {
    if (_selectedDevice == nil) {
        return;
    }
    
    self.deviceManager =
    [[GCKDeviceManager alloc] initWithDevice:_selectedDevice
                           clientPackageName:[NSBundle mainBundle].bundleIdentifier];
    self.deviceManager.delegate = self;
    [_deviceManager connect];
}

- (void)deviceDisconnected {
    self.mediaControlChannel = nil;
    self.deviceManager = nil;
    self.selectedDevice = nil;
}

- (void)updateButtonStates {
    if (_deviceScanner && _deviceScanner.devices.count > 0) {
        // Show the Cast button.
        self.navigationItem.rightBarButtonItems = @[_googleCastButton];
        if (_deviceManager && _deviceManager.connectionState == GCKConnectionStateConnected) {
            // Show the Cast button in the enabled state.
            [_googleCastButton setTintColor:[UIColor blueColor]];
        } else {
            // Show the Cast button in the disabled state.
            [_googleCastButton setTintColor:[UIColor grayColor]];
        }
    } else {
        //Don't show cast button.
        self.navigationItem.rightBarButtonItems = @[];
    }
}

#pragma mark - GCKDeviceScannerListener
- (void)deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"device found!! %@", device.friendlyName);
    [self updateButtonStates];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
    [self updateButtonStates];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_deviceScanner setPassiveScan:YES];
    if (_selectedDevice == nil) {
        if (buttonIndex < _deviceScanner.devices.count) {
            self.selectedDevice = _deviceScanner.devices[buttonIndex];
            NSLog(@"Selecting device:%@", _selectedDevice.friendlyName);
            [self connectToDevice];
        }
    } else {
        if (buttonIndex == 0) {  //Disconnect button
            NSLog(@"Disconnecting device:%@", self.selectedDevice.friendlyName);
            // New way of doing things: We're not going to stop the applicaton. We're just going
            // to leave it.
            [_deviceManager leaveApplication];
            [_deviceManager disconnect];
            
            [self deviceDisconnected];
            [self updateButtonStates];
        }
    }
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"connected to %@!", _selectedDevice.friendlyName);
    
    [self updateButtonStates];
    [_deviceManager launchApplication:kReceiverAppID];
}

// [START media-control-channel]
- (void)deviceManager:(GCKDeviceManager *)deviceManager didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID launchedApplication:(BOOL)launchedApplication {
    
    NSLog(@"application has launched");
    self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    self.mediaControlChannel.delegate = self;
    [_deviceManager addChannel:self.mediaControlChannel];
    // [START_EXCLUDE silent]
    [_mediaControlChannel requestStatus];
    //[END_EXCLUDE silent]
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error {
    [self showError:error];
    
    [self deviceDisconnected];
    [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectWithError:(GCKError *)error {
    [self showError:error];
    
    [self deviceDisconnected];
    [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
    NSLog(@"Received notification that device disconnected");
    if (error != nil) {
        [self showError:error];
    }
    
    [self deviceDisconnected];
    [self updateButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
    self.applicationMetadata = applicationMetadata;
}

#pragma mark - misc
- (void)showError:(NSError *)error {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Error"
                                        message:error.description
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
