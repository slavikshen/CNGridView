//
//  CNGridViewItem.m
//
//  Created by cocoa:naut on 06.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2012 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CNGridViewItem.h"
#import "NSColor+CNGridViewPalette.h"
#import "CNGridViewItemLayout.h"


#if !__has_feature(objc_arc)
#error "Please use ARC for compiling this file."
#endif


NSString* const kCNDefaultItemIdentifier = @"CNGridViewItem";

/// Notifications
extern NSString *CNGridViewSelectAllItemsNotification;
extern NSString *CNGridViewDeSelectAllItemsNotification;

@implementation CNGridViewItemBase


+ (CGSize)defaultItemSize
{
    return NSMakeSize(310, 225);
}


-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:CNGridViewSelectAllItemsNotification object:nil];
    [nc removeObserver:self name:CNGridViewDeSelectAllItemsNotification object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}


- (void)initProperties
{
    /// Reusing Grid View Items
    self.reuseIdentifier = kCNDefaultItemIdentifier;
    self.index = CNItemIndexUndefined;

//    /// Selection and Hovering
//    _selected = NO;
//    _selectable = YES;
//    _hovered = NO;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(selectAll:) name:CNGridViewSelectAllItemsNotification object:nil];
    [nc addObserver:self selector:@selector(deSelectAll:) name:CNGridViewDeSelectAllItemsNotification object:nil];
}

- (void)prepareForReuse {
    self.index = CNItemIndexUndefined;
    self.selected = NO;
    self.selectable = YES;
    self.hovered = NO;
}


- (BOOL)isReuseable
{
    return ( self.selected ? NO : YES);
}


- (void)selectAll:(NSNotification *)notification
{
    [self setSelected:YES];
}

- (void)deSelectAll:(NSNotification *)notification
{
    [self setSelected:NO];
}


@end


@interface CNGridViewItem ()
@property (strong) NSImageView *itemImageView;
@property (strong) CNGridViewItemLayout *currentLayout;
@end

@implementation CNGridViewItem

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialzation


- (id)initWithLayout:(CNGridViewItemLayout *)layout reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self init];
    if (self) {
        _defaultLayout = layout;
        _currentLayout = _defaultLayout;
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)initProperties
{
    [super initProperties];

    /// Item Default Content
    _itemImage = nil;
    _itemTitle = @"";
    /// Grid View Item Layout
    _defaultLayout = [CNGridViewItemLayout defaultLayout];
    _hoverLayout = [CNGridViewItemLayout defaultLayout];
    _selectionLayout = [CNGridViewItemLayout defaultLayout];
    _currentLayout = _defaultLayout;
    _useLayout = YES;

}

- (BOOL)isFlipped
{
    return YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reusing Grid View Items

- (void)prepareForReuse
{

    [super prepareForReuse];
    
    self.itemImage = nil;
    self.itemTitle = @"";

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - ViewDrawing

- (void)drawRect:(NSRect)rect
{
    NSRect dirtyRect = self.bounds;

    // decide which layout we have to use
    /// contentRect is the rect respecting the value of layout.contentInset
    NSRect contentRect = NSMakeRect(dirtyRect.origin.x + self.currentLayout.contentInset,
                                    dirtyRect.origin.y + self.currentLayout.contentInset,
                                    dirtyRect.size.width - self.currentLayout.contentInset * 2,
                                    dirtyRect.size.height - self.currentLayout.contentInset * 2);

    NSBezierPath *contentRectPath = [NSBezierPath bezierPathWithRoundedRect:contentRect
                                                                    xRadius:self.currentLayout.itemBorderRadius
                                                                    yRadius:self.currentLayout.itemBorderRadius];
    [self.currentLayout.backgroundColor setFill];
    [contentRectPath fill];

    /// draw selection ring
    if (self.selected) {
        [self.currentLayout.selectionRingColor setStroke];
        [contentRectPath setLineWidth:self.currentLayout.selectionRingLineWidth];
        [contentRectPath stroke];
    }


    NSRect srcRect = NSZeroRect;
    srcRect.size = self.itemImage.size;
    NSRect imageRect = NSZeroRect;
    NSRect textRect = NSZeroRect;

    if (self.currentLayout.visibleContentMask & (CNGridViewItemVisibleContentImage | CNGridViewItemVisibleContentTitle)) {
        imageRect = NSMakeRect(((NSWidth(contentRect) - self.itemImage.size.width) / 2) + self.currentLayout.contentInset,
                               self.currentLayout.contentInset + 10,
                               self.itemImage.size.width,
                               self.itemImage.size.height);
        [self.itemImage drawInRect:imageRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];

        textRect = NSMakeRect(contentRect.origin.x + 3,
                              NSHeight(contentRect) - 20,
                              NSWidth(contentRect) - 6,
                              14);
        [self.itemTitle drawInRect:textRect withAttributes:self.currentLayout.itemTitleTextAttributes];
    }

    else if (self.currentLayout.visibleContentMask & CNGridViewItemVisibleContentImage) {
        imageRect = NSMakeRect(((NSWidth(contentRect) - self.itemImage.size.width) / 2) + self.currentLayout.contentInset,
                               ((NSHeight(contentRect) - self.itemImage.size.height) / 2) + self.currentLayout.contentInset,
                               self.itemImage.size.width,
                               self.itemImage.size.height);
    }

    else if (self.currentLayout.visibleContentMask & CNGridViewItemVisibleContentTitle) {
    }

}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications

- (void)clearHovering
{
    [self setHovered:NO];
}

- (void)clearSelection
{
    [self setSelected:NO];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessors

- (void)setHovered:(BOOL)hovered
{
    [super setHovered:hovered];
    _currentLayout = (self.hovered ? _hoverLayout : (self.selected ? _selectionLayout : _defaultLayout));
    [self setNeedsDisplay:YES];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _currentLayout = (self.selected ? _selectionLayout : _defaultLayout);
    [self setNeedsDisplay:YES];
}

- (void)setDefaultLayout:(CNGridViewItemLayout *)defaultLayout
{
    _defaultLayout = defaultLayout;
    self.currentLayout = _defaultLayout;
}

@end
