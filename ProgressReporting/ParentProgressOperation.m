//
//  ParentProgressOperation.m
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/11/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import "ParentProgressOperation.h"
#import "DownloadTaskOperation.h"

static const NSUInteger unitCount = 3;
@interface ParentProgressOperation()
@property (nonatomic, strong, readwrite) NSProgress* progress;
@property (nonatomic, strong) NSOperationQueue* internalQueue;
@end

@implementation ParentProgressOperation
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
    
    NSLog(@"starting parent operation");
    NSLog(@"progress %@", self.progress);
    [self.progress setUserInfoObject:NSProgressFileOperationKindDownloading forKey:NSProgressFileOperationKindKey];
    
    /* create several download operations, each operation is one unit of work */
    for (NSUInteger i = 0; i < unitCount; i++) {
        [self.progress becomeCurrentWithPendingUnitCount:1];
        DownloadTaskOperation* op = [[DownloadTaskOperation alloc]init];
        op.name = [NSString stringWithFormat:@"download task %lu",(unsigned long)i];
        [self.internalQueue addOperation:op];
        [self.progress resignCurrent];
    }
}

@end
