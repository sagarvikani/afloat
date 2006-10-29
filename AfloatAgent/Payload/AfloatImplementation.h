//
//  AfloatImplementation.h
//  AfloatAgent
//
//  Created by ∞ on 24/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AfloatImplementation : NSObject {}

- (BOOL) installMenuItems:(NSArray* /* of NSMenuItem* */) modelItems;
- (NSArray* /* of id <AfloatWindow> */) windows;
- (id /* <AfloatWindow> */) focusedWindow;

@end
