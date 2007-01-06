/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import "../AfloatAgentCommunication.h"
#import "AfloatCocoa.h"

#import <objc/objc-class.h>
#import "AfloatHub.h"

#define kAfloatCocoaUserAlphaValue @"AfloatCocoaUserAlphaValue"

@implementation AfloatCocoa

// From SIMBL's creator, ...
- (BOOL) renameSelector:(SEL) select ofClass:(Class) cls toNewSelector:(SEL) newSel {
    Method method = nil;
	
    method = class_getInstanceMethod(cls, select);
    if (method == nil)
        return NO;
	
    method->method_name = newSel;
    return YES;
}

- (BOOL) bypassSelector:(SEL) original ofClass:(Class) cls throughNewSelector:(SEL) newSel keepOriginalAs:(SEL) kept {
	BOOL res = [self renameSelector:original ofClass:cls toNewSelector:kept];
	if (res)
		res = [self renameSelector:newSel ofClass:cls toNewSelector:original];
	
	return res;
}

- (void) performInstallOnMainThread {
	[self performSelectorOnMainThread:@selector(install) withObject:nil waitUntilDone:NO];
}

- (void) install {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeFocusedWindow:) name:NSWindowDidBecomeMainNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willCloseWindow:) name:NSWindowWillCloseNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:NSApplicationWillResignActiveNotification object:NSApp];
	
	[[AfloatHub sharedHub] setFocusedWindow:[[NSApp mainWindow] afloatTopWindow]];	
	
	// install menu items
	
	NSMenu* mainMenu = [NSApp mainMenu], * items = [[AfloatHub sharedHub] afloatMenu];
	[self searchAndInstallMenuItems:items inAppropriateMenuIn:mainMenu];
    
    // install Drag Anywhere
    
    [self bypassSelector:@selector(sendEvent:) ofClass:[NSApplication class] throughNewSelector:@selector(afloatSendEvent:) keepOriginalAs:@selector(afloatSendEventOriginal:)];
}

- (BOOL) searchAndInstallMenuItems:(NSMenu*) items inAppropriateMenuIn:(NSMenu*) menu {
	NSEnumerator* enu = [[menu itemArray] objectEnumerator];
	int i = -1;
	NSMenuItem* item;
	
	while (item = [enu nextObject]) {
		i++;
		if ([item action] == @selector(performMiniaturize:)) {
			[self installMenuItems:items inMenu:menu index:i];
			return YES;
		}
		
		if ([item hasSubmenu]) {
			if ([self searchAndInstallMenuItems:items inAppropriateMenuIn:[item submenu]])
				return YES;
		}
	}
	
	return NO;
}

- (void) installMenuItems:(NSMenu*) items inMenu:(NSMenu*) menu index:(int) i {
	NSMenuItem* newItem = [[NSMenuItem alloc] initWithTitle:@"Afloat" action:nil keyEquivalent:@""];
	
	[menu insertItem:newItem atIndex:i];
	[menu setSubmenu:items forItem:newItem];
	
	[newItem release];
}

- (void) didChangeFocusedWindow:(NSNotification*) notif {
	[[AfloatHub sharedHub] setFocusedWindow:[notif object]];
}

- (void) willCloseWindow:(NSNotification*) notif {
	[[AfloatHub sharedHub] willRemoveWindow:[notif object]];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (NSArray*) windows {
	NSEnumerator* enu = [[NSApp windows] objectEnumerator];
	NSWindow* wnd;
	NSMutableSet* topWindows = [NSMutableSet set];
	
	while (wnd = [enu nextObject])
		[topWindows addObject:[wnd afloatTopWindow]];
	
	return [topWindows allObjects];
}

- (id) focusedWindow {
	return [[[NSApp orderedWindows] objectAtIndex:0] afloatTopWindow];
}

@end

@implementation NSWindow (AfloatCocoaAdditions)

- (float) userAlphaValue {
    NSNumber* n = [[[AfloatHub sharedHub] infoForWindow:self] objectForKey:kAfloatCocoaUserAlphaValue];
    if (n) return [n floatValue];
    
    return [self alphaValue];
}

- (void) setUserAlphaValue:(float) uav {
    [[[AfloatHub sharedHub] infoForWindow:self] setObject:[NSNumber numberWithFloat:uav] forKey:kAfloatCocoaUserAlphaValue];
    [self setAlphaValue:uav];
    [[AfloatHub sharedHub] changedUserAlpha:uav forWindow:self];
}

- (BOOL) overlayWindow {
	return [self ignoresMouseEvents];
}

- (void) setOverlayWindow:(BOOL) overlay {
	if (overlay) {
		[self setIgnoresMouseEvents:YES];
		if ([self alphaValue] == 1.0) [self setAlphaValue:[[AfloatHub sharedHub] adequateOverlayAlphaValue]];
		[self setAlwaysOnTop:YES];
	} else {
		[self setIgnoresMouseEvents:NO];
		if ([self alphaValue] == [[AfloatHub sharedHub] adequateOverlayAlphaValue]) [self setAlphaValue:1.0];
		[self setAlwaysOnTop:NO];
	}
}

- (id) afloatTopWindow {
	NSWindow* me = self;
	while ([me parentWindow])
		me = [me parentWindow];
		
	return me;
}

- (BOOL) alwaysOnTop {
	return [self level] == NSFloatingWindowLevel;
}

- (void) setAlwaysOnTop:(BOOL) onTop {
	[self setLevel:(onTop? NSFloatingWindowLevel : NSNormalWindowLevel)];
}


- (void) beginMouseTrackingWithOwner:(id) owner {
	NSMutableDictionary* myInfo = [[AfloatHub sharedHub] infoForWindow:self];
	if ([[myInfo objectForKey:@"AfloatTrackingRectTagOwner"] nonretainedObjectValue] == owner) return;
	
	[self endMouseTracking];
	
	NSView* windowView = [[self contentView] superview];
	NSRect frame = [windowView frame];
	
	NSTrackingRectTag tr = [windowView addTrackingRect:frame owner:owner userData:self assumeInside:NO];
	
	[myInfo setObject:[NSNumber numberWithInt:tr] forKey:@"AfloatTrackingRectTag"];
	[myInfo setObject:[NSValue valueWithNonretainedObject:owner] forKey:@"AfloatTrackingRectTagOwner"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_afloat_windowViewDidChangeBounds:) name:NSViewBoundsDidChangeNotification object:windowView];
}

