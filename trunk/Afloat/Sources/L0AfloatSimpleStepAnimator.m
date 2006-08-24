/*
** L0AfloatSimpleStepAnimator.m
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

#import "L0AfloatSimpleStepAnimator.h"


@implementation L0AfloatSimpleStepAnimator

- (id) initWithAnimation:(L0AfloatAni*) ani duration:(NSTimeInterval) duration steps:(unsigned int) steps {
	if (self = [super initWithDuration:duration steps:steps])
		[self setAnimation:ani];
	
	return self;
}

- (L0AfloatAni*) animation { return _ani; }
- (void) setAnimation:(L0AfloatAni*) ani {
	[ani retain]; [_ani release]; _ani = ani;
}

- (void) dealloc {
	[self setAnimation:nil];
	[super dealloc];
}

- (void) prepareAnimation {
	[[self animation] willBegin];
}

- (void) animateAtProgress:(float) progress sliding:(BOOL) sliding {
	[[self animation] performAt:progress sliding:sliding];
}

- (void) endAnimation {
	[[self animation] didEnd];
}

- (L0SlideRecoveryStrategy) slideRecoveryStrategy { return [[self animation] slideRecoveryStrategy]; }

@end
