//
//  YMCTodoItem.h
//  ReactiveViewModelTodo
//
//  Created by Nils Kübler on 07.01.14.
//  Copyright (c) 2014 YMC AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMCTodoItem : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL completed;

@end
