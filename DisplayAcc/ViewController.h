//
//  ViewController.h
//  DisplayAcc
//
//  Created by Rafael Aguayo on 4/22/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) PBWatch *myWatch;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *nameInput;
@property (strong, nonatomic) NSOutputStream *stream;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UILabel *receiveData;
@property (weak, nonatomic) IBOutlet UILabel *trial;
@property (strong, nonatomic) NSString *data;

@end
