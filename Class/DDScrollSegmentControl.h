//
//  DDScrollSegmentControl.h
//  meizhuang
//
//  Created by Daniel on 16/7/12.
//  Copyright © 2016年 djs66256. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDScrollSegmentControl : UIControl {
    BOOL _needResizeItem;
}

//@property (assign, nonatomic) BOOL scrollEnable;    // If NO, there is one page. If not set sizeForItemHandler, the items have the same width
@property (assign, nonatomic) CGFloat itemWidth;    // If not set sizeForItemHandler, will use this
@property (assign, nonatomic) UIEdgeInsets itemInset;
@property (copy, nonatomic) CGFloat (^widthForItemHandler)(DDScrollSegmentControl *segmentControl, NSString *item);

@property (copy, nonatomic) NSArray<NSString *> *items;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (copy, nonatomic) NSDictionary *textAttributes;
@property (copy, nonatomic) NSDictionary *highlightAttributes;
@property (copy, nonatomic) NSDictionary *selectedAttributes;
@property (strong, nonatomic) UIColor *underLineColor;
@property (readonly, strong, nonatomic) UIView *underLineView;

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

- (void)forwardToIndex:(NSInteger)index withProgress:(double)progress;

@end
