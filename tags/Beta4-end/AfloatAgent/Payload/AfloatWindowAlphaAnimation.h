//
//  AfloatWindowAlphaAnimation.h
//  AfloatAgent

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import <Cocoa/Cocoa.h>

#import "AfloatAnimator.h"

@interface AfloatWindowAlphaAnimation : NSObject <AfloatAnimation> {
	id animatedWindow;
	float from;
	float to;
	
	float lastProgress;
}

+ (id) animationForWindow:(id) wnd fromAlpha:(float) fa toAlpha:(float) ta;
- (id) initForWindow:(id) wnd fromAlpha:(float) fa toAlpha:(float) ta;

@end
