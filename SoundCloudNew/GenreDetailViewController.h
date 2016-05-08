//
//  GenreDetailViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/27/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "MainViewController.h"
#import <UIKit/UIKit.h>
#import "Genre.h"

@interface GenreDetailViewController : MainViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) Genre *selectedGenre;
@property (nonatomic, retain) NSMutableArray *tracks;
@property (weak, nonatomic) IBOutlet UITableView *tbvTracks;

@end
