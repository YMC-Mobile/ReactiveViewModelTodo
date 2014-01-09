//
//  YMCMasterViewController.m
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 31.12.13.
//  Copyright (c) 2013 YMC AG. All rights reserved.
//

#import "YMCMasterViewController.h"

#import "YMCDetailViewController.h"

#import "YMCTodoViewModel.h"
#import "YMCTodoItem.h"

@interface YMCMasterViewController()

@property (weak, nonatomic) YMCTodoViewModel *viewModel;

@end

@implementation YMCMasterViewController
objection_requires(@"viewModel");

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[JSObjection defaultInjector] injectDependencies:self];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    addButton.rac_command = self.viewModel.addCommand;
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"sort" style:UIBarButtonItemStylePlain target:nil action:nil];
    sortButton.rac_command = self.viewModel.sortCommand;
    self.navigationItem.leftBarButtonItem = sortButton;
    
    self.detailViewController = (YMCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    @weakify(self);
    
    [self.viewModel.itemInsertedAtSignal subscribeNext:^(id x) {
        @strongify(self);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[x intValue] inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];

    [self.viewModel.itemDeletedAtSignal subscribeNext:^(id x) {
        @strongify(self);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[x intValue] inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [self.viewModel.refreshSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];

    // on the iPad we want our table to always display the selected item
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.viewModel.itemSelectedAtSignal subscribeNext:^(id index) {
            @strongify(self);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[index intValue] inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        }];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodoItemCell" forIndexPath:indexPath];
    
    YMCTodoItem *item = [self.viewModel itemAtIndex:indexPath.row];
    
    RAC(cell.textLabel, text) = [RACObserve(item, title) takeUntil:cell.rac_prepareForReuseSignal];
    
    RAC(cell.detailTextLabel, text) = [[RACObserve(item, date) takeUntil:cell.rac_prepareForReuseSignal] map:^id(NSDate *value) {
        return [NSString stringWithFormat:@"Due: %@", [value description]];
    }];
    
    RAC(cell.textLabel, textColor) = [[RACObserve(item, completed) takeUntil:cell.rac_prepareForReuseSignal] map:^id(id value) {
        if([value boolValue]) {
            return [UIColor lightGrayColor];
        } else {
            return [UIColor blackColor];
        }
    }];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel deleteItemAtIndex:indexPath.row];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel selectItemAtIndex:indexPath.row];
}


@end
