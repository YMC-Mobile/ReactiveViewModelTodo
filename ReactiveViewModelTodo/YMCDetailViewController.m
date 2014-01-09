//
//  YMCDetailViewController.m
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 31.12.13.
//  Copyright (c) 2013 YMC AG. All rights reserved.
//

#import "YMCDetailViewController.h"
#import "YMCTodoViewModel.h"
#import "YMCTodoItem.h"
#import <ReactiveCocoa/UIControl+RACSignalSupport.h>

@interface YMCDetailViewController ()
@property (weak, nonatomic) YMCTodoViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueDatePicker;
@property (weak, nonatomic) IBOutlet UISwitch *chkCompleted;
@property (weak, nonatomic) IBOutlet UILabel *lblNoItemSelected;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation YMCDetailViewController
objection_requires(@"viewModel");

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[JSObjection defaultInjector] injectDependencies:self];
    
    @weakify(self)

    RAC(self, title) = RACObserve(self.viewModel, selectedItem.title);
    
    // Two way binding for textfield to the selected item
    RAC(self.viewModel, selectedItem.title) = self.txtTitle.rac_newTextChannel;
    RAC(self.txtTitle, text) = RACObserve(self.viewModel, selectedItem.title);
    
    // Two way binding for date picker to the selected item
    [[self.dueDatePicker rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self)
        self.viewModel.selectedItem.date = self.dueDatePicker.date;
    }];
    RAC(self.dueDatePicker, date) = [RACObserve(self.viewModel, selectedItem.date) filter:^BOOL(id value) {
        return value != nil;
    }];

    // Two way binding for completed switch to the selected item
    RAC(self.viewModel, selectedItem.completed) = self.chkCompleted.rac_newOnChannel;
    RAC(self.chkCompleted, on) = [RACObserve(self.viewModel, selectedItem.completed) filter:^BOOL(id value) {
        return value != nil;
    }];
    
    [RACObserve(self.viewModel, selectedItem) subscribeNext:^(id item) {
        @strongify(self)
        if (self.masterPopoverController != nil) {
            [self.masterPopoverController dismissPopoverAnimated:YES];
        }
    }];

    // Disable the "No Item Selected" overlay when there is no item selected
    RAC(self.lblNoItemSelected, hidden) = [RACObserve(self.viewModel, selectedItem) map:^id(id value) {
        return @(value != nil);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
