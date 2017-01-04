//
//  ViewController.h
//  ceshi
//
//  Created by loary on 16/12/19.
//  Copyright © 2016年 loary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)start:(id)sender;
- (IBAction)zanting:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)cancelResume:(id)sender;
- (IBAction)resumeStart:(id)sender;

@end

