/*
** L0Afloat.m
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

#import "L0Afloat.h"
#import "L0AfloatWindowFloater.h"
#import "L0AfloatWindowMover.h"
#import "L0AfloatWindowTransitions.h"

#import <objc/objc-class.h>

@implementation L0Afloat

- (BOOL) insertMenuItemsIntoRightSubmenuOfMenu:(NSMenu*) menu {
    int i;
    for (i = 0; i < [menu numberOfItems]; i++) {
        NSMenuItem* item = [menu itemAtIndex:i];
		
        if ([item hasSubmenu]) {
            if ([self insertMenuItemsIntoRightSubmenuOfMenu:[item submenu]])
                return YES;
        } else if ([item action] == @selector(arrangeInFront:)) {
            [self addAfloatMenuItemsToMenu:menu index:i];
            return YES;
        }
    }
	
	for (i = 0; i < [menu numberOfItems]; i++) {
        NSMenuItem* item = [menu itemAtIndex:i];
		
		if ([item action] == @selector(zoom:) || [item action] == @selector(performZoom:)) {
			[self addAfloatMenuItemsToMenu:menu index:i];
			return YES;
		}
	}
    
    return NO;
}

- (void) addAfloatMenuItemsToMenu:(NSMenu*) menu index:(int) i {
	NSArray* commands = [menuWithItems itemArray];
	NSEnumerator* enu = [commands objectEnumerator];
	
	NSMenuItem* item;
	while (item = [enu nextObject]) {
		[item retain];
		[menuWithItems removeItem:item];
		[menu insertItem:item atIndex:i];
		[item release];
		i++;
	}
	
	[menu insertItem:[NSMenuItem separatorItem] atIndex:i];
}

//////////////

- (L0AfloatWindowModule*) moduleOfClass:(Class) cls forWindow:(NSWindow*) window {
	return [[windowData objectForKey:[NSValue valueWithPointer:window]] objectForKey:cls];
}

- (L0AfloatWindowModule*) findOrCreateModuleOfClass:(Class) cls forWindow:(NSWindow*) window {
	L0AfloatWindowModule* mod = [self moduleOfClass:cls forWindow:window];
	
	if (!mod) {
		mod = [[cls alloc] initForWindow:window];
		NSMutableDictionary* dic = [windowData objectForKey:[NSValue valueWithPointer:window]];
		if (!dic) {
			dic = [NSMutableDictionary dictionaryWithObject:mod forKey:cls];
			[windowData setObject:dic forKey:[NSValue valueWithPointer:window]];
		} else
			[dic setObject:mod forKey:cls];
	}
	
	return mod;
}

- (void) removeAllModulesForWindow:(NSWindow*) window {
	[windowData removeObjectForKey:[NSValue valueWithPointer:window]];
}

- (NSArray*) modulesForWindow:(NSWindow*) window {
	return [[windowData objectForKey:[NSValue valueWithPointer:window]] allValues];
}

- (NSArray*) findOrCreateModulesForWindow:(NSWindow*) window {
	NSArray* a = [self modulesForWindow:window];
	if (!a) {
		NSEnumerator* enu = [[self perWindowModuleClasses] objectEnumerator];
		Class cls;
		while (cls = [enu nextObject])
			[self moduleOfClass:cls forWindow:window]; // this loads the module implicitely
	}
	
	return [self modulesForWindow:window];
}

/////////////////

- (BOOL) willValidateMenuItem:(NSMenuItem*) item forWindow:(NSWindow*) wnd shouldEnable:(BOOL*) shouldEnable {
	NSEnumerator* enu = [[self globalModules] objectEnumerator];
	L0AfloatModule* mod;
	
	while (mod = [enu nextObject])
		if ([mod willValidateMenuItem:item forWindow:wnd shouldEnable:shouldEnable])
			return YES;
	
	enu = [[self findOrCreateModulesForWindow:wnd] objectEnumerator];
	while (mod = [enu nextObject])
		if ([mod willValidateMenuItem:item forWindow:wnd shouldEnable:shouldEnable])
			return YES;
	
	return NO;
}

- (BOOL) willHandleEvent:(NSEvent*) evt {
	NSEnumerator* enu = [[self globalModules] objectEnumerator];
	L0AfloatModule* mod;
	
	while (mod = [enu nextObject])
		if ([mod willHandleEvent:evt])
			return YES;
	
	enu = [[self findOrCreateModulesForWindow:[evt window]] objectEnumerator];
	while (mod = [enu nextObject])
		if ([mod willHandleEvent:evt])
			return YES;
	
	return NO;	
}

/////////////////

- (BOOL) renameSelector:(SEL) select ofClass:(Class) cls toNewSelector:(SEL) newSel {
    Method method = nil;
    
    // First, look for the methods
    method = class_getInstanceMethod(cls, select);
    if (method == nil)
        return NO;
    
    method->method_name = newSel;
    return YES;	
}

- (BOOL) bypassSelector:(SEL) original ofClass:(Class) cls throughNewSelector:(SEL) newSel keepOriginalAs:(SEL) kept {
	BOOL res = [self renameSelector:original ofClass:cls toNewSelector:kept];
	res = [self renameSelector:newSel ofClass:cls toNewSelector:original] && res;
	
	return res;
}

+ (L0Afloat*) sharedInstance {
	static L0Afloat* myself = nil;
	
	if (!myself)
		myself = [[L0Afloat alloc] init];
	
	return myself;
}

+ (void) doLoad {
	if (NO) // TODO -> L0AfloatPreferences
		return;
	
	L0Afloat* me = [self sharedInstance];
	[me bypassSelector:@selector(sendEvent:) ofClass:[NSApplication class] throughNewSelector:@selector(L0Afloat_sendEvent:) keepOriginalAs:@selector(L0Afloat_appKitSendEvent:)];
	[me bypassSelector:@selector(validateMenuItem:) ofClass:[NSWindow class] throughNewSelector:@selector(L0Afloat_validateMenuItem:) keepOriginalAs:@selector(L0Afloat_appKitValidateMenuItem:)];
	[me bypassSelector:@selector(dealloc) ofClass:[NSWindow class] throughNewSelector:@selector(L0Afloat_dealloc) keepOriginalAs:@selector(L0Afloat_appKitDealloc)];
	
	[NSBundle loadNibNamed:@"AfloatMenuCommands" owner:me];
	[me insertMenuItemsIntoRightSubmenuOfMenu:[NSApp mainMenu]];
}

/////////////

- (id) init {
	if (self = [super init])
		windowData = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void) dealloc {
	[windowData release];
	
	[super dealloc];
}

/////////////

- (NSArray*) globalModules {
	static NSArray* globMods = nil;
	if (!globMods) {
		globMods = [[NSArray alloc] initWithObjects:
			[L0AfloatWindowMover sharedInstance],
			[L0AfloatWindowTransitions sharedInstance],
			nil];
	}
	
	return globMods;
}

- (NSArray*) perWindowModuleClasses {
	static NSArray* classes = nil;
	if (!classes) {
		classes = [[NSArray alloc] initWithObjects:
			[L0AfloatWindowFloater class],
			nil]; // TODO
	}
	
	return classes;
}

/////////////

@end


@implementation NSWindow (L0AfloatBypassSelectors)

- (BOOL) L0Afloat_validateMenuItem:(id <NSMenuItem>) itm {
	BOOL shouldEnable;
	if ([[L0Afloat sharedInstance] willValidateMenuItem:itm forWindow:self shouldEnable:&shouldEnable])
		return shouldEnable;
	
	return [self L0Afloat_appKitValidateMenuItem:itm];
}

- (void) L0Afloat_dealloc {
	[[L0Afloat sharedInstance] removeAllModulesForWindow:self];
	[self L0Afloat_appKitDealloc];
}

@end

@implementation NSApplication (L0AfloatBypassSelectors)

- (void) L0Afloat_sendEvent:(NSEvent*) evt {
	if ([[L0Afloat sharedInstance] willHandleEvent:evt])
		return;
	
	[self L0Afloat_appKitSendEvent:evt];
}

@end