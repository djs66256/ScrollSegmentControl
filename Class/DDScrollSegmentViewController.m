//
//  DDTestViewController.m
//  meizhuang
//
//  Created by Daniel on 16/7/12.
//  Copyright © 2016年 djs66256. All rights reserved.
//
//#import "DDRouter.h"
//#import "DDApplication.h"
#import "DDScrollSegmentViewController.h"
#import "DDScrollSegmentControl.h"

@interface DDScrollSegmentViewController () <UIScrollViewDelegate> {
    BOOL _dragging;
    
    struct TransitionIndexes {
        NSInteger from;
        NSInteger to;
    } transitionIndexes;
}

@end

@implementation DDScrollSegmentViewController

- (void)loadView {
    [super loadView];
    
    DDScrollSegmentControl *control = [DDScrollSegmentControl new];
    control.itemInset = UIEdgeInsetsMake(5, 10, 2, 10);
    control.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30);
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:control];
    _segmentControl = control;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-30)];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _segmentControl.highlightAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor],
                                    NSFontAttributeName: [UIFont systemFontOfSize:18]};
    _segmentControl.selectedAttributes = @{NSForegroundColorAttributeName: [UIColor redColor],
                                   NSFontAttributeName: [UIFont systemFontOfSize:16]};
    _segmentControl.textAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    _segmentControl.items = self.items;
    [_segmentControl addTarget:self
                        action:@selector(segmentControlValueChanged:)
              forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * self.items.count, CGRectGetHeight(_scrollView.frame));
    for (int i = 0; i < _controllers.count; i++) {
        _controllers[i].view.frame = CGRectMake(i*CGRectGetWidth(_scrollView.frame),
                                                0,
                                                CGRectGetWidth(_scrollView.frame),
                                                CGRectGetHeight(_scrollView.frame));
    }
}

- (void)setAutoSizeItems {
    _segmentControl.widthForItemHandler = ^CGFloat(DDScrollSegmentControl *segmentControl, NSString *item) {
        CGRect rect = [item boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(segmentControl.frame))
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics
                                      attributes:segmentControl.selectedAttributes
                                         context:NULL];
        return rect.size.width + 2;
    };
}

- (UIViewController *)currentViewController {
    if (self.controllers.count > _segmentControl.selectedIndex) {
        return self.controllers[_segmentControl.selectedIndex];
    }
    return nil;
}

- (void)setItems:(NSArray *)items {
    _items = items;
    _segmentControl.items = items;
}

- (void)setControllers:(NSArray<UIViewController *> *)controllers {
    if (_controllers) {
        for (UIViewController *controller in _controllers) {
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
    }
    _controllers = controllers;
    for (int i = 0; i < controllers.count; i++) {
        [self addChildViewController:controllers[i]];
        [_scrollView addSubview:controllers[i].view];
    }
}

- (void)segmentControlValueChanged:(DDScrollSegmentControl *)sender {
    [self _updateScrollViewToIndex:sender.selectedIndex animated:YES];
}

- (void)_beginTransitionFromIndex:(NSInteger)from toIndex:(NSInteger)to animated:(BOOL)animated {
    UIViewController *fromController = _controllers[from];
    UIViewController *toController = _controllers[to];
    [fromController beginAppearanceTransition:NO animated:animated];
    [toController beginAppearanceTransition:YES animated:animated];
    
    transitionIndexes.from = from;
    transitionIndexes.to = to;
}

- (void)_endTransitionFromIndex:(NSInteger)from toIndex:(NSInteger)to {
    UIViewController *fromController = _controllers[from];
    UIViewController *toController = _controllers[to];
    [fromController endAppearanceTransition];
    [toController endAppearanceTransition];
}

- (void)_updateScrollViewToIndex:(NSInteger)to animated:(BOOL)animated {
    int from = (int)round(_scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame));
    [self _beginTransitionFromIndex:from toIndex:to animated:animated];
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_scrollView.frame) * to, 0) animated:animated];
    if (!animated) {
        [self _endTransitionFromIndex:from toIndex:to];
    }
}

- (void)_updateSegmentControlSelectedIndexAnimated:(BOOL)animated {
    NSInteger to = (int)round(_scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame));
    NSInteger from = _segmentControl.selectedIndex;
    [_segmentControl setSelectedIndex:to animated:NO];
    [self _endTransitionFromIndex:from toIndex:to];
}

#pragma mark - UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _dragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging || scrollView.isDecelerating) {
        CGFloat offset = scrollView.contentOffset.x - _segmentControl.selectedIndex * CGRectGetWidth(scrollView.frame);
        NSInteger indexDelta = ceil(fabs(offset/CGRectGetWidth(scrollView.frame)));
        if (indexDelta == 0) return ;
        NSInteger index = offset > 0 ? _segmentControl.selectedIndex + indexDelta : _segmentControl.selectedIndex - indexDelta;
        double progress = fabs(offset) / CGRectGetWidth(scrollView.frame) / indexDelta;
        
        if (index >= 0 && index < self.items.count) {
            [self _beginTransitionFromIndex:_segmentControl.selectedIndex toIndex:index animated:YES];
            [_segmentControl forwardToIndex:index withProgress:progress];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if (scrollView.isDragging) {
        [self _updateSegmentControlSelectedIndexAnimated:NO];
        _dragging = NO;
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self _updateSegmentControlSelectedIndexAnimated:YES];
        _dragging = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self _endTransitionFromIndex:transitionIndexes.from toIndex:transitionIndexes.to];
}

@end
