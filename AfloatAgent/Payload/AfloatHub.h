//
//  AfloatHub.h
//  AfloatAgent

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import <Cocoa/Cocoa.h>
#import "AfloatImplementation.h"

@interface AfloatHub : NSObject {
	NSMutableDictionary* windowData;
	NSObject* focusedWindow; // prevents IB from picking it up as an outlet
	BOOL animating;
	
	IBOutlet NSMenu* menuWithModelItems;
	IBOutlet NSPanel* adjustEffectsPanel;
	
	BOOL temporarilyTrackingOverlays;
	
	id windowBeingCleared;
	NSMutableDictionary* temporaryCopyOfInfoOfWindowBeingCleared;
	
	BOOL doingSeethru;
	NSAppleScript* reactivationScript;
}

+ (id) sharedHub;

- (void) changedUserAlpha:(float) ua forWindow:(NSWindow*) wnd;

- (NSMutableDictionary*) infoForWindow:(id /* AfloatWindow */) wnd;
- (void) clearInfoForWindow:(id) wnd;

- (void) willRemoveWindow:(id) wnd;

- (id) focusedWindow;
- (void) setFocusedWindow:(id) wnd;

- (IBAction) showAdjustEffectsPanel:(id) sender;
- (NSMenu*) afloatMenu;

- (IBAction) toggleKeepAfloat:(id) sender;
- (float) mediumAlphaValue;
- (float) adequateOverlayAlphaValue;

- (float) normalizedAlphaValueForValue:(float) val;

- (IBAction) makeOpaque:(id) sender;
- (IBAction) makeMediumTransparency:(id) sender;
- (IBAction) lessTransparent:(id) sender;
- (IBAction) moreTransparent:(id) sender;
- (IBAction) resetAllOverlays:(id) sender;

- (void) fadeWindow:(id) window toAlpha:(float) alpha duration:(NSTimeInterval) duration;
- (void) fadeWindow:(id) window toAlpha:(float) alpha;

- (void) beginTemporaryTrackingOfOverlays;
- (void) endTemporaryTrackingOfOverlays;
- (BOOL) isTemporarilyTrackingOverlays;

- (IBAction) toggleAlwaysOnTop:(id) sender;

- (void) fadeInWindow:(id) wnd;
- (void) fadeOutWindow:(id) wnd;

@end
