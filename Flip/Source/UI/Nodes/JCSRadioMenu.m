//
//  JCSRadioMenu.m
//  Flip
//
//  Created by Christian Schuster on 24.11.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSRadioMenu.h"

@interface JCSRadioMenu ()

// private property containing the currently highlighted (tentatively selected) item
@property (nonatomic) CCMenuItem *highlightedItem;

@end

// category to access the menu items block without triggering any UI changes
@interface CCMenuItem (InvokeBlock)

- (void)invokeBlock:(id)sender;

@end

@implementation CCMenuItem (InvokeBlock)

- (void)invokeBlock:(id)sender {
    block_(sender);
}

@end

@implementation JCSRadioMenu {
    CCMenuItem *_highlightedItem;
    
    // the ivar selectedItem_ of CCMenu is used to hold the currently selected menu item
    // the ivar state_ of CCMenu is used to hold the menu's state ("waiting" or "tracking touch")
}

- (void)setSelectedItem:(CCMenuItem *)item {
    if (selectedItem_ != item) {
        // mark the currently selected item as "unselected" if it is not the highlighted item
        if (selectedItem_ != _highlightedItem) {
            [selectedItem_ unselected];
        }
        
        // update the selected item
        selectedItem_ = item;

        // mark the newly selected item as "selected" if it is not the highlighted item
        if (selectedItem_ != _highlightedItem) {
            [selectedItem_ selected];
        }
        
        // trigger the item's block
        // cannot use -activate here, because this resizes CCMenuItemLabel back to normal
        [selectedItem_ invokeBlock:selectedItem_];
    }
}

- (CCMenuItem *)selectedItem {
    return selectedItem_;
}

- (void)setHighlightedItem:(CCMenuItem *)item {
    if (_highlightedItem != item) {
        // mark the currently highlighted item as "unselected" if it is not the selected item
        if (_highlightedItem != selectedItem_) {
            [_highlightedItem unselected];
        }
        
        // update the highlighted item
        _highlightedItem = item;
        
        // mark the newly highlighted item as "selected" if it is not the selected item
        if (_highlightedItem != selectedItem_) {
            [_highlightedItem selected];
        }
    }
}

- (CCMenuItem *)highlightedItem {
    return _highlightedItem;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (state_ == kCCMenuStateWaiting && visible_ && enabled_) {
        CCMenuItem *touchItem = [self itemForTouch:touch];
        if (touchItem != nil) {
            self.highlightedItem = touchItem;
            state_ = kCCMenuStateTrackingTouch;
            return YES;
        }
    }
    
    return NO;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
    
    self.highlightedItem = nil;
    
    CCMenuItem *touchItem = [self itemForTouch:touch];
    if (touchItem != nil) {
        self.selectedItem = touchItem;
    }
    
    state_ = kCCMenuStateWaiting;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
    
    self.highlightedItem = nil;
    
	state_ = kCCMenuStateWaiting;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	self.highlightedItem = [self itemForTouch:touch];
}

- (CCMenuItem *)itemForTouch:(UITouch *)touch {
	CGPoint touchLocation = [touch locationInView:[touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    for (CCMenuItem *item in children_) {
		if (item.visible && item.isEnabled) {
			CGPoint local = [item convertToNodeSpace:touchLocation];
			CGRect r = [item rect];
			r.origin = CGPointZero;
			if (CGRectContainsPoint(r, local)) {
				return item;
            }
		}
	}
    
	return nil;
}

@end
