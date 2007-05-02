//
//  AfloatWindowInfo.h
//  AfloatAgent
//
//  Created by ∞ on 01/02/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSMutableDictionary* AfloatGetWindowInfoForWindow(id window);
extern void AfloatSetWindowInfoForWindow(id window, NSString* key, id value);
extern void AfloatClearWindowInfoForWinow(id window);

@interface NSObject (AfloatWindowInfo)

- (void) afloatWillRemoveFromWindow:(NSWindow*) wnd;

@end
