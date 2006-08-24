/*
** L0AfloatWindowMover.m
** 
** 
**   This source file is part of Afloat and is
** subject to the terms of a (BSD) license.
** 
** Copyright © 2006, Emanuele Vulcano.
** 
** The license should have been distributed
** along with this source file. If it hasn't,
** please see the Afloat development site at
** <http://millenomi.altervista.org/Afloat/Next>
** or contact the main developer at
** <millenomi+afloatlicense@gmail.com>.
*/


#import "L0AfloatWindowMover.h"


@implementation L0AfloatWindowMover

- (void) beginTrackingWindow:(NSWindow*) window {
	if (window != trackedWindow) {
		[trackedWindow release];
		trackedWindow = [window retain];
		
		//NSLog(@"Begun tracking %@", trackedWindow);
	}
}

- (void) endTracking {
	[trackedWindow displayIfNeeded];
	[trackedWindow release];
	trackedWindow = nil;
	//NSLog(@"Ended tracking.");
}

- (void) moveTrackedWindowByX:(float) x Y:(float) y {
	if (!trackedWindow)
		return;
	
	//NSLog(@"About to move %@ by x %f, y %f", trackedWindow, x, y);
	
	NSRect frame = [trackedWindow frame];
	frame.origin.x += x;
	frame.origin.y -= y;
	[trackedWindow setFrame:frame display:NO];
}

- (BOOL) willHandleEvent:(NSEvent*) event {
	int type = [event type];
	if (trackedWindow && type == NSLeftMouseDragged) {
		[NSApp preventWindowOrdering];
		[self moveTrackedWindowByX:[event deltaX] Y:[event deltaY]];
		return YES;
	} else if (trackedWindow && type == NSLeftMouseUp) {
		[NSApp preventWindowOrdering];
		[NSApp deactivate];
		[self endTracking];
		return YES;
	} else if (!trackedWindow && type == NSLeftMouseDown && ([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == (NSControlKeyMask | NSCommandKeyMask)) {
		[NSApp preventWindowOrdering];
		[self beginTrackingWindow:[event window]];
		return YES;
	} else if (trackedWindow) {
		[NSApp preventWindowOrdering];
		return YES; // prevent ALL events to be sent during window tracking.
	}
	
	//NSLog(@"%@", event);
	
	return NO;
}

- (void) dealloc {
	[trackedWindow release];
	[super dealloc];
}

+ (id) sharedInstance {
    static id myself = nil;
    if (myself == nil)
        myself = [[self alloc] init];
    
    return myself;
}

@end
