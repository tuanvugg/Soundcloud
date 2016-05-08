//
//  SearchViewController.h
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>


@interface SearchViewController : MainViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblSuggestResult;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchResult;
@property (weak, nonatomic) IBOutlet UILabel *lblWelcome;

@end