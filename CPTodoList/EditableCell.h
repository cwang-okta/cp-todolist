//
//  EditableCell.h
//  CPTodoList
//
//  Created by Christine Wang on 1/24/14.
//  Copyright (c) 2014 Christine Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *todoItem;

@end
