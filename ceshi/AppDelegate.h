//
//  AppDelegate.h
//  ceshi
//
//  Created by loary on 16/12/19.
//  Copyright © 2016年 loary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundSessionCompletionHandler)();

@end

