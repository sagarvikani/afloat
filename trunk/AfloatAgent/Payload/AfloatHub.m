//
//  AfloatHub.m
//  AfloatAgent

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import "../AfloatAgentCommunication.h"
#import "AfloatHub.h"

#import "AfloatAnimator.h"
#import "AfloatWindowAlphaAnimation.h"
#import "AfloatWindowFader.h"

@implementation AfloatHub

+ (id) sharedHub {
	static id me = nil;
	if (!me) me = [self new];
	
	return me;
}

- (id) init {
	if (self = [super init]) {
		windowData = [NSMutableDictionary new];
		[NSBundle loadNibNamed:@"Hub" owner:self];
		
		[self addObserver:self forKeyPath:@"focusedWindow.alphaValue" options:0 context:nil];
		animating = NO;
		
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToRollCall:) name:kAfloatRollCallNotification object:kAfloatDistributedObjectIdentifier];
	}
	
	return self;
}

- (void) respondToRollCall:(NSNotification*) notif {
	NSDictionary* info = [NSDictionary dictionaryWithObject:[[NSBundle mainBundle] bundleIdentifier] forKey:kAfloatApplicationBundleID];
	
	[[NSDistributedNotificationCenter defaultCenter] 
		postNotificationName:kAfloatAlreadyLoadedNotification object:kAfloatDistributedObjectIdentifier userInfo:info deliverImmediately:YES];
}

- (void) dealloc {
	[self removeObserver:self forKeyPath:@"focusedWindow.alphaValue"];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	
	[windowData release];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString*) keyPath ofObject:(id)object change:(NSDictionary*) change context:(void*) context {	
	if ([keyPath isEqualToString:@"focusedWindow.alphaValue"]) {
		id focus = [self focusedWindow];
		if (animating || !focus) return;
		
		NSMutableDictionary* info = [self infoForWindow:focus];
		[info setObject:[NSNumber numberWithFloat:[focus alphaValue]] forKey:@"AfloatLastAlphaValue"];
		
		if ([focus alphaValue] >= 0.95)
			[info removeObjectForKey:kAfloatWindowFaderKey];
		else
			[info setObject:[[[AfloatWindowFader alloc] initForWindow:focus] autorelease] forKey:kAfloatWindowFaderKey];
	}
}

- (NSMutableDictionary*) infoForWindow:(id /* AfloatWindow */) wnd {
	id data = [windowData objectForKey:[NSValue valueWithNonretainedObject:wnd]];
	
	if (!data) {
		data = [NSMutableDictionary dictionary];
		[windowData setObject:data forKey:[NSValue valueWithNonretainedObject:wnd]];
	}
	
	return data;
}

- (void) clearInfoForWindow:(id) wnd {
	[windowData removeObjectForKey:[NSValue valueWithNonretainedObject:wnd]];
}

- (void) willRemoveWindow:(id) wnd {
	[self clearInfoForWindow:wnd];
}

- (id) focusedWindow {
	return focusedWindow;
}

- (void) setFocusedWindow:(id) wnd {
	if (wnd != focusedWindow) {
		[focusedWindow release];
		focusedWindow = [wnd retain];
	}
}

- (NSMenu*) afloatMenu {
	return menuWithModelItems;
}

- (IBAction) showAdjustEffectsPanel:(id) sender {
	// I could have connected it in IB;
	// but does Carbon support connections
	// as Cocoa does?
	// This way, a menu with action == showAdjustEffectsPanel:
	// can be intercepted and redirected to an appropriate
	// function/method/whatever by the impl.
	
	[adjustEffectsPanel makeKeyAndOrderFront:self];
}

#pragma mark ** Features **

- (IBAction) toggleKeepAfloat:(id) sender {
	id win = [self focusedWindow];
	if (!win) { NSBeep(); return; }
	
	if ([win alwaysOnTop]) {
		[win setAlwaysOnTop:NO];
		[win setAlphaValue:1.0];
	} else {
		[win setAlwaysOnTop:YES];
		[win setAlphaValue:[self mediumAlphaValue]];
	}
}

- (float) mediumAlphaValue {
	return 0.8;
}

- (float) adequateOverlayAlphaValue {
	return 0.4;
}

