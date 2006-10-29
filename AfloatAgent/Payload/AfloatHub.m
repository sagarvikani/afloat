//
//  AfloatHub.m
//  AfloatAgent
//
//  Created by ∞ on 28/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AfloatHub.h"


@implementation AfloatHub

+ (id) sharedHub {
	static id me = nil;
	if (!me) me = [self new];
	
	return me;
}

- (id) init {
	if (self = [super init])
		windowData = [NSMutableDictionary new];
	
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

@end
