/*
** L0AfloatStepAnimator.h
** 
**   This class implements an abstract step
** animator -- an animator that defines a number
** of "steps" to be executed uniformly during
** a given period of time. Exactly how the
** animation is performed is up to the subclasses
** to decide (by implementing the
** -animateAtProgress:sliding: method).
**   The animator also implements some sliding
** prevention -- if the animation runs too slow
** and the sliding prevention policy allows it,
** the animator will skip a number of steps in
** an attempt to compensate (and prevent
** the effective duration from being too
** different than the intended one).
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
#import "L0AfloatAni.h"

#define kL0StepAnimatorReasonableNumberOfSteps 15

@interface L0AfloatStepAnimator : NSObject {
	NSTimeInterval _duration;
	unsigned int _steps;
	
	BOOL _running;
}

- (id) initWithDuration:(NSTimeInterval) duration steps:(unsigned int) steps;

- (NSTimeInterval) duration;
- (unsigned int) steps;

- (void) setDuration:(NSTimeInterval) duration;
- (void) setSteps:(unsigned int) steps;

- (void) run;
- (void) stop;

- (void) prepareAnimation;
- (void) animateAtProgress:(float) progress sliding:(BOOL) sliding;
- (void) endAnimation;

- (L0SlideRecoveryStrategy) slideRecoveryStrategy;

@end
