/*
** L0AfloatMulticastStepAnimator.h
** 
**   A multicast animator -- a sligthly more
** complex implementation of a step animator that
** sends progress messages to multiple animations
** at every step. If all of them can perform well
** fast enough, it can be used to simulate
** "simultaneous" animation being shown together.
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

@interface L0AfloatMulticastStepAnimator : L0AfloatStepAnimator {
	NSArray* _anis;
}

- (id) initWithAnimations:(NSArray*) anis duration:(NSTimeInterval) duration steps:(unsigned int) steps;
- (NSArray*) animations;
- (void) setAnimations:(NSArray*) anis;


- (void) prepareAnimation;
- (void) animateAtProgress:(float) progress sliding:(BOOL) sliding;
- (void) endAnimation;

- (L0SlideRecoveryStrategy) slideRecoveryStrategy;

@end
