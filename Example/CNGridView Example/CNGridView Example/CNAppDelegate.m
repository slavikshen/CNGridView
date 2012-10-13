//
//  CNAppDelegate.m
//  CNGridView Example
//
//  Created by cocoa:naut on 12.10.12.
//  Copyright (c) 2012 cocoa:naut. All rights reserved.
//

#import "CNAppDelegate.h"
#import "CNGridViewItem.h"
#import "CNGridViewItemLayout.h"


static NSString *kContentTitleKey, *kContentImageKey;

@implementation CNAppDelegate

+ (void)initialize
{
    kContentTitleKey = @"itemTitle";
    kContentImageKey = @"itemImage";
}

- (id)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.itemSizeSlider.title = @"GridView Item Size";
    
    /// insert some content
    for (int i=0; i<30; i++) {
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameComputer], kContentImageKey,
                               NSImageNameComputer, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameBonjour], kContentImageKey,
                               NSImageNameBonjour, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameFolderBurnable], kContentImageKey,
                               NSImageNameFolderBurnable, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameNetwork], kContentImageKey,
                               NSImageNameNetwork, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameDotMac], kContentImageKey,
                               NSImageNameDotMac, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameUserAccounts], kContentImageKey,
                               NSImageNameUserAccounts, kContentTitleKey,
                               nil]];
        [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSImage imageNamed:NSImageNameFolderSmart], kContentImageKey,
                               NSImageNameFolderSmart, kContentTitleKey,
                               nil]];
    }

    self.gridView.itemSize = NSMakeSize(self.itemSizeSlider.integerValue, self.itemSizeSlider.integerValue);
    self.gridView.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.1];
    self.gridView.elasticity = NO;
    [self.gridView reloadData];
}

- (IBAction)itemSizeSliderAction:(id)sender
{
    self.gridView.itemSize = NSMakeSize(self.itemSizeSlider.integerValue, self.itemSizeSlider.integerValue);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CNGridView DataSource

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section
{
    static NSString *reuseIdentifier = @"CNGridViewItem";
    CNGridViewItem *item = [gridView dequeueReusableItemWithIdentifier:reuseIdentifier];

    if (item == nil) {
        item = [[CNGridViewItem alloc] initWithLayout:[CNGridViewItemLayout defaultLayout] reuseIdentifier:reuseIdentifier];
    }

    NSDictionary *contentDict = [self.items objectAtIndex:index];
    item.itemTitle = [contentDict objectForKey:kContentTitleKey];
    item.itemImage = [contentDict objectForKey:kContentImageKey];

    return item;
}

@end