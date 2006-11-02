
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

// From SIMBL creator, ...
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

@end
