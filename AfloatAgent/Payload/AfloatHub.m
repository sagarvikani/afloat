//
//  AfloatHub.m
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import "AfloatHub.h"


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
	}
	
	return self;
}

- (void) dealloc {
	[windowData release];
	[super dealloc];
}

- (NSMutableDictionary*) infoForWindow:(id /* AfloatWindow */) wnd {
	id data = [windowData objectForKey:wnd];
	
	if (!data) {
		data = [NSMutableDictionary dictionary];
		[windowData setObject:data forKey:wnd];
	}
	
	return data;
}

- (void) clearInfoForWindow:(id) wnd {
	[windowData removeObjectForKey:wnd];
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
	// but Carbon does not support connections
	// as Cocoa does.
	
	[adjustEffectsPanel makeKeyAndOrderFront:self];
}

#pragma mark ** Features **



@end
