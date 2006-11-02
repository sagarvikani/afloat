//
//  AfloatImplementation.m
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import "AfloatImplementation.h"


@implementation AfloatImplementation

- (BOOL) performInstallOnMainThread { return NO; }

- (NSArray*) windows { return [NSArray array]; }

- (id /* an AfloatWindow */) focusedWindow { return nil; }

+ (id) sharedInstance {
	static id me = nil;
	if (!me)
		me = [self new];
	
	return me;
}

@end