- (void) endMouseTracking {
	NSMutableDictionary* myInfo = [[AfloatHub sharedHub] infoForWindow:self];
	NSNumber* n = [myInfo objectForKey:@"AfloatTrackingRectTag"];
	if (n == nil) return;
	
	NSView* windowView = [[self contentView] superview];
	[windowView removeTrackingRect:[n intValue]];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:windowView];
	
	[myInfo removeObjectForKey:@"AfloatTrackingRectTag"];
	[myInfo removeObjectForKey:@"AfloatTrackingRectTagOwner"];
}

- (void) endMouseTrackingIfOwner:(id) owner {
	NSMutableDictionary* myInfo = [[AfloatHub sharedHub] infoForWindow:self];
	NSValue* v = [myInfo objectForKey:@"AfloatTrackingRectTagOwner"];
	
	if (v && [v nonretainedObjectValue] == owner)
		[self endMouseTracking];
}

- (void) _afloat_windowViewDidChangeBounds:(NSNotification*) notif {
	NSMutableDictionary* myInfo = [[AfloatHub sharedHub] infoForWindow:self];
	id theOwner = [[myInfo objectForKey:@"AfloatTrackingRectTagOwner"] nonretainedObjectValue];
	
	[self endMouseTracking];
	[self beginMouseTrackingWithOwner:theOwner];
}

@end

// Drag Anywhere and Scroll to Set Transparency code

@implementation NSApplication (AfloatCocoaAdditions)

- (void) afloatSendEvent:(NSEvent*) evt {
    // bad hack: since we're going to support 10.3.9, and
    // we cannot do so while still using NSDeviceIndependentModifierFlagsMask,
    // we copy its value here. Since it's an enum, it's not terribly
    // important. Still.
    // This should do nothing to pre-10.4 events.
    
    unsigned int mods = [evt modifierFlags] & /* NSDeviceIndependentModifierFlagsMask */ 0xffff0000U;
    NSPoint ori;
    AfloatHub* hub = [AfloatHub sharedHub]; id wnd; float oldAlpha;
    
    if (mods == (NSCommandKeyMask | NSControlKeyMask)) {
        
        switch ([evt type]) {
            case NSLeftMouseDown:
                return; // filter it
                
            case NSLeftMouseDragged:
                if (!(wnd = [hub focusedWindow])) return;
                    
                ori = [[hub focusedWindow] frame].origin;
                ori.x += [evt deltaX];
                ori.y -= [evt deltaY];
                [[hub focusedWindow] setFrameOrigin:ori];
                return; // filter it once done
                
            case NSLeftMouseUp:
                return; // filter it
                
            case NSScrollWheel:
                oldAlpha = [[hub focusedWindow] alphaValue];
                [[hub focusedWindow] setAlphaValue:
                    [hub normalizedAlphaValueForValue:oldAlpha + [evt deltaY] * 0.10]];
                //NSRunAlertPanel(@"Opacita'",[NSString stringWithFormat:@"%f", [evt deltaY]],nil,nil,nil);
                return; // filter it
				
			// command-click to allow overlay window manipulation.
			case NSFlagsChanged:
				[hub beginTemporaryTrackingOfOverlays];
				break; // we don't filter this event, merely add to it.
        }
        
    } else if ([hub isTemporarilyTrackingOverlays] && [evt type] == NSFlagsChanged) {
		[hub endTemporaryTrackingOfOverlays];
		// we don't filter this event, merely add to it.
	}
    
    // If we didn't return above, we return the event to its
    // regular code path.
    [self afloatSendEventOriginal:evt];
}

@end