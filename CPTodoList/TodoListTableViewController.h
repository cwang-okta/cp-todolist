//
//  TodoListTableViewController.h
//  CPTodoList
//
//  Created by Christine Wang on 1/24/14.
//  Copyright (c) 2014 Christine Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodoListTableViewController : UITableViewController<UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *todoItems;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapRecognizer;

@end
