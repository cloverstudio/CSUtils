//
//  CSViewController.h
//  CSLazyLoadTests
//
//  Created by Josip Bernat on 24/01/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
