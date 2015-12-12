//
//  ParentProgressOperation.h
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/11/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParentProgressOperation : NSOperation
/* we need a public property so the UI can observe the progress */
@property (nonatomic, strong, readonly) NSProgress* progress;
@end
