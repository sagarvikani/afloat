/*
** L0AfloatMulticastStepAnimator.m
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

#import "L0AfloatMulticastStepAnimator.h"


@implementation L0AfloatMulticastStepAnimator

- (id) initWithAnimations:(NSArray*) anis duration:(NSTimeInterval) duration steps:(unsigned int) steps {
	if (self = [super initWithDuration:duration steps:steps])
		[self setAnimations:anis];
	
	return self;
}

- (NSArray*) animations { return _anis; }
- (void) setAnimations:(NSArray*) anis {
	if (anis != _anis) {
		[_anis release];
		_anis = [anis copy];
	}
}

- (void) dealloc {
	[self setAnimations:nil];
	[super dealloc];
}

- (L0SlideRecoveryStrategy) slideRecoveryStrategy {
	NSArray* anis = [self animations];
	if ([anis count] == 0)
		return L0AllowNoStrategy;
	if ([anis count] == 1)
		return [[anis objectAtIndex:0] slideRecoveryStrategy];
	
	L0SlideRecoveryStrategy stra = [[anis objectAtIndex:0] slideRecoveryStrategy];
	int i;
	for (i = 1; i < [anis count]; i++)
		stra = stra & [[anis objectAtIndex:i] slideRecoveryStrategy];
	
	return stra;
}

- (void) prepareAnimation {
	NSArray* anis = [self animations];
	int i = [anis count];
	while (--i >= 0)
		[[anis objectAtIndex:i] willBegin];
}

- (void) animateAtProgress:(float) progress sliding:(BOOL) sliding {
	NSArray* anis = [self animations];
	int i = [anis count];
	while (--i >= 0)
		[[anis objectAtIndex:i] performAt:progress sliding:sliding];
}

- (void) endAnimation {
	NSArray* anis = [self animations];
	int i = [anis count];
	while (--i >= 0)
		[[anis objectAtIndex:i] didEnd];
}

@end
