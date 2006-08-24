/*
** L0AfloatWindowAlphaAnimation.h
** 
**   This animation changes the opacity of
** a window from a starting to an ending value.
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

@interface L0AfloatWindowAlphaAnimation : L0AfloatAni {
	NSWindow* _window;
	float _fromAlpha;
	float _toAlpha;
}

- (id) initForWindow:(NSWindow*) window fromAlpha:(float) fromAlpha toAlpha:(float) toAlpha;

@end
