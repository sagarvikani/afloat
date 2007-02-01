//
//  AfloatCocoaWindowTracking.h
//  AfloatAgent
//
//  Created by ∞ on 19/01/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AfloatCocoaWindowTracking : NSObject {
    BOOL isTracking;
    NSTrackingRectTag trackingRectTag;
    id trackingOwner;
    NSWindow* trackedWindow;
}

- (id) initForWindow:(NSWindow*) wnd owner:(id) owner;

// private
- (void) _beginTracking;
- (void) _endTracking;

@end
