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
static NSString* const FinishedKey = @"isFinished";
static NSString* const ExecutingKey = @"isExecuting";

@interface DownloadTaskOperation ()
@property (nonatomic, strong) NSProgress* progress;
@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isExecuting) BOOL executing;
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
         //create serial queue so we can show progress of each task, this could be concurrent
        self.internalQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)start {
    
    NSLog(@"starting operation %@ with progress %@",self.name, self.progress);
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSString* urlString = @"https://www.dropbox.com/s/uxlu4qpxgtjcwh8/257H.jpg?dl=1"; //large file
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

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:ExecutingKey];
    _executing = executing;
    [self didChangeValueForKey:ExecutingKey];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:FinishedKey];
    _finished = finished;
    [self didChangeValueForKey:FinishedKey];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isAsynchronous {
    return YES;
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
