//
//  ViewController.m
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/10/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import "ViewController.h"
#import "ParentProgressOperation.h"
#import "DownloadTaskOperation.h"


@interface ViewController ()
@property (nonatomic, strong) UIProgressView* progressBar;
@property (nonatomic, strong) UILabel* progressLabel;
@property (nonatomic, strong) UILabel* progressDescriptionLabel;
@property (nonatomic, strong) NSProgress* progress;
@property (nonatomic, strong) NSOperationQueue* progressQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUIElements];
}

- (void)viewDidAppear:(BOOL)animated {
 
}

- (void)setupUIElements {
    self.progressBar = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressBar.progressTintColor = [UIColor greenColor];
    self.progressBar.backgroundColor = [UIColor grayColor];
    CGRect frame = self.progressBar.frame;
    frame.origin.y += 100;
    frame.size.width = self.view.bounds.size.width - 20;
    self.progressBar.frame = frame;
    self.progressBar.progress = 0.f;
    [self.view addSubview:self.progressBar];
    
    self.progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMidY(self.view.frame)-100, self.view.bounds.size.width - 20, 100)];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.backgroundColor = [UIColor blueColor];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.text = [NSString stringWithFormat:@"%lld",self.progress.completedUnitCount];
    [self.view addSubview:self.progressLabel];
    
    self.progressDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMidY(self.view.frame), self.view.bounds.size.width - 20, 100)];
    self.progressDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.progressDescriptionLabel.backgroundColor = [UIColor greenColor];
    self.progressDescriptionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.progressDescriptionLabel];
    
    UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)- 50, CGRectGetMidY(self.view.frame)+ 150, 100, 50)];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)start:(id)sender {
    [self launchChildOperations];
}


- (void)launchChildOperations {

    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        ParentProgressOperation* start = [[ParentProgressOperation alloc]init];
        self.progress = start.progress;
        NSLog(@"progress %@", start.progress);
        [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionInitial context:NULL];
        [self.progressQueue addOperation:start];
    }];
    
    self.progressQueue = [[NSOperationQueue alloc]init];
    self.progressQueue.name = @"Progress Queue";
    [self.progressQueue addOperation:op];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (_progress == object) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSProgress *progress = object;
            self.progressBar.progress = progress.fractionCompleted;
            self.progressLabel.text = progress.localizedDescription;
            self.progressDescriptionLabel.text = progress.localizedAdditionalDescription;
        }];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)launchChildProccesses {
    NSLog(@"starting operation parent progress");
    self.progress = [NSProgress progressWithTotalUnitCount:2];
    self.progress.kind = NSProgressKindFile;
    [self.progress addObserver:self forKeyPath:@"fractionCompleted"
                       options:NSKeyValueObservingOptionInitial
                       context:NULL];
    [self.progress becomeCurrentWithPendingUnitCount:1];
    [self createNSURLRequest];
    [self createNSURLRequest];
    [self.progress resignCurrent];
}

- (void)createNSURLRequest {
    
    NSLog(@"createSingleProgressTask");
    //create a unit of work
    NSProgress* progress = [NSProgress progressWithTotalUnitCount:1];
    
    //establish parent-child relationship
    progress = [progress initWithParent:self.progress userInfo:nil];
    

    NSURLSession* session = [NSURLSession sharedSession];
    //    NSString* urlString = @"http://freelargephotos.com/photos/002310/large.jpg";
    NSString* urlString = @"https://www.dropbox.com/s/uxlu4qpxgtjcwh8/257H.jpg?dl=1";
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"loading image from url");
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        self.progress.completedUnitCount++;
        NSLog(@"location %@", location);
        NSLog(@"response %@", response);
        NSLog(@"error %@", error.localizedDescription);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [downloadTask resume];
}

- (void)dealloc {
    [_progress removeObserver:self forKeyPath:@"fractionCompleted"];
}

@end
