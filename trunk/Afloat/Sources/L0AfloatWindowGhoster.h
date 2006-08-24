/*
** L0AfloatWindowGhoster.h
** 
**   Ghost windows module -- adds the capability
** to set any window to ignore clicks.
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

@interface L0AfloatWindowGhoster : L0AfloatWindowModule {

}

- (BOOL) isGhost;
- (void) setGhost:(BOOL) ghost;

+ (id) ghosterForWindow:(NSWindow*) wnd;

@end

@interface NSApplication (L0AfloatWindowGhosterAdditions)

- (IBAction) L0Afloat_windowGhosterMaterializeAllGhosts:(id) sender;

@end

@interface NSWindow (L0AfloatWindowGhosterAdditions)

- (IBAction) L0Afloat_windowGhosterMakeGhost:(id) sender;

@end