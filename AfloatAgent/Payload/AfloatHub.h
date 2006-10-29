//
//  AfloatHub.h
//  AfloatAgent
//
//  Created by ∞ on 28/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AfloatImplementation.h"

@interface AfloatHub : NSObject {
	NSMutableDictionary* /* AfloatWindow -> NSMutableDictionary* */ windowData;
	id focusedWindow;
}

+ (id) sharedHub;

- (NSMutableDictionary*) infoForWindow:(id /* AfloatWindow */) wnd;
- (void) clearInfoForWindow:(id) wnd;

- (void) willRemoveWindow:(id) wnd;

- (id) focusedWindow;
- (void) setFocusedWindow:(id) wnd;

@end
