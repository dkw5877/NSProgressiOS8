//
//  DownloadTaskOperation.m
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/11/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import "DownloadTaskOperation.h"
#import "AppDelegate.h"
#import "UploadTaskOperation.h"

static const NSUInteger unitCount = 2;

@interface DownloadTaskOperation ()
@property (nonatomic, strong) NSProgress* progress;
@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) BOOL executing;
@property (nonatomic, strong) NSOperationQueue* internalQueue;
@end


@implementation DownloadTaskOperation

@synthesize finished = _finished;
@synthesize executing = _executing;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.progress = [NSProgress progressWithTotalUnitCount:unitCount];
        self.internalQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}

- (void)start {
    

    NSLog(@"starting operation %@ with progress %@",self.name, self.progress);
    
    NSURLSession* session = [NSURLSession sharedSession];
//    NSString* urlString = @"https://www.dropbox.com/s/uxlu4qpxgtjcwh8/257H.jpg?dl=1"; //large file
    NSString* urlString = @"https://www.pexels.com/photo/night-fire-flame-fire-pit-21490/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.executing = YES;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        self.executing = NO;
        
        //update progress on main queue
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.progress.completedUnitCount++;
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self uploadData];
        NSLog(@"operation %@ completed",self.name);

        self.finished = YES;
    }];
    
    [downloadTask resume];
}

- (void)uploadData {
    //assume we did some processing with the downloaded data and now want to upload
    [self.progress becomeCurrentWithPendingUnitCount:1];
    UploadTaskOperation* upload = [[UploadTaskOperation alloc]init];
    upload.name = [NSString stringWithFormat:@"upload task for %@",self.name];
    [self.internalQueue addOperation:upload];
    [self.progress resignCurrent];
}

@end
