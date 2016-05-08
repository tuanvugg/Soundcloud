//
//  MoreViewController.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "MoreViewController.h"
#import "Constant.h"
#import "Constant.h"
#import "MoreCell.h"
#import "AppDelegate.h"
#import "NowPlayingViewController.h"
#import "UIImage+Custom.h"

@interface MoreViewController ()

@property(nonatomic,strong) NSArray *colors;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lblHeader.textColor = kAppColor;
    
    //setup header separator
    _tblColors.tableHeaderView = ({UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblColors.frame.size.width, 1 / UIScreen.mainScreen.scale)];
        line.backgroundColor = _tblColors.separatorColor;
        line;
    });
    
    _tblColors.separatorStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([NowPlayingViewController sharedManager].playingTrack) {
        
        UIImage *btnPlayingImage = [UIImage customWithTintColor:kAppColor duration:1.5];
        
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithImage:btnPlayingImage style:UIBarButtonItemStyleBordered target:self action:@selector(btnPlayingDidTouch)];
        self.navigationItem.rightBarButtonItem = barItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)btnPlayingDidTouch;
{
    NowPlayingViewController *nowPlayingViewController = [NowPlayingViewController sharedManager];
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.3f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [nowPlayingViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:nowPlayingViewController animated:NO];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellId = @"moreCell";
    
    MoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"MoreCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (indexPath.row == 0) {
        cell.lblColor.text = @"Black Color";
        cell.lblColor.textColor = [UIColor blackColor];
    } else if (indexPath.row == 1) {
        cell.lblColor.text = @"Dark Gray Color";
        cell.lblColor.textColor = [UIColor darkGrayColor];
    } else if (indexPath.row == 2) {
        cell.lblColor.text = @"Light Gray Color";
        cell.lblColor.textColor = [UIColor lightGrayColor];
    } else if (indexPath.row == 3) {
        cell.lblColor.text = @"Gray Color";
        cell.lblColor.textColor = [UIColor grayColor];
    } else if (indexPath.row == 4) {
        cell.lblColor.text = @"Red Color";
        cell.lblColor.textColor = [UIColor redColor];
    } else if (indexPath.row == 5) {
        cell.lblColor.text = @"Green Color";
        cell.lblColor.textColor = [UIColor greenColor];
    } else if (indexPath.row == 6) {
        cell.lblColor.text = @"Blue Color";
        cell.lblColor.textColor = [UIColor blueColor];
    } else if (indexPath.row == 7) {
        cell.lblColor.text = @"Cyan Color";
        cell.lblColor.textColor = [UIColor cyanColor];
    } else if (indexPath.row == 8) {
        cell.lblColor.text = @"Yellow Color";
        cell.lblColor.textColor = [UIColor yellowColor];
    } else if (indexPath.row == 9) {
        cell.lblColor.text = @"Magenta Color";
        cell.lblColor.textColor = [UIColor magentaColor];
    } else if (indexPath.row == 10) {
        cell.lblColor.text = @"Orange Color";
        cell.lblColor.textColor = [UIColor orangeColor];
    } else if (indexPath.row == 11) {
        cell.lblColor.text = @"Purple Color";
        cell.lblColor.textColor = [UIColor purpleColor];
    } else if (indexPath.row == 12) {
        cell.lblColor.text = @"Brown Color";
        cell.lblColor.textColor = [UIColor brownColor];
    }
    
    return cell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSLog(@"%@",[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppColor"]]);
    
    NSData *colorData = nil;
    
    //Change AppColor
    if (indexPath.row == 0) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]];
    } else if (indexPath.row == 1) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor darkGrayColor]];
    } else if (indexPath.row == 2) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor lightGrayColor]];
    } else if (indexPath.row == 3) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor grayColor]];
    } else if (indexPath.row == 4) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor redColor]];
    } else if (indexPath.row == 5) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor greenColor]];
    } else if (indexPath.row == 6) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor blueColor]];
    } else if (indexPath.row == 7) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor cyanColor]];
    } else if (indexPath.row == 8) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor yellowColor]];
    } else if (indexPath.row == 9) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor magentaColor]];
    } else if (indexPath.row == 10) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor orangeColor]];
    } else if (indexPath.row == 11) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor purpleColor]];
    } else if (indexPath.row == 12) {
        colorData = [NSKeyedArchiver archivedDataWithRootObject:[UIColor brownColor]];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"AppColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _lblHeader.textColor = kAppColor;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.tintColor = kAppColor;
    [[UITabBar appearance] setTintColor:kAppColor];
    [[UITabBar appearance] setBarTintColor:kAppColor];
    
    
    
    //Show Alert View
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Color changed! Restart to see the change."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
