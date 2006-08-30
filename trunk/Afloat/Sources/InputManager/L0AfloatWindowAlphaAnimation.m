/*
** L0AfloatWindowAlphaAnimation.m
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

#import "L0AfloatWindowAlphaAnimation.h"


@implementation L0AfloatWindowAlphaAnimation

- (id) initForWindow:(NSWindow*) aWindow fromAlpha:(float) aFromAlpha toAlpha:(float) aToAlpha {
	if (self = [super init]) {
		_window = [aWindow retain];
		_fromAlpha = aFromAlpha;
		_toAlpha = aToAlpha;
	}
	
	return self;
}

- (void) performAt:(float) progress {
	float alpha = _toAlpha + ((_fromAlpha - _toAlpha) * (1 - progress));
	[_window setAlphaValue:alpha];
}

- (void) willBegin { [_window setAlphaValue:_fromAlpha]; }
- (void) didEnd { [_window setAlphaValue:_toAlpha]; }

- (void) dealloc {
	[_window release];
	[super dealloc];
}

@end
