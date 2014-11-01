//
//  FileTableViewController.m
//  DisplayAcc
//
//  Created by Rafael Aguayo on 10/30/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import "FileTableViewController.h"

@implementation FileTableViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* path = [documentsPath stringByAppendingString:@"/data"];
    NSError *err;
    NSArray *dummy = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
    
    if(err) {
        // do nothing
    }
    else {
        self.dirContent = [dummy mutableCopy];
    }
    
    NSLog(@"pathName: %@", path);
    NSLog(@"length of dir in view did load %lu", (unsigned long)[self.dirContent count]);
    
    
    //self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier  isEqualToString: @"showText"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString* path = [documentsPath stringByAppendingString:@"/data/"];
        
        path = [path stringByAppendingString:[self.dirContent objectAtIndex:indexPath.row]];
        TextViewController *destView = segue.destinationViewController;
        destView.pathName = path;
        destView.navBarTitle = [self.dirContent objectAtIndex:indexPath.row];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.cellText = [self.dirContent objectAtIndex:indexPath.row];
        
        [self.dirContent removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
        NSLog(@"cell name: %@", self.cellText);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString* path = [documentsPath stringByAppendingString:@"/data/"];
        path = [path stringByAppendingString:self.cellText];
        BOOL remove = [fileManager removeItemAtPath:path error:nil];
        if(remove)
            NSLog(@"Successfuly removed");
        
        NSLog(@"Name of file: %@", path);
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dirContent count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [self.tableView
            dequeueReusableCellWithIdentifier:CellIdentifier
            forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.dirContent objectAtIndex:indexPath.row];
    
    return cell;
}


@end
