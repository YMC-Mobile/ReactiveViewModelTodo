//
//  YMCTodoViewModel.m
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 06.01.14.
//  Copyright (c) 2014 YMC AG. All rights reserved.
//

#import "YMCTodoViewModel.h"
#import "YMCTodoItem.h"

@interface YMCTodoViewModel()

@property (weak, nonatomic) YMCTodoItem *selectedItem;
@property (assign, nonatomic) int selectedItemIndex;

@property (assign, nonatomic) BOOL itemsSorted;
@property (strong, nonatomic) NSMutableArray *items;

@property (strong, nonatomic) RACSubject *refreshSubject;
@property (strong, nonatomic) RACSubject *itemInsertedAtSubject;
@property (strong, nonatomic) RACSubject *itemDeletedAtSubject;
@property (strong, nonatomic) RACSubject *itemSelectedAtSubject;

@end

@implementation YMCTodoViewModel
objection_register_singleton(YMCTodoViewModel)

- (id)init {
    if(!(self = [super init])) {
        return nil;
    }
    return self;
}

- (void) awakeFromObjection {
    self.items = [NSMutableArray new];
    
    // add one sample item
    YMCTodoItem *item = [YMCTodoItem new];
    item.title = @"add some items";
    item.date = [NSDate date];
    [self insertItem:item atIndex:0];
    
    self.itemInsertedAtSubject = [RACSubject subject];
    self.itemDeletedAtSubject = [RACSubject subject];
    self.itemSelectedAtSubject = [RACSubject subject];
    self.refreshSubject = [RACSubject subject];
}

- (RACSignal*) itemInsertedAtSignal {
    return self.itemInsertedAtSubject;
}

- (RACSignal*) itemDeletedAtSignal {
    return self.itemDeletedAtSubject;
}

- (RACSignal*) itemSelectedAtSignal {
    return self.itemSelectedAtSubject;
}

- (RACSignal*) refreshSignal {
    return self.refreshSubject;
}

- (int) numberOfRows {
    return [self.items count];
}

- (YMCTodoItem*) itemAtIndex:(uint)index {
    return self.items[index];
}

- (uint) itemIndex:(YMCTodoItem*)item {
    return [self.items indexOfObject:item];
}

- (void) deleteItemAtIndex:(uint) index {
    [self.items removeObjectAtIndex:index];
    [self.itemDeletedAtSubject sendNext:@(index)];
    self.selectedItem = nil;
    [self testIfSorted];
}

- (void) selectItemAtIndex:(uint)index {
    self.selectedItem = [self itemAtIndex:index];
    self.selectedItemIndex = index;
    if(self.selectedItem) {
        [self.itemSelectedAtSubject sendNext:@(index)];
    }
}

- (void) insertItem:(YMCTodoItem*)item atIndex:(uint) index {
    [self.items insertObject:item atIndex:index];
    [self.itemInsertedAtSubject sendNext:@(index)];
    [self selectItemAtIndex:index];
    [self testIfSorted];
    @weakify(self)
    [RACObserve(item, date) subscribeNext:^(id x) {
        @strongify(self)
        [self testIfSorted];
    }];
}

- (RACCommand*) addCommand {
    if(!_addCommand) {
        @weakify(self);
        _addCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal defer:^RACSignal *{
                @strongify(self);
                YMCTodoItem *item = [YMCTodoItem new];
                static int entryNumber = 0;
                entryNumber++;
                item.title = [NSString stringWithFormat:@"Entry %i", entryNumber];
                item.date = [NSDate date];
                [self insertItem:item atIndex:0];
                return [RACSignal empty];
            }];
        }];
    }
    return _addCommand;
}

- (RACCommand*) sortCommand {
    if(!_sortCommand) {
        @weakify(self);
        _sortCommand = [[RACCommand alloc] initWithEnabled:[RACObserve(self, itemsSorted) not] signalBlock:^RACSignal *(id input) {
            return [RACSignal defer:^RACSignal *{
                YMCTodoItem *selectedItem = self.selectedItem;
                @strongify(self);
                [self.items sortUsingComparator:^NSComparisonResult(YMCTodoItem *a, YMCTodoItem *b) {
                    return [a.date compare:b.date];
                }];
                [self testIfSorted];
                [self.refreshSubject sendNext:self.items];
                [self selectItemAtIndex:[self itemIndex:selectedItem]];
                return [RACSignal empty];
            }];
        }];
    }
    return _sortCommand;
}

# pragma section - Helpers

- (void) testIfSorted {
    NSDate *lastDate = nil;
    for (YMCTodoItem *item in self.items) {
        if(lastDate && [lastDate compare:item.date] > 0) {
            self.itemsSorted = NO;
            return;
        }
        lastDate = item.date;
    }
    self.itemsSorted = YES;
}

@end
