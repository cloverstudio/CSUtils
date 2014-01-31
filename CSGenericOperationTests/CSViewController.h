//
//  CSViewController.h
//  CSGenericOperationTests
//
//  Created by Josip Bernat on 31/01/14.
//  Copyright (c) 2014 Clover-Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *addOperationButton;
@property (nonatomic, weak) IBOutlet UITextView *textView;

#pragma mark - Button Selectors
- (IBAction)onAddOperation:(id)sender;

@end
