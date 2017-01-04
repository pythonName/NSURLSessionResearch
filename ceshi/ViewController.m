//
//  ViewController.m
//  ceshi
//
//  Created by loary on 16/12/19.
//  Copyright © 2016年 loary. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSData *resData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.session = [self backgroundSession];
    //self.session = [self normalSession];
    self.progressView.progress = 0;
   // [self performSelector:@selector(kik) withObject:nil afterDelay:10];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appWillTerminate)
//                                                 name:UIApplicationWillTerminateNotification
//                                               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appbg)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
}

- (void)appbg {
    NSLog(@"appbg-------");
    [self cancelResume:nil];
}

//- (void)dealloc {
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)kik {
    NSArray *a = @[@"dfdf"];
    NSString *pp = a[3];
}

//- (void)appWillTerminate {//捕获不准确，不可用
//    NSLog(@"appWillTerminate------");
//}

//- (NSURLSession *)normalSession {
//    static NSURLSession *session = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
//    });
//    return session;
//}

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration;
        if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
        }else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
        }
        
        
        /*allowsCellularAccess 属性指定是否允许使用蜂窝连接， discretionary属性为YES时表示当程序在后台运作时由系统自己选择最佳的网络连接配置，该属性可以节省通过蜂窝连接的带宽。在使用后台传输数据的时候，建议使用discretionary属性，而不是allowsCellularAccess属性，因为它会把WiFi和电源可用性考虑在内。补充：这个标志允许系统为分配任务进行性能优化。这意味着只有当设备有足够电量时，设备才通过Wifi进行数据传输。如果电量低，或者只仅有一个蜂窝连接，传输任务是不会运行的。后台传输总是在discretionary模式下运行
         */
        configuration.discretionary = YES;//////

        
        /*参数说明delegateQueue
         当传nil 或 新建一个queue对象时，session的回调方法会在子线程调用，但不是每次的回调都在同一个子线程，测试时发现有两个子线程的回调
         当传main queue时，表示回调方法会在主线程执行*/
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}

- (void)releaseOperation {
//    [self.session invalidateAndCancel];
//    self.session = nil;
}

- (IBAction)start:(id)sender {
    if (self.downloadTask) {
        return;
    }//
    NSURL *downloadURL = [NSURL URLWithString:@"http://cdn.ios.dl.apiappvv.com/74feebfedc6d265476c17f69177120a9a0029ab8.ipa"];//http://dl.moviebox.appvv.com/cc922c040cfd68bf9a99697c769ef521b1f8651c.ipa
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
//    self.dataTask = [self.session dataTaskWithRequest:request];
//    [self.dataTask resume];
    //[self performSelector:@selector(kik) withObject:nil afterDelay:10];
}

- (IBAction)zanting:(id)sender {
    //[self.downloadTask suspend]; //所谓的暂停 还是不要用这个suspend  还是用cancelByProducingResumeData这个方法 拿到resumeData  方便后续断点传输
    //[self cancelResume:sender];
}

- (IBAction)restart:(id)sender {
    //[self.downloadTask resume];
    //[self resumeStart:sender];
}

- (IBAction)cancelResume:(id)sender {
    __weak __typeof(self)weakSelf = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        //在子线程该block
//        NSString *rr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
//        NSLog(@"queueueCCCCCC=-----currentThread %@,,, main thread: %@",[NSThread currentThread],[NSThread mainThread]);
        NSError *error;
        NSPropertyListFormat format;
        NSMutableDictionary *rr = (NSMutableDictionary *)[NSPropertyListSerialization propertyListWithData:resumeData options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
        
        NSLog(@"rr = %@",rr);
        NSURLRequest *originRequest = [NSKeyedUnarchiver unarchiveObjectWithData:[rr objectForKey:@"NSURLSessionResumeOriginalRequest"]];
        NSLog(@"ori = %@",originRequest);
        NSLog(@"ori header = %@",originRequest.allHTTPHeaderFields);
        
        NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:[rr objectForKey:@"NSURLSessionResumeCurrentRequest"]];
        NSLog(@"current = %@",currentRequest);
        NSLog(@"current header = %@",currentRequest.allHTTPHeaderFields);
        //weakSelf.resData = resumeData;
        
        [rr removeObjectForKey:@"NSURLSessionResumeEntityTag"];
        weakSelf.resData = [NSPropertyListSerialization
                            dataWithPropertyList:rr format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
        
//        NSMutableURLRequest *newc = [currentRequest mutableCopy];
//        [newc setValue:@"" forHTTPHeaderField:@"If-Range"];
//        
//        [rr setObject:newc forKey:@"NSURLSessionResumeCurrentRequest"];
//        
//        
//        NSData *da = [NSPropertyListSerialization
//                            dataWithPropertyList:rr format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
//        weakSelf.resData = [[NSData alloc] initWithData:da];
        //cancel之时拷贝文件到安全目录
//        NSError *copyFileError = nil;
//        NSString *oriFilePath = [rr objectForKey:@"NSURLSessionResumeInfoLocalPath"];
//        NSString *destinationFilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),[oriFilePath lastPathComponent]];
//        [[NSFileManager defaultManager] copyItemAtPath:oriFilePath toPath:destinationFilePath error:&copyFileError];
//        if (nil == copyFileError) {
//            NSString *resumeDataCacheFilePath = [NSString stringWithFormat:@"%@/Documents/%@.cache", NSHomeDirectory(),[oriFilePath lastPathComponent]];
//            [resumeData writeToFile:resumeDataCacheFilePath atomically:YES];
//        }else {
//            NSLog(@"cancel之时拷贝文件失败：%@",copyFileError);
//        }
        
        NSLog(@"cancel之时拷贝文件失败");
    }];
}

- (IBAction)resumeStart:(id)sender {
    
    NSError *error;
    NSPropertyListFormat format;
    NSMutableDictionary *rr = (NSMutableDictionary *)[NSPropertyListSerialization propertyListWithData:self.resData options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    
    NSLog(@"rr = %@",rr);
    
    
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resData];
    [self.downloadTask resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession------1111-------");
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"All tasks are finished");
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
    
    self.downloadTask = nil;
    [self releaseOperation];
}

#pragma mark - NSURLSessionDownloadDelegate回调
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
//    NSLog(@"queueue=-----currentThread %@,,, main thread: %@",[NSThread currentThread],[NSThread mainThread]);2098888
    if (downloadTask == self.downloadTask) {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    NSLog(@"didFinishDownloadingToURL---------");
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        
    } else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
    [self releaseOperation];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"9090------didResumeAtOffset = %lld --- expectedTotalBytes = %lld---",fileOffset,expectedTotalBytes);
}
@end