- (float) normalizedAlphaValueForValue:(float) val {
    if (val > 1.0) return 1.0;
    if (val < 0.1) return 0.1;
    
    return val;
}

- (IBAction) makeOpaque:(id) sender {
    [[self focusedWindow] setAlphaValue:1.0];
}

- (IBAction) makeMediumTransparency:(id) sender {
    [[self focusedWindow] setAlphaValue:[self mediumAlphaValue]];
}

- (IBAction) lessTransparent:(id) sender {
    float newVal = [[self focusedWindow] alphaValue] - 0.15;
    [[self focusedWindow] setAlphaValue:[self normalizedAlphaValueForValue:newVal]];
}

- (IBAction) moreTransparent:(id) sender {
    float newVal = [[self focusedWindow] alphaValue] + 0.15;
    [[self focusedWindow] setAlphaValue:[self normalizedAlphaValueForValue:newVal]];
}

- (void) fadeInWindow:(id) window {
	if ([window overlayWindow] && !temporarilyTrackingOverlays) return;
	
	[[self infoForWindow:window] setObject:[NSNumber numberWithFloat:[window alphaValue]] forKey:@"AfloatLastAlphaValue"];

	// NSLog(@"entered: %f", [[theEvent window] alphaValue]);
	
	animating = YES;
	AfloatAnimator* ani = [[AfloatAnimator alloc] initWithApproximateDuration:0.35];
	[ani addAnimation:[AfloatWindowAlphaAnimation animationForWindow:window fromAlpha:[window alphaValue] toAlpha:1.0]];
	[ani run];
	[ani release];
	animating = NO;
}

- (void) fadeOutWindow:(id) window {
	NSNumber* num = [[self infoForWindow:window] objectForKey:@"AfloatLastAlphaValue"];
	if (num == nil) return;
	float oldAlpha = [num floatValue];
	
	NSLog(@"exited: %@", num);
	
	animating = YES;
	AfloatAnimator* ani = [[AfloatAnimator alloc] initWithApproximateDuration:0.35];
	[ani addAnimation:[AfloatWindowAlphaAnimation animationForWindow:window fromAlpha:[window alphaValue] toAlpha:oldAlpha]];
	[ani run];
	[ani release];
	[window setAlphaValue:oldAlpha];
	animating = NO;
}

- (IBAction) resetAllOverlays:(id) sender {
	NSEnumerator* enu = [[[AfloatImplementation sharedInstance] windows] objectEnumerator];
	id window;
	
	while (window = [enu nextObject]) {
		if (![window overlayWindow]) continue;
		
		[window setOverlayWindow:NO];
		[window setAlwaysOnTop:NO];
		[window setAlphaValue:1.0];
	}
}

- (void) beginTemporaryTrackingOfOverlays {
	temporarilyTrackingOverlays = YES;
	
	NSEnumerator* enu = [[[AfloatImplementation sharedInstance] windows] objectEnumerator];
	id wnd;
	
	while (wnd = [enu nextObject]) {
		if (![wnd overlayWindow])
			continue;
		
		[[self infoForWindow:wnd] setObject:[NSNumber numberWithBool:YES] forKey:@"AfloatIsTemporarilyTracked"];
		[wnd setOverlayWindow:NO];
	}
}

- (void) endTemporaryTrackingOfOverlays {
	if (!temporarilyTrackingOverlays) return;
	temporarilyTrackingOverlays = NO;
	
	NSEnumerator* enu = [[[AfloatImplementation sharedInstance] windows] objectEnumerator];
	id wnd;
	
	while (wnd = [enu nextObject]) {
		NSMutableDictionary* d = [self infoForWindow:wnd];
		if (![d objectForKey:@"AfloatIsTemporarilyTracked"])
			continue;
		
		[d removeObjectForKey:@"AfloatIsTemporarilyTracked"];
		[wnd setOverlayWindow:YES];
	}
}

- (BOOL) isTemporarilyTrackingOverlays {
	return temporarilyTrackingOverlays;
}

- (IBAction) toggleAlwaysOnTop:(id) sender {
	id w = [self focusedWindow];
	[w setAlwaysOnTop:![w alwaysOnTop]];
}

@end
