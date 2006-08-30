/*
** L0AfloatSimpleStepAnimator.h
** 
**   A simple step animator -- a step animator
** that sends messages to a single animation.
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
#import "L0AfloatAni.h"

@interface L0AfloatSimpleStepAnimator : L0AfloatStepAnimator {
	L0AfloatAni* _ani;
}

- (id) initWithAnimation:(L0AfloatAni*) ani duration:(NSTimeInterval) duration steps:(unsigned int) steps;

- (L0AfloatAni*) animation;
- (void) setAnimation:(L0AfloatAni*) ani;

@end
