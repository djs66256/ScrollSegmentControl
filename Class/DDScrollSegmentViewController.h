//
//  DDTestViewController.h
//  meizhuang
//
//  Created by Daniel on 16/7/12.
//  Copyright © 2016年 djs66256. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDScrollSegmentControl.h"

@class DDScrollSegmentControl;
@interface DDScrollSegmentViewController : UIViewController

@property (strong, nonatomic) NSArray<NSString *> *items;
@property (strong, nonatomic) NSArray<UIViewController *> *controllers;
@property (readonly, nonatomic) UIViewController *currentViewController;

@property (readonly, strong, nonatomic) UIScrollView *scrollView;
@property (readonly, strong, nonatomic) DDScrollSegmentControl *segmentControl;

- (void)setAutoSizeItems;

@end
