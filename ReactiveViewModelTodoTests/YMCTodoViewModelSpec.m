//
//  YMCMasterViewModel.m
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 06.01.14.
//  Copyright (c) 2014 YMC AG. All rights reserved.
//

#import "Kiwi.h"
#import "YMCTodoViewModel.h"
#import "YMCTodoItem.h"

SPEC_BEGIN(YMCTodoViewModelSpec)

describe(@"YMCTodoViewModel", ^{
    
    __block YMCTodoViewModel *todoViewModel;
    
    beforeEach(^{
        todoViewModel = [YMCTodoViewModel new];
        // we don't have dependencies in this simple exmample, if we would, we should wire up mocks here:
        // todoViewModel.someDependentService = [SomeAwesomeService mock];
        [todoViewModel awakeFromObjection];
    });
    
    it(@"numberOfRows should be 1", ^{
        [[@([todoViewModel numberOfRows]) should] equal:theValue(1)];
    });
    
    it(@"selected item should be 'add some items'", ^{
        [[todoViewModel.selectedItem.title should] equal:@"add some items"];
    });
    
    context(@"when adding 'NewItem' to index 0", ^{
        __block int itemInsertedAtSignalResult = -1;
        
        beforeEach(^{
            [todoViewModel.itemInsertedAtSignal subscribeNext:^(NSNumber *x) {
                itemInsertedAtSignalResult = [x intValue];
            }];
            
            YMCTodoItem *item = [YMCTodoItem new];
            item.title =  @"New Item";
            item.date= [NSDate date];
            
            [todoViewModel insertItem:item atIndex:0];
        });
        
        it(@"numberOfRows should be 2", ^{
            [[@([todoViewModel numberOfRows]) should] equal:theValue(2)];
        });
        
        it(@"selected item should be 'New Item'", ^{
            [[todoViewModel.selectedItem.title should] equal:@"New Item"];
        });
        
        it(@"itemAtIndex:0 should be 'New Item'", ^{
            [[[todoViewModel itemAtIndex:0].title should] equal:@"New Item"];
        });
        
        it(@"itemInsertedAtSignal should be invoked", ^{
            [[expectFutureValue(theValue(itemInsertedAtSignalResult)) shouldEventually] equal:theValue(0)];
        });
    });
    
    
    context(@"when deleting item at index 0", ^{
        __block int itemDeletedAtSignalResult = -1;
        
        beforeEach(^{
            [todoViewModel.itemDeletedAtSignal subscribeNext:^(NSNumber *x) {
                itemDeletedAtSignalResult = [x intValue];
            }];
            
            [todoViewModel deleteItemAtIndex:0];
        });
        
        it(@"numberOfRows should be 0", ^{
            [[@([todoViewModel numberOfRows]) should] equal:theValue(0)];
        });
        
        it(@"selected item should be nil", ^{
            [[todoViewModel.selectedItem should] beNil];
        });

        it(@"itemDeletedAtSignal should be invoked", ^{
            [[expectFutureValue(theValue(itemDeletedAtSignalResult)) shouldEventually] equal:theValue(0)];
        });
    });
    
    context(@"when executing the addCommand", ^{
        __block int itemInsertedAtSignalResult = -1;
        beforeEach(^{
            [todoViewModel.itemInsertedAtSignal subscribeNext:^(NSNumber *x) {
                itemInsertedAtSignalResult = [x intValue];
            }];
            
            [todoViewModel.addCommand execute:self];
        });
        
        it(@"selectedItem should be set to the new item", ^{
            [[expectFutureValue(todoViewModel.selectedItem.title) shouldEventually] equal:@"Entry 1"];
        });
        
        it(@"itemInsertedAtSignal should be invoked", ^{
            [[expectFutureValue(theValue(itemInsertedAtSignalResult)) shouldEventually] equal:theValue(0)];
        });
        
        it(@"numberOfRows should be increased", ^{
            [[expectFutureValue(theValue([todoViewModel numberOfRows])) shouldEventually] equal:theValue(2)];
        });
    });
    
    context(@"with some unsorted items added", ^{
        beforeEach(^{
            
            YMCTodoItem *item1 = [YMCTodoItem new];
            item1.title =  @"Item 1";
            item1.date= [NSDate dateWithTimeIntervalSince1970:1];
            
            YMCTodoItem *item2 = [YMCTodoItem new];
            item2.title =  @"Item 2";
            item2.date= [NSDate dateWithTimeIntervalSince1970:2];
            
            YMCTodoItem *item3 = [YMCTodoItem new];
            item3.title =  @"Item 3";
            item3.date= [NSDate dateWithTimeIntervalSince1970:3];
            
            [todoViewModel insertItem:item3 atIndex:1];
            [todoViewModel insertItem:item2 atIndex:2];
            [todoViewModel insertItem:item1 atIndex:3];
            
        });
        
        it(@"should have selected the last inserted", ^{
            [[expectFutureValue(theValue(todoViewModel.selectedItemIndex)) shouldEventually] equal:theValue(3)];
        });
        
        context(@"the sortCommand", ^{
            it(@"should be enabled", ^{
                __block NSNumber *result = nil;
                
                [todoViewModel.sortCommand.enabled subscribeNext:^(NSNumber *x) {
                    result = x;
                }];
                
                [[expectFutureValue(result) shouldEventually] beTrue];
            });
            
            context(@"when executing the sortCommand", ^{
                __block id refreshSignalResult = nil;
                
                beforeEach(^{
                    [todoViewModel.refreshSignal subscribeNext:^(id x) {
                        refreshSignalResult = x;
                    }];
                    
                    [todoViewModel.sortCommand execute:self];
                });
                
                it(@"refreshSignal should be invoked", ^{
                    [[expectFutureValue(theValue(refreshSignalResult)) shouldEventually] beNonNil];
                });
                
                it(@"items should be sorted by date", ^{
                    [[expectFutureValue([todoViewModel itemAtIndex:0].title) shouldEventually] equal:@"Item 1"];
                    [[expectFutureValue([todoViewModel itemAtIndex:1].title) shouldEventually] equal:@"Item 2"];
                    [[expectFutureValue([todoViewModel itemAtIndex:2].title) shouldEventually] equal:@"Item 3"];
                    [[expectFutureValue([todoViewModel itemAtIndex:3].title) shouldEventually] equal:@"add some items"];
                });
                
                it(@"should remain the selected item", ^{
                    [[expectFutureValue(theValue(todoViewModel.selectedItemIndex)) shouldEventually] equal:theValue(0)];
                });
                
                it(@"should be be disabled", ^{
                    __block NSNumber *result = nil;
                    
                    [todoViewModel.sortCommand.enabled subscribeNext:^(NSNumber *x) {
                        result = x;
                    }];
                    
                    [[expectFutureValue(result) shouldEventually] beFalse];
                });
            });
        });

        context(@"when selecting an item", ^{
            __block int itemSelectedAtSignalResult = -1;
            
            beforeEach(^{
                [todoViewModel.itemSelectedAtSignal subscribeNext:^(NSNumber *x) {
                    itemSelectedAtSignalResult = [x intValue];
                }];
                
                [todoViewModel selectItemAtIndex:2];
            });
            
            it(@"selectedItem should be 'Item 2'", ^{
                [[todoViewModel.selectedItem.title should] equal:@"Item 2"];
            });
            
            it(@"itemSelectedAtSignal should be invoked", ^{
                [[expectFutureValue(theValue(itemSelectedAtSignalResult)) shouldEventually] equal:theValue(2)];
            });
        });
        
    });
    
});

SPEC_END