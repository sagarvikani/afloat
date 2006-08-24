/*
** L0AfloatWindowFrameAnimation.h
** 
**   This animation moves a window by
** transitioning from a starting frame to an
** ending frame specified during construction.
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

#import <Cocoa/Cocoa.h>
#import "L0AfloatAni.h"

@interface L0AfloatWindowFrameAnimation : L0AfloatAni {
	NSWindow* _window;
	NSRect _fromFrame;
	NSRect _toFrame;
}

- (id) initForWindow:(NSWindow*) window fromFrame:(NSRect) fromFrame toFrame:(NSRect) toFrame;

@end
