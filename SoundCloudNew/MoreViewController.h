//
//  MoreViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface MoreViewController : MainViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblColors;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;

@end
