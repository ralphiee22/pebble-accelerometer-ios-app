//
//  ViewController.m
//  DisplayAcc
//
//  Created by Rafael Aguayo on 4/22/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <PBPebbleCentralDelegate>

@property (strong, nonatomic) PBWatch *myWatch;
@property (weak, nonatomic) IBOutlet UILabel *x_coord;
@property (weak, nonatomic) IBOutlet UILabel *y_coord;
@property (weak, nonatomic) IBOutlet UILabel *z_coord;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *nameInput;
@property (strong, nonatomic) NSOutputStream *stream;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UILabel *receiveData;
@property (weak, nonatomic) IBOutlet UILabel *trial;
@property (weak, nonatomic) IBOutlet UIButton *spoonDown;
@property (weak, nonatomic) IBOutlet UIButton *spoonUp;
@end

@implementation ViewController

BOOL isPressedDown;
BOOL isPressedUp;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [PBPebbleCentral setDebugLogsEnabled:YES];
    [[PBPebbleCentral defaultCentral] setDelegate:self];

    _receiveData.hidden = YES;
    _x_coord.hidden = YES;
    _y_coord.hidden = YES;
    _z_coord.hidden = YES;
    _trial.hidden = YES;
    
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"048d67db-f86a-4363-99a2-1fbd564c88a8"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    self.myWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    NSLog(@"Last connected watch: %@", self.myWatch);
    
}

- (NSString *) applicationDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"documentsPath: %@", documentsPath);
    NSString* path = [documentsPath stringByAppendingString:@"/data"];
    NSLog(@"path: %@", path);
    
    _path = [path stringByAppendingString:@"/"];
    _path = [_path stringByAppendingString:[_firstName text]];
    _path = [_path stringByAppendingString:@"_"];
    _path = [_path stringByAppendingString:[_lastName text]];
    _path = [_path stringByAppendingString:@"_acc.txt"];
    NSLog(@"Name Input Path: %@", _path);
    
    NSString* filePath = _path;
    //NSString* filePath = [path stringByAppendingString:@"/acc.txt"];

    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
    {
        NSError* err = nil;
        
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&err])
        {
            NSLog(@"Failed to create directory \"%@\". Error: %@", path, err);
        }
        else
            NSLog(@"created directory at path");
        
        if(![fileManager createFileAtPath:filePath contents:nil attributes:nil])
        {
            NSLog(@"Failed to create file at path \"%@\" ", filePath);
        }
        else
            NSLog(@"created file at path");
    }
    else {
        NSLog(@"Directory file exists at path");
    }
    return @"YES";
}


