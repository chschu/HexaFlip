//
//  JCSRadioMenu.m
//  HexaFlip
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
    if (_block != nil) {
        _block(sender);
    }
}

@end

@implementation JCSRadioMenu {
    CCMenuItem *_highlightedItem;
    
    // the ivar selectedItem_ of CCMenu is used to hold the currently selected menu item
    // the ivar state_ of CCMenu is used to hold the menu's state ("waiting" or "tracking touch")
}

- (void)setSelectedItem:(CCMenuItem *)item {
    if (_selectedItem != item) {
        // mark the currently selected item as "unselected" if it is not the highlighted item
        if (!_allSelectedMode && _selectedItem != _highlightedItem) {
            [_selectedItem unselected];
        }
        
        // update the selected item
        _selectedItem = item;

        // mark the newly selected item as "selected" if it is not the highlighted item
        if (!_allSelectedMode && _selectedItem != _highlightedItem) {
            [_selectedItem selected];
        }
        
        // trigger the item's block
        // cannot use -activate here, because this resizes CCMenuItemLabel back to normal
        [_selectedItem invokeBlock:_selectedItem];
    }
}

- (CCMenuItem *)selectedItem {
    return _selectedItem;
}

- (void)setAllSelectedMode:(BOOL)allSelectedMode {
    _allSelectedMode = allSelectedMode;
    if (_allSelectedMode) {
        // select all items
        for (CCMenuItem *item in _children) {
            if (!item.isSelected) {
                [item selected];
            }
        }
    } else {
        // unselect all items except selected and highlighted item
        for (CCMenuItem *item in _children) {
            if (item.isSelected && item != _selectedItem && item != _highlightedItem) {
                [item unselected];
            }
        }
    }
}

- (void)setHighlightedItem:(CCMenuItem *)item {
    if (_highlightedItem != item) {
        // mark the currently highlighted item as "unselected" if it is not the selected item
        if (!_allSelectedMode && _highlightedItem != _selectedItem) {
            [_highlightedItem unselected];
        }
        
        // update the highlighted item
        _highlightedItem = item;
        
        // mark the newly highlighted item as "selected" if it is not the selected item
        if (!_allSelectedMode && _highlightedItem != _selectedItem) {
            [_highlightedItem selected];
        }
    }
}

- (CCMenuItem *)highlightedItem {
    return _highlightedItem;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_state == kCCMenuStateWaiting && !_allSelectedMode && _visible && _enabled) {
        CCMenuItem *touchItem = [self itemForTouch:touch];
        if (touchItem != nil) {
            self.highlightedItem = touchItem;
            _state = kCCMenuStateTrackingTouch;
            return YES;
        }
    }
    
    return NO;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
    
    self.highlightedItem = nil;
    
    CCMenuItem *touchItem = [self itemForTouch:touch];
    if (touchItem != nil) {
        self.selectedItem = touchItem;
    }
    
    _state = kCCMenuStateWaiting;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
    
    self.highlightedItem = nil;
    
	_state = kCCMenuStateWaiting;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	self.highlightedItem = [self itemForTouch:touch];
}

- (CCMenuItem *)itemForTouch:(UITouch *)touch {
	CGPoint touchLocation = [touch locationInView:[touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    for (CCMenuItem *item in _children) {
		if (item.visible && item.isEnabled) {
			CGPoint local = [item convertToNodeSpace:touchLocation];
			CGRect r = [item activeArea];
			r.origin = CGPointZero;
			if (CGRectContainsPoint(r, local)) {
				return item;
            }
		}
	}
    
	return nil;
}

@end
