/*
** L0AfloatAnimationServices.h
** 
**   Included by all parts of Afloat that
** use animations.
**   It adds methods to the L0AfloatStepAnimator
** class that may tie into Afloat preferences
** to create animators.
** 
** 
**   This source file is part of Afloat and is
** subject to the terms of a (BSD) license.
** 
** Copyright © 2006, Emanuele Vulcano.
** 
** The license should have been distributed
** along with this source file. If it hasn't,
** please see the Afloat development site at
** <http://millenomi.altervista.org/Afloat/Next>
** or contact the main developer at
** <millenomi+afloatlicense@gmail.com>.
*/

#import <Cocoa/Cocoa.h>
#import "L0AfloatStepAnimator.h"

#import "L0AfloatSimpleStepAnimator.h"
#import "L0AfloatMulticastStepAnimator.h"
#import "L0AfloatWindowAlphaAnimation.h"
#import "L0AfloatWindowFrameAnimation.h"

@interface L0AfloatStepAnimator (L0AfloatOnlyAdditions)

+ (id) slowAnimator;
+ (id) normalAnimator;
+ (id) quickAnimator;

@end