- (IBAction)startRecordingAccelValues:(id)sender {
    _firstName.hidden = YES;
    _lastName.hidden = YES;
    //_receiveData.hidden = NO;
    _trial.hidden = YES;
    
    [self applicationDirectory];

    
    [self.myWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        if (!error) {
            NSLog(@"Successfully launched app.");
        }
        else {
            NSLog(@"Error launching app - Error: %@", error);
        }
    }
     ];

    //NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //_path = [documentsPath stringByAppendingString:@"/data"];
    //_path = [_path stringByAppendingString:@"/acc.txt"];
    NSLog(@"OPENING STREAM FOR WRITING DATA");
    
    _stream = [[NSOutputStream alloc] initToFileAtPath:_path append:YES];
    [_stream open];
    __block int i = 0;
    __block int counter = 0;
    
    [self.myWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"Received Message:%@", update);
        i++;
        
        if(i == 1) {
            _receiveData.hidden = NO;
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MM-dd-yyyy 'at' hh:mm:ss"];
            
            NSDate* today = [NSDate date];
            NSString* dateString = [format stringFromDate:today];
            NSLog(@"DATE STRING: %@", dateString);
            dateString = [dateString stringByAppendingString:@"\n"];
            NSData* date = [dateString dataUsingEncoding:NSUTF8StringEncoding];
            [_stream write:date.bytes maxLength:date.length];
        }
        __block NSString *xyz = @"";
        NSString *temp = nil;
       // xyz = @"start\n";
        
        
        /*for(id key in update) {
            NSLog(@"key=%@ value=%@", key, [update objectForKey:key]);
            
            if([key isEqual: @(1)]) {
                [_x_coord setText:[NSString stringWithFormat:@"%d", (int32_t)[[update objectForKey:@(1)] int32Value] ]];
                temp = [NSString stringWithFormat:@"%d,", (int32_t)[[update objectForKey:@(1)] int32Value] ];
                xyz = [temp stringByAppendingString:xyz];
            }
            
            else if([key isEqual: @(2)]) {
                [_y_coord setText:[NSString stringWithFormat:@"%d", (int32_t)[[update objectForKey:@(2)] int32Value] ]];
                xyz = [NSString stringWithFormat:@"%d,", (int32_t)[[update objectForKey:@(2)] int32Value] ];
            }
            
            else if([key isEqual: @(3)]) {
                [_z_coord setText:[NSString stringWithFormat:@"%d", (int32_t)[[update objectForKey:@(3)] int32Value] ]];
                xyz = [xyz stringByAppendingString:[NSString stringWithFormat:@"%d", (int32_t)[[update objectForKey:@(3)] int32Value] ]];
            }
        }*/
      /*  NSArray *arrayOfKeys = [update allKeys];
        
        NSString *key = [arrayOfKeys objectAtIndex:0];
        NSString *stringAtIndexZero = [update objectForKey:key];
        
        for(id key in update) {
            NSLog(@"key=%@ value=%@", key, [update objectForKey:key]);
            //xyz = [xyz stringByAppendingString:[NSString stringWithFormat:@"%@\n", [update objectForKey:key]]];
            counter++;
            temp = [NSString stringWithFormat:@"%@,%d\n", [update objectForKey:key], counter];
            xyz = [xyz stringByAppendingString:temp];
        }*/
        
        for (id key in [[update allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            NSLog(@"key=%@ value=%@", key, [update objectForKey:key]);
            //xyz = [xyz stringByAppendingString:[NSString stringWithFormat:@"%@\n", [update objectForKey:key]]];
            counter++;
            temp = [NSString stringWithFormat:@"%@,%d\n", [update objectForKey:key], counter];
            xyz = [xyz stringByAppendingString:temp];
            if(isPressedDown) {
                xyz = [xyz stringByAppendingString:@"*\n"];
                isPressedDown = NO;
                
            }
            else if(isPressedUp) {
                xyz = [xyz stringByAppendingString:@"^\n"];
                isPressedUp = NO;
            }
        }

        
        
        xyz = [xyz stringByAppendingString:@""];
        NSLog(@"xyz: %@", xyz);
        NSData *data = [xyz dataUsingEncoding:NSUTF8StringEncoding];
        [_stream write:data.bytes maxLength: data.length];
        return YES;
    }];
}
- (IBAction)spoonBowl:(id)sender {
    isPressedDown = YES;
}

- (IBAction)spoonMouth:(id)sender {
    isPressedUp = YES;
}



- (IBAction)stopWatchApp:(id)sender {
    _firstName.hidden = NO;
    _lastName.hidden = NO;
    _receiveData.hidden = YES;
    _trial.hidden = NO;
    
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy 'at' hh:mm:ss"];
    
    NSDate* today = [NSDate date];
    NSString* dateString = [format stringFromDate:today];
    NSLog(@"DATE STRING: %@", dateString);
    dateString = [dateString stringByAppendingString:@"\n"];
    NSData* date = [dateString dataUsingEncoding:NSUTF8StringEncoding];
    [_stream write:date.bytes maxLength:date.length];

    [_stream close];
    
    [self.myWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
        if(error) {
            NSLog(@"Error closing watchapp: %@", error);
        }
    }];
    
    NSLog(@"CLOSING STREAM FOR WRITING DATA");

    
    NSFileManager *man = [NSFileManager defaultManager];
    NSData* returnData = [man contentsAtPath:_path];
    NSString *strData = [[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"ACCEL DATA: %@", strData);

}

/*
 * PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [[[UIAlertView alloc] initWithTitle:@"Connected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    NSLog(@"Pebble connected: %@", [watch name]);
    self.myWatch = watch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    NSLog(@"Pebble disconnected: %@", [watch name]);
    
    if (self.myWatch == watch || [watch isEqual:self.myWatch]) {
        self.myWatch = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
