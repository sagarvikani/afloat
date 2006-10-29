/*
** L0AfloatWindowModule.h
** 
**   The superclass for all per-window modules.
** Subclasses will be instantiated for each
** window and the instances will be released once
** the window is deallocated.
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
#import "L0AfloatModule.h"

@interface L0AfloatWindowModule : L0AfloatModule {
	NSWindow* window;
}

- (id) initForWindow:(NSWindow*) wnd;

- (NSWindow*) window;
- (void) setWindow:(NSWindow*) wnd;

@end
