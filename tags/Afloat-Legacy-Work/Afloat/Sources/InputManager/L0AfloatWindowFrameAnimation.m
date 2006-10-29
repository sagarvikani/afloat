/*
** L0AfloatWindowFrameAnimation.m
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

#import "L0AfloatWindowFrameAnimation.h"


@implementation L0AfloatWindowFrameAnimation

- (id) initForWindow:(NSWindow*) window fromFrame:(NSRect) fromFrame toFrame:(NSRect) toFrame {
	if (self = [super init]) {
		_window = [window retain];
		_fromFrame = fromFrame;
		_toFrame = toFrame;
	}
	
	return self;
}

- (void) performAt:(float) progress {
	NSRect nuFrame = _fromFrame;
	nuFrame.origin.x += (_toFrame.origin.x - _fromFrame.origin.x) * progress;
	nuFrame.origin.y += (_toFrame.origin.y - _fromFrame.origin.y) * progress;
	nuFrame.size.width += (_toFrame.size.width - _fromFrame.size.width) * progress;
	nuFrame.size.height += (_toFrame.size.height - _fromFrame.size.height) * progress;
	
	[_window setFrame:nuFrame display:YES];
}

- (void) willBegin {
	NSScreen* scr = [_window screen];
	if (scr) {
		NSRect goodFrame = [scr visibleFrame];
		if (_fromFrame.origin.x < goodFrame.origin.x)
			_fromFrame.origin.x = goodFrame.origin.x;
		if (_fromFrame.origin.y < goodFrame.origin.y)
			_fromFrame.origin.y = goodFrame.origin.y;
		if (_fromFrame.size.width > goodFrame.size.width)
			_fromFrame.size.width = goodFrame.size.width;
		if (_fromFrame.size.height > goodFrame.size.height)
			_fromFrame.size.height = goodFrame.size.height;
	}
	
	[_window setFrame:_fromFrame display:YES];
}
- (void) didEnd { [_window setFrame:_toFrame display:YES]; }

@end
