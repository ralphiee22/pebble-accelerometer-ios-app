//
//  TextViewController.m
//  DisplayAcc
//
//  Created by Rafael Aguayo on 10/31/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import "TextViewController.h"

@implementation TextViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *txtContent = [[NSString alloc]
                            initWithContentsOfFile:_pathName
                            encoding:NSUTF8StringEncoding
                            error:nil];
    
    _textView.text = txtContent;
    _navBar.title = _navBarTitle;
    _textView.editable = NO;
}


@end
