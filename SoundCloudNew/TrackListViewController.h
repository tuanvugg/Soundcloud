//
//  TrackListViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/31/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface TrackListViewController : MainViewController <UITableViewDataSource,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tbvTracks;
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic,strong) Track *playingTrack;

@end
