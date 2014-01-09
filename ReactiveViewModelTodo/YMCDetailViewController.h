//
//  YMCDetailViewController.h
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 31.12.13.
//  Copyright (c) 2013 YMC AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMCDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
