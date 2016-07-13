//
//  DDDemoViewController.m
//  ScrollSegmentControlDemo
//
//  Created by daniel on 16/7/14.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DDDemoViewController.h"

@implementation DDDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.equalWidth) {
        self.items = @[@"首页",@"淘宝",@"一号店",@"京东猴子"];
        self.controllers = [self _randomViewControllerOfNumber:self.items.count];
        self.segmentControl.itemWidth = CGRectGetWidth([UIScreen mainScreen].bounds)/self.items.count;
    }
    else {
        self.items = @[@"首页",@"淘宝",@"一号店",@"京东猴子",@"当当",@"小红书", @"Amazon", @"Yotube"];
        self.controllers = [self _randomViewControllerOfNumber:self.items.count];
        [self setAutoSizeItems];
    }
}

- (NSArray *)_randomViewControllerOfNumber:(NSInteger)count {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        UIViewController *c = [UIViewController new];
        NSLog(@"%f", random()*.1 );
        c.view.backgroundColor = [UIColor colorWithRed:random()%10/10.f green:random()%10/10.f blue:random()%10/10.f alpha:1];
        [array addObject:c];
    }
    return array.copy;
}

@end
