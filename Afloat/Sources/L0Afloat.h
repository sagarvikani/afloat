/*
** L0Afloat.h
** 
**   The main class.
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
#import "L0AfloatWindowModule.h"

@interface L0Afloat : NSObject {
	NSMutableDictionary* windowData;
	
	IBOutlet NSMenu* menuWithItems;
}

- (L0AfloatWindowModule*) moduleOfClass:(Class) cls forWindow:(NSWindow*) window;
- (L0AfloatWindowModule*) findOrCreateModuleOfClass:(Class) cls forWindow:(NSWindow*) window;
- (void) removeAllModulesForWindow:(NSWindow*) window;
- (NSArray*) modulesForWindow:(NSWindow*) window;

- (NSArray*) findOrCreateModulesForWindow:(NSWindow*) window;

- (NSArray*) globalModules;
- (NSArray*) perWindowModuleClasses;

- (BOOL) willValidateMenuItem:(NSMenuItem*) item forWindow:(NSWindow*) wnd shouldEnable:(BOOL*) shouldEnable;
- (BOOL) willHandleEvent:(NSEvent*) evt;

- (BOOL) renameSelector:(SEL) select ofClass:(Class) cls toNewSelector:(SEL) newSel;
- (BOOL) bypassSelector:(SEL) select ofClass:(Class) cls throughNewSelector:(SEL) newSel keepOriginalAs:(SEL) original;

- (BOOL) insertMenuItemsIntoRightSubmenuOfMenu:(NSMenu*) menu;
- (void) addAfloatMenuItemsToMenu:(NSMenu*) menu index:(int) i;

+ (void) doLoad;
+ (L0Afloat*) sharedInstance;

@end


@interface NSObject (L0AfloatBypassSelectors)
// from NSApplication
- (void) L0Afloat_appKitSendEvent:(NSEvent*) evt;

// from NSWindow
- (BOOL) L0Afloat_appKitValidateMenuItem:(id <NSMenuItem>) itm;
- (void) L0Afloat_appKitDealloc;

@end

@interface NSWindow (L0AfloatBypassSelectors)

- (BOOL) L0Afloat_validateMenuItem:(id <NSMenuItem>) itm;
- (void) L0Afloat_dealloc;

@end

@interface NSApplication (L0AfloatBypassSelectors)

- (void) L0Afloat_sendEvent:(NSEvent*) evt;

@end