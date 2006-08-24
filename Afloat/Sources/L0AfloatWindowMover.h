/*
** L0AfloatWindowMover.h
** 
**   Window mover module -- adds the capability
** to move any window by dragging it while
** modifier keys are down.
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

@interface L0AfloatWindowMover : L0AfloatModule {
	NSWindow* trackedWindow;
}

+ (id) sharedInstance;

- (void) beginTrackingWindow:(NSWindow*) window;
- (void) endTracking;

- (void) moveTrackedWindowByX:(float) x Y:(float) y;

@end
