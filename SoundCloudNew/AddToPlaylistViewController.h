//
//  AddToPlaylistViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/30/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "MainViewController.h"
#import <UIKit/UIKit.h>
#import "Track.h"

@interface AddToPlaylistViewController : MainViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblPlaylists;
@property (nonatomic,strong) Track *track;

@end
