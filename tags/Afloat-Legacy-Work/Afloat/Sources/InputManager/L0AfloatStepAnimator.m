/*
** L0AfloatStepAnimator.m
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

#import "L0AfloatStepAnimator.h"


@implementation L0AfloatStepAnimator

- (id) initWithDuration:(NSTimeInterval) duration steps:(unsigned int) steps {
	if (self = [super init]) {
		[self setDuration:duration];
		[self setSteps:steps];
	}
	
	return self;
}

- (NSTimeInterval) duration { return _duration; }
- (unsigned int) steps { return _steps; }

- (void) setDuration:(NSTimeInterval) duration { _duration = duration; }
- (void) setSteps:(unsigned int) steps { _steps = steps; }

- (void) prepareAnimation {}
- (void) animateAtProgress:(float) progress sliding:(BOOL) sliding {}
- (void) endAnimation {}

- (L0SlideRecoveryStrategy) slideRecoveryStrategy { return L0AllowSkipRecovery; }

- (void) run {
	_running = YES;
	unsigned int i, s = [self steps];
	
	NSTimeInterval d = [self duration], elapsed, lastElapsed = 0, stopwatch, stepDelta = d/(double)s;
	NSDate* startDate = [NSDate date];
	BOOL allowSkip = [self slideRecoveryStrategy] & L0AllowSkipRecovery;
	
	[self prepareAnimation];
	
	BOOL sliding = NO;
	for (i = 1; i <= s && _running; i++) {
		float progress = (float) i / (float) s;
		[self animateAtProgress:progress sliding:sliding];
		elapsed = -[startDate timeIntervalSinceNow];
		
		//NSLog(@"about to sleep for %d nanos", (int) (stepDelta * 1000000));
		if ((stopwatch = (elapsed - lastElapsed)) < stepDelta) {
			usleep((int) ((stepDelta - stopwatch) * 1000000));
			sliding = NO;
		} else if (allowSkip) {
			i += (s / 10); sliding = YES;
		}
		
		//NSLog(@"elapsed %f, lastElapsed %f, stopwatch %f, stepDelta %f", elapsed, lastElapsed, stopwatch, stepDelta);
		lastElapsed = elapsed;
	}
	
	[self endAnimation];
	
	_running = NO;
}

- (void) stop { _running = NO; }

@end
