/*
** L0AfloatWindowFloater.h
** 
**   Window floater module -- adds always-on-top
** and transparency to all windows.
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
#include "L0AfloatWindowModule.h"

typedef enum {
	L0AfloatOpaque = 0,
	L0AfloatTranslucent = 25,
	L0AfloatAlmostInvisible = 90
} L0AfloatTransparency;

@interface L0AfloatWindowFloater : L0AfloatWindowModule {
	NSTrackingRectTag windowTag;
	int transparency;
	BOOL trackingSuspended;
}

- (void) setAlwaysOnTop:(BOOL) top;
- (BOOL) isAlwaysOnTop;

- (void) setFloating:(BOOL) floating;
- (BOOL) isFloating;

- (int) transparency;
- (void) setTransparency:(int) transp;
- (int) transparencyFromAlpha:(float) alpha;
- (float) alphaFromTransparency:(int) transp;

- (void) beginMouseTracking;
- (void) endMouseTracking;

- (void) suspendMouseTracking;
- (void) resumeMouseTracking;

+ (L0AfloatWindowFloater*) floaterForWindow:(NSWindow*) wnd;

@end

@interface NSWindow (L0AfloatWindowFloaterAdditions)
- (IBAction) L0Afloat_windowFloaterToggleAlwaysOnTop:(id) sender;

- (IBAction) L0Afloat_windowFloaterSetOpaque:(id) sender;
- (IBAction) L0Afloat_windowFloaterSetTranslucent:(id) sender;
- (IBAction) L0Afloat_windowFloaterSetAlmostInvisible:(id) sender;

- (IBAction) L0Afloat_windowFloaterShowTransparencyPanel:(id) sender;
@end