//
//  AfloatCocoa.h
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import <Cocoa/Cocoa.h>
#import "AfloatImplementation.h"

@interface AfloatCocoa : AfloatImplementation {}

- (BOOL) renameSelector:(SEL) select ofClass:(Class) cls toNewSelector:(SEL) newSel;
- (BOOL) bypassSelector:(SEL) select ofClass:(Class) cls throughNewSelector:(SEL) newSel keepOriginalAs:(SEL) original;

- (BOOL) searchAndInstallMenuItems:(NSMenu*) items inAppropriateMenuIn:(NSMenu*) menu;
- (void) installMenuItems:(NSMenu*) items inMenu:(NSMenu*) menu index:(int) i;

@end

@interface NSObject (AfloatCocoaAdditions)
- (void) afloatSendEventOriginal:(NSEvent*) evt;
@end

@interface NSWindow (AfloatCocoaAdditions)
- (id) afloatTopWindow;
@end

@interface NSApplication (AfloatCocoaAdditions)
- (void) afloatSendEvent:(NSEvent*) evt;
@end