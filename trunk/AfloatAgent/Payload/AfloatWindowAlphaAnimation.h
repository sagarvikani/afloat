//
//  AfloatWindowAlphaAnimation.h
//  AfloatAgent
//
//  Created by ∞ on 13/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AfloatAnimator.h"

@interface AfloatWindowAlphaAnimation : NSObject <AfloatAnimation> {
	id animatedWindow;
	float from;
	float to;
}

+ (id) animationForWindow:(id) wnd fromAlpha:(float) fa toAlpha:(float) ta;
- (id) initForWindow:(id) wnd fromAlpha:(float) fa toAlpha:(float) ta;

@end
