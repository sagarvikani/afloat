//
//  AfloatAnimator.m

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import "AfloatAnimator.h"
#include <unistd.h>
#define kAfloatAnimatorFramesPerSecond 15

@implementation AfloatAnimator

- (id) initWithApproximateDuration:(NSTimeInterval) dur {
	if (self = [super init]) {
		animations = [NSMutableArray new];
		duration = dur;
	}
	
	return self;
}

- (void) dealloc {
	[animations release];
	[super dealloc];
}

- (void) addAnimation:(id) target {
	[animations addObject:target];
}

- (void) run {
	int frames = kAfloatAnimatorFramesPerSecond / duration;
	NSTimeInterval delta = duration / frames;
	
	// copy the animation functions on the stack so that we don't have to
	// send messages to self->animations or pass through objc_msgsend at each frame.
	
	const SEL theSelector = @selector(performAnimation:);
	
	unsigned i, count = [animations count];
	id allAnis[count];
	IMP allPerforms[count];
	for (i = 0; i < count; i++) {
		allAnis[i] = [animations objectAtIndex:i];
		allPerforms[i] = [(allAnis[i]) methodForSelector:theSelector];
	}
	
	unsigned j; float progress;
	// from this moment on, we must be as quick as possible for each
	// animation step (for j = 0...).
	
	for (i = 0; i < frames; i++) {
		progress = (float) i / (float) frames;
		for (j = 0; j < count; j++)
			// This is actually [[animations objectAtIndex:j] performAnimation:progress];
			(allPerforms[j])(allAnis[j], theSelector, progress);
		usleep(delta * 1000000); // does not take drifting (late frames) into account
	}
	
	if (progress < 1.0) {
		for (j = 0; j < count; j++)
			// This is actually [[animations objectAtIndex:j] performAnimation:1.0];
			(allPerforms[j])(allAnis[j], theSelector, 1.0);
	}
	
}

- (void) runWithinMainThread { NSAssert(false, @"runWithinMainThread"); }

@end
