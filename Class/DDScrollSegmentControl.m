//
//  DDScrollSegmentControl.m
//  meizhuang
//
//  Created by Daniel on 16/7/12.
//  Copyright © 2016年 djs66256. All rights reserved.
//

#import "DDScrollSegmentControl.h"

@interface DDScrollSegmentControlTextCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *textLabel;
@property (copy, nonatomic) NSDictionary *textAttributes;
@property (copy, nonatomic) NSDictionary *selectedAttributes;
@property (copy, nonatomic) NSDictionary *highlightAttributes;
@end

@implementation DDScrollSegmentControlTextCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = frame.size}];;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted != highlighted) {
        [super setHighlighted:highlighted];
        [self _updateTextAttributes];
    }
}

- (void)setSelected:(BOOL)selected {
    if (self.selected != selected) {
        [super setSelected:selected];
        [self _updateTextAttributes];
    }
}

- (void)setText:(NSString *)text {
    self.textLabel.text = text;
    [self _updateTextAttributes];
}

- (void)_updateTextAttributes {
    if (self.highlighted && self.highlightAttributes) {
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:self.textLabel.text?:@"" attributes:self.highlightAttributes];
    }
    else if (self.selected && self.selectedAttributes) {
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:self.textLabel.text?:@"" attributes:self.selectedAttributes];
    }
    else {
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:self.textLabel.text?:@"" attributes:self.textAttributes];
    }
}

@end

@interface DDScrollSegmentControl () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation DDScrollSegmentControl

static NSString * const textCellIdentifier = @"text";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(60, 20);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = frame.size}
                                             collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.allowsMultipleSelection = NO;
        [_collectionView registerClass:DDScrollSegmentControlTextCollectionViewCell.class
            forCellWithReuseIdentifier:textCellIdentifier];
        [self addSubview:_collectionView];
        
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 2, 20, 2)];
        _underLineView.backgroundColor = [UIColor redColor];
        [self.collectionView addSubview:_underLineView];
        [self _updateUnderLineToIndex:_selectedIndex];
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex != selectedIndex && self.items.count > selectedIndex) {
        _selectedIndex = selectedIndex;
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]
                                          animated:YES
                                    scrollPosition:UICollectionViewScrollPositionNone];
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [self _updateUnderLineToIndex:selectedIndex];
            }];
        }
        else {
            [self _updateUnderLineToIndex:selectedIndex];
        }
    }
}

- (void)setItems:(NSArray<NSString *> *)items {
    if (_items != items) {
        _items = items.copy;
        [self.collectionView reloadData];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0]
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionNone];
        [self setNeedResizeItem];
    }
}

- (void)setItemInset:(UIEdgeInsets)itemInset {
    _itemInset = itemInset;
    
    [self setNeedResizeItem];
}

- (void)setItemWidth:(CGFloat)itemWidth {
    if (itemWidth != _itemWidth) {
        _itemWidth = itemWidth;
        if (_widthForItemHandler == NULL) {
            [self setNeedResizeItem];
        }
    }
}

- (void)setWidthForItemHandler:(CGFloat (^)(DDScrollSegmentControl *, NSString *))widthForItemHandler {
    _widthForItemHandler = [widthForItemHandler copy];
    [self setNeedResizeItem];
}

- (void)setNeedResizeItem {
    if (!_needResizeItem) {
        _needResizeItem = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _resizeItems];
            _needResizeItem = NO;
        });
    }
}

- (void)forwardToIndex:(NSInteger)index withProgress:(double)progress {
    if (index >= 0 && index < self.items.count && progress > 0 && progress < 1) {
        [self _updateUnderLineToIndex:index withProgress:progress];
    }
    else {
        
    }
}

- (void)_resizeItems {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(_itemInset.top, 0, _itemInset.bottom, 0);
    [layout invalidateLayout];
    
    // UI layout will be next runloop
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updateUnderLineToIndex:_selectedIndex];
    });
}

- (void)_updateUnderLineToIndex:(NSInteger)selectedIndex {
    [self _updateUnderLineToIndex:selectedIndex withProgress:1];
}

- (void)_updateUnderLineToIndex:(NSInteger)index withProgress:(double)progress {
    if (index < self.items.count) {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
        CGRect selectedRect = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:selectedIndexPath].frame;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        CGRect rect = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
        _underLineView.frame = CGRectMake(selectedRect.origin.x + (rect.origin.x - selectedRect.origin.x) * progress,
                                          rect.origin.y + rect.size.height,
                                          selectedRect.size.width + (rect.size.width - selectedRect.size.width) * progress,
                                          2);
        [self.collectionView scrollRectToVisible:_underLineView.frame animated:YES];
    }
}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDScrollSegmentControlTextCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:textCellIdentifier
                                                                                                   forIndexPath:indexPath];
    cell.highlightAttributes = self.highlightAttributes;
    cell.textAttributes = self.textAttributes;
    cell.selectedAttributes = self.selectedAttributes;
    cell.text = self.items[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item != _selectedIndex) {
        [self setSelectedIndex:indexPath.item animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = 0;
    if (_widthForItemHandler == NULL) {
        width = _itemWidth;
    }
    else {
        width = _widthForItemHandler(self, self.items[indexPath.item]) + _itemInset.left + _itemInset.right;
    }
    
    return CGSizeMake(width, CGRectGetHeight(collectionView.frame) - _itemInset.top - _itemInset.bottom);
}

@end
