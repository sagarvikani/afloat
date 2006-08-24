/*
** L0AfloatWindowModule.m
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

#import "L0AfloatWindowModule.h"


@implementation L0AfloatWindowModule

- (id) initForWindow:(NSWindow*) wnd {
	if (self = [super init])
		[self setWindow:wnd];
	
	return self;
}

- (void) dealloc {
	[self setWindow:nil];
	[super dealloc];
}

- (NSWindow*) window { return window; }
- (void) setWindow:(NSWindow*) wnd {
	window = wnd; // weak ref
}

@end
