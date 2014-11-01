//
//  TextViewController.h
//  DisplayAcc
//
//  Created by Rafael Aguayo on 10/31/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewController : UIViewController<UITextViewDelegate>

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (nonatomic,strong) NSString *pathName;
@property (nonatomic,strong) NSString *navBarTitle;

@end
