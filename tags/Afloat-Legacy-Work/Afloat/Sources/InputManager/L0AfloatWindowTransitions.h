/*
** L0AfloatWindowTransitions.h
** 
**   Window transitions module -- adds
** fading to all app windows when they appear
** or disappear.
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
#import "L0AfloatWindowModule.h"

@interface L0AfloatWindowTransitions : L0AfloatWindowModule { }

+ (id) sharedInstance;

@end

@interface NSObject (L0AfloatWindowTransitionsBypasses)
- (void) L0Afloat_appKitOrderWindow:(NSWindowOrderingMode) order relativeTo:(int) wnd;
@end

@interface NSWindow (L0AfloatWindowTransitionsAdditions)
- (void) L0Afloat_orderWindow:(NSWindowOrderingMode) order relativeTo:(int) wnd;
@end