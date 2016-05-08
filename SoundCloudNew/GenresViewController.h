//
//  GenresViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface GenresViewController : MainViewController <UITableViewDataSource,UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblGenres;

@end
