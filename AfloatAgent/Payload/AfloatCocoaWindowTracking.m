//
//  AfloatCocoaWindowTracking.m
//  AfloatAgent
//
//  Created by ∞ on 19/01/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AfloatCocoaWindowTracking.h"


@implementation AfloatCocoaWindowTracking

- (id) initForWindow:(NSWindow*) wnd owner:(id) owner {
    if (self = [super init]) {
        isTracking = NO;
        trackingOwner = owner;
        trackedWindow = wnd;
        [self _beginTracking];
    }
    
    return self;
}

- (void) _beginTracking {
    [self _endTracking];
    NSView* windowView = [[trackedWindow contentView] superview];
    NSRect frame = [windowView frame];
    
    trackingRectTag = [windowView addTrackingRect:frame owner:trackingOwner userData:self assumeInside:NSPointInRect([NSEvent mouseLocation], frame)];    
    isTracking = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowViewDidChangeBounds:) name:NSViewBoundsDidChangeNotification object:windowView];
}

- (void) _endTracking {
    if (!isTracking) return;
    NSView* windowView = [[trackedWindow contentView] superview];
    
    [windowView removeTrackingRect:trackingRectTag];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) _windowViewDidChangeBounds:(NSNotification*) notif {
    [self _beginTracking];
}

- (void) dealloc {
    [self _endTracking];
    [super dealloc];
}

@end
