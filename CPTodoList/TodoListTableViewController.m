//
//  TodoListTableViewController.m
//  CPTodoList
//
//  Created by Christine Wang on 1/24/14.
//  Copyright (c) 2014 Christine Wang. All rights reserved.
//

#import "TodoListTableViewController.h"
#import "EditableCell.h"

@interface TodoListTableViewController ()

@property (nonatomic, assign) BOOL shouldBecomeFirstResponder;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;

@end

@implementation TodoListTableViewController

static NSString *CellIdentifier = @"EditableCell";
static NSString *TodoListKey = @"TodoList";
static const int TAG_OFFSET = 100;
static const int CELL_PADDING = 50;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"To Do List";
        self.todoItems = [[[NSUserDefaults standardUserDefaults] arrayForKey:TodoListKey] mutableCopy];
        self.shouldBecomeFirstResponder = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButton)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
    UINib *cellNib = [UINib nibWithNibName:@"EditableCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.tapRecognizer.enabled = NO;
        self.navigationItem.rightBarButtonItem = nil;
        [self.view endEditing:YES];
    } else {
        self.tapRecognizer.enabled = YES;
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.todoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.todoItem.delegate = self;
    cell.todoItem.text = [self.todoItems objectAtIndex:indexPath.row];
    cell.todoItem.tag = TAG_OFFSET + (int)indexPath.row;
    cell.todoItem.scrollEnabled = NO;
    cell.todoItem.clipsToBounds = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.todoItems removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self saveValues];
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [self.todoItems objectAtIndex:sourceIndexPath.row];
    [self.todoItems removeObjectAtIndex:sourceIndexPath.row];
    [self.todoItems insertObject:stringToMove atIndex:destinationIndexPath.row];
    [self saveValues];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldBecomeFirstResponder && indexPath.row == 0) {
        EditableCell *editableCell = (EditableCell *)cell;
        [editableCell.todoItem becomeFirstResponder];
        self.shouldBecomeFirstResponder = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *todoItemStr = [self.todoItems objectAtIndex:indexPath.row];
    
    // TODO: figure out why empty string gives a different height with boundingRect
    if ([todoItemStr isEqualToString:@""]) {
        todoItemStr = @"A";
    }

    NSAttributedString *todoItemAttrStr = [[NSAttributedString alloc] initWithString:todoItemStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
    
    CGRect todoItemFrame = [todoItemAttrStr boundingRectWithSize:CGSizeMake([self getScreenWidth] - CELL_PADDING, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        context:nil];
    return ceilf(todoItemFrame.size.height + 18);
}

#pragma mark - Text View Delegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    NSString *currentStr = textView.text;
    NSString *updatedStr = [textView.text stringByReplacingCharactersInRange:range withString:text];

    [self.todoItems replaceObjectAtIndex:textView.tag - TAG_OFFSET withObject:updatedStr];
    [self saveValues];
    
    // Edit cell height if textView height changes
    NSAttributedString *beforeStr = [[NSAttributedString alloc] initWithString:currentStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
    NSAttributedString *afterStr = [[NSAttributedString alloc] initWithString:updatedStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];

    CGRect beforeFrame = [beforeStr boundingRectWithSize:CGSizeMake([self getScreenWidth] - CELL_PADDING, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                 context:nil];
    CGRect afterFrame = [afterStr boundingRectWithSize:CGSizeMake([self getScreenWidth] - CELL_PADDING, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                               context:nil];
    
    if (afterFrame.size.height != beforeFrame.size.height) {
        [self updateTableView];
    }
    
    return YES;
}

- (CGFloat)getScreenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return screenRect.size.width;
    } else {
        return screenRect.size.height;
    }
}

- (BOOL)textViewShouldClear:(UITextView *)textView {
    return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return !self.isEditing;
}

#pragma mark -

- (void)updateTableView {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

- (void)onAddButton {
    [self.todoItems insertObject:@"" atIndex:0];
    [self.tableView reloadData];
    self.shouldBecomeFirstResponder = YES;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)saveValues {
    // Save values to NSUserDefaults
    // TODO: replace this w/ Parse
    
    [[NSUserDefaults standardUserDefaults] setObject:self.todoItems forKey:TodoListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
