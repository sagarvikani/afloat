
/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */

#import "AfloatCocoa.h"

#import <objc/objc-class.h>
#import "AfloatHub.h"

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
	
	[self bypassSelector:@selector(dealloc) ofClass:[NSWindow class] throughNewSelector:@selector(afloatDealloc) keepOriginalAs:@selector(afloatDeallocOriginal)];
	
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

- (void) afloatDealloc {
	[[AfloatHub sharedHub] willRemoveWindow:self];
	[self endMouseTracking];
	[self afloatDeallocOriginal];
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
    AfloatHub* hub; id wnd;
    
    if (mods == (NSCommandKeyMask | NSControlKeyMask)) {
        
        switch ([evt type]) {
            case NSLeftMouseDown:
                return; // filter it
                
            case NSLeftMouseDragged:
                hub = [AfloatHub sharedHub];
                if (!(wnd = [hub focusedWindow])) return;
                    
                ori = [[hub focusedWindow] frame].origin;
                ori.x += [evt deltaX];
                ori.y -= [evt deltaY];
                [[hub focusedWindow] setFrameOrigin:ori];
                return; // filter it once done
                
            case NSLeftMouseUp:
                return; // filter it
                
            case NSScrollWheel:
                hub = [AfloatHub sharedHub];
                float oldAlpha = [[hub focusedWindow] alphaValue];
                [[hub focusedWindow] setAlphaValue:
                    [hub normalizedAlphaValueForValue:oldAlpha + [evt deltaY] * 0.10]];
                //NSRunAlertPanel(@"Opacita'",[NSString stringWithFormat:@"%f", [evt deltaY]],nil,nil,nil);
                return; // filter it
        }
        
    }
    
    // If we didn't return above, we return the event to its
    // regular code path.
    [self afloatSendEventOriginal:evt];
}

@end