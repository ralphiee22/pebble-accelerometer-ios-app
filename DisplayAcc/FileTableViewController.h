//
//  FileTableViewController.h
//  DisplayAcc
//
//  Created by Rafael Aguayo on 10/30/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextViewController.h"

@interface FileTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong)NSMutableArray *dirContent;
@property (nonatomic,strong)NSString *cellText;

@end
