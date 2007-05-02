//
//  AfloatWindowFader.m
//  AfloatAgent
//
//  Created by ∞ on 17/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AfloatWindowFader.h"
#import "AfloatHub.h"
#import "AfloatLogging.h"
#import "AfloatPreferences.h"

@implementation AfloatWindowFader

- (id) initForWindow:(id) w {
	if (self = [super init]) {
		window = w; // weak -- we are owned by the window's info dictionary.
		tracker = [[w beginMouseTrackingWithOwner:self] retain];
	}
	
	AfloatLog(@"Fader created for window %@", w);
	
	return self;
}

- (void) dealloc {
    [tracker release];
	AfloatLog(@"Fader removed for window %@", window);
	
	[super dealloc];
}

// TODO: Factor Cocoa away.
- (void) mouseEntered:(NSEvent*) evt {
	if ([[AfloatPreferences sharedInstance] boolForKey:@"AfloatDoAnimation" withDefault:YES])
		[self scheduleMousePositionTest];
	else
		[[AfloatHub sharedHub] fadeInWindow:[evt window]];
}

- (void) mouseExited:(NSEvent*) evt {
	if ([[AfloatPreferences sharedInstance] boolForKey:@"AfloatDoAnimation" withDefault:YES])
		[self scheduleMousePositionTest];
	else
		[[AfloatHub sharedHub] fadeOutWindow:[evt window]];
}

- (void) scheduleMousePositionTest {
	if (timer) {
		AfloatLog(@"Coalesced an additional mouse event for fader %@ for window %@", self, window);
		return;
	}
	
	AfloatLog(@"Scheduling a mouse position test in 0.3s for fader %@ for window %@", self, window);
	timer = [[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(performMousePositionTest:) userInfo:nil repeats:NO] retain];
}

- (void) performMousePositionTest:(NSTimer*) theTimer {
	AfloatLog(@"Performing scheduled position test for fader %@ for window %@", self, window);
	[timer release]; timer = nil;
	
	NSPoint p = [NSEvent mouseLocation];
	NSRect frame = [window frame];
	
	if (NSPointInRect(p, frame)) {
		AfloatLog(@"Fading in.");
		[[AfloatHub sharedHub] fadeInWindow:window];
	} else {
		AfloatLog(@"Fading out.");
		[[AfloatHub sharedHub] fadeOutWindow:window];
	}
}

@end
