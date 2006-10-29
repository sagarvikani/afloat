//
//  AfloatImplementation.m
//  AfloatAgent
//
//  Created by ∞ on 24/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AfloatImplementation.h"


@implementation AfloatImplementation

- (BOOL) installMenuItems:(NSArray* /* of NSMenuItem* */) modelItems {
	return NO;
}

- (NSArray*) windows { return [NSArray array]; }

- (id /* an AfloatWindow */) focusedWindow { return nil; }

@end
