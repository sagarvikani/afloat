//
//  AfloatWindowAlphaAnimation.m
//  AfloatAgent
//
//  Created by ° on 13/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AfloatWindowAlphaAnimation.h"


@implementation AfloatWindowAlphaAnimation

- (id) initForWindow:(id) wnd fromAlpha:(float) fa toAlpha:(float) ta {
	if (self = [super init]) {
		animatedWindow = [wnd retain];
		from = fa;
		to = ta;
	}
	
	return self;
}

+ (id) animationForWindow:(id) wnd fromAlpha:(float) fa toAlpha:(float) ta {
	return [[[self alloc] initForWindow:wnd fromAlpha:fa toAlpha:ta] autorelease];
}

- (void) dealloc {
	[animatedWindow release];
	[super dealloc];
}

- (void) performAnimation:(float) progress {
	[animatedWindow setAlphaValue:(to - from) * progress];
}

@end
