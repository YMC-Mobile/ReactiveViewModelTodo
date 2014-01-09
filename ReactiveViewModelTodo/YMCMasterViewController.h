//
//  YMCMasterViewController.h
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 31.12.13.
//  Copyright (c) 2013 YMC AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YMCDetailViewController;

@interface YMCMasterViewController : UITableViewController

@property (strong, nonatomic) YMCDetailViewController *detailViewController;

@end
