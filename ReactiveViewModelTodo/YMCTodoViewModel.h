//
//  YMCTodoViewModel.h
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 06.01.14.
//  Copyright (c) 2014 YMC AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YMCTodoItem;

@interface YMCTodoViewModel : NSObject

@property (strong, nonatomic) RACCommand *addCommand;
@property (strong, nonatomic) RACCommand *sortCommand;
@property (readonly) YMCTodoItem *selectedItem;
@property (readonly, assign) int selectedItemIndex;

- (RACSignal*) refreshSignal;
- (RACSignal*) itemInsertedAtSignal;
- (RACSignal*) itemDeletedAtSignal;
- (RACSignal*) itemSelectedAtSignal;

- (int) numberOfRows;
- (YMCTodoItem*) itemAtIndex:(uint)index;
- (void) deleteItemAtIndex:(uint) index;
- (void) selectItemAtIndex:(uint) index;
- (void) insertItem:(YMCTodoItem*)item atIndex:(uint) index;

@end
