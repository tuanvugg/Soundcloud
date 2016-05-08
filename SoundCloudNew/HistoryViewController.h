//
//  HistoryViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface HistoryViewController : MainViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblHistory;

@end
