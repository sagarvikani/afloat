//
//  AfloatCocoa.h
//  AfloatAgent
//
//  Created by ∞ on 23/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AfloatImplementation.h"

@interface AfloatCocoa : AfloatImplementation {}

- (BOOL) renameSelector:(SEL) select ofClass:(Class) cls toNewSelector:(SEL) newSel;
- (BOOL) bypassSelector:(SEL) select ofClass:(Class) cls throughNewSelector:(SEL) newSel keepOriginalAs:(SEL) original;

@end

@interface NSObject (AfloatCocoaAdditions)
- (void) afloatDeallocOriginal;
@end

@interface NSWindow (AfloatCocoaAdditions)
- (void) afloatDealloc;
- (id) afloatTopWindow;
@end
