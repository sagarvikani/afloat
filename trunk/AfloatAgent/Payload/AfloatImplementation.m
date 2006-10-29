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

+ (id) sharedInstance {
	static id me = nil;
	if (!me)
		me = [self new];
	
	return me;
}

@end
