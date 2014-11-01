//
//  ViewController.m
//  DisplayAcc
//
//  Created by Rafael Aguayo on 4/22/14.
//  Copyright (c) 2014 Rafael Aguayo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <PBPebbleCentralDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    [PBPebbleCentral setDebugLogsEnabled:YES];
    [[PBPebbleCentral defaultCentral] setDelegate:self];

    _receiveData.hidden = YES;
    _trial.hidden = YES;
    
    // set app id of current watch
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"048d67db-f86a-4363-99a2-1fbd564c88a8"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    // prints out last connected watch
    self.myWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    NSLog(@"Last connected watch: %@", self.myWatch);
    
}
- (IBAction)fileSegue:(id)sender {
    
    [self performSegueWithIdentifier:@"justTest" sender:self];
}

- (NSString *) applicationDirectory
{
    
    // create path for data directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"documentsPath: %@", documentsPath);
    NSString* path = [documentsPath stringByAppendingString:@"/data"];
    NSLog(@"path: %@", path);
    
    _path = @"";
    
    _path = [path stringByAppendingString:@"/"];
    _path = [_path stringByAppendingString:[_firstName text]];
    _path = [_path stringByAppendingString:@"_acc.txt"];
    NSLog(@"Name Input Path: %@", _path);
    
    NSString* filePath = _path;

    // check if file name exists at path
    // if it doesn't create file at path
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
        NSLog(@"Directory file created at path");
    }
    return @"YES";
}


- (IBAction)startRecordingAccelValues:(id)sender {
    _firstName.hidden = YES;
    _trial.hidden = YES;
    
    [self applicationDirectory];

    
    // launch watch accelerometer application
    [self.myWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        if (!error) {
            NSLog(@"Successfully launched app.");
        }
        else {
            NSLog(@"Error launching app - Error: %@", error);
        }
    }
     ];

    NSLog(@"OPENING STREAM FOR WRITING DATA");
    _data = @"";
    
    //_stream = [[NSOutputStream alloc] initToFileAtPath:_path append:YES];
   // [_stream open];
    __block int i = 0;
    __block int counter = 0;
    
    // incoming watch messages are captured by this method
    [self.myWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"Received Message:%@", update);
        i++;
        
        if(i == 1) {
            // time stamp the beginning of file
            _receiveData.hidden = NO;
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MM-dd-yyyy 'at' hh:mm:ss"];
            
            NSDate* today = [NSDate date];
            NSString* dateString = [format stringFromDate:today];
            NSLog(@"DATE STRING: %@", dateString);
            dateString = [dateString stringByAppendingString:@"\n"];
            
            _data = dateString;
            
            NSData* date = [dateString dataUsingEncoding:NSUTF8StringEncoding];
           // [_stream write:date.bytes maxLength:date.length];
        }
        
        __block NSString *xyz = @"";
        NSString *temp = nil;
        
        for (id key in [[update allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            NSLog(@"key=%@ value=%@", key, [update objectForKey:key]);
            counter++;
            temp = [NSString stringWithFormat:@"%@,%d\n", [update objectForKey:key], counter];
            xyz = [xyz stringByAppendingString:temp];
        }
        
        //xyz = [xyz stringByAppendingString:@""];
        _data = [_data stringByAppendingString:xyz];
        NSLog(@"xyz: %@", xyz);
       // NSData *data = [xyz dataUsingEncoding:NSUTF8StringEncoding];
        //[_stream write:data.bytes maxLength: data.length];
        return YES;
    }];
}

- (IBAction)stopWatchApp:(id)sender {
    _firstName.hidden = NO;
    _receiveData.hidden = YES;
    _trial.hidden = NO;
    
    // time stamp end of file
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy 'at' hh:mm:ss"];
    
    NSDate* today = [NSDate date];
    NSString* dateString = [format stringFromDate:today];
    NSLog(@"DATE STRING: %@", dateString);
    dateString = [dateString stringByAppendingString:@"\n"];
    
    _data = [_data stringByAppendingString:dateString];
    [_data writeToFile:_path atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    NSData* date = [dateString dataUsingEncoding:NSUTF8StringEncoding];
    //[_stream write:date.bytes maxLength:date.length];

    //[_stream close];
    
    // close message communication and shut down watch app
    //[self.myWatch closeSession:nil];
    
    [self.myWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
        if(error) {
            NSLog(@"Error closing watchapp: %@", error);
        }
    }];
    
    NSLog(@"CLOSING STREAM FOR WRITING DATA");
    
    // prints out file
    NSFileManager *man = [NSFileManager defaultManager];
    NSData* returnData = [man contentsAtPath:_path];
   // NSString *strData = [[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
    //NSLog(@"ACCEL DATA: %@", strData);

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
