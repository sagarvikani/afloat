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
    [drawingTimer release];
    [startDate release];
	[animations release];
    
	[super dealloc];
}

- (void) addAnimation:(id) target {
	[animations addObject:target];
}

- (void) runImmediatly {
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

- (void) run {
    [self retain];
    
    if (drawingTimer) {
        if (![drawingTimer isValid])
            [drawingTimer release];
        else
            return;
    }
    
    drawingTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(_runSingleFrame:) userInfo:nil repeats:YES] retain];
    startDate = [[NSDate alloc] init];
}

- (void) _runSingleFrame:(NSTimer*) timer {
    NSDisableScreenUpdates();
    
    NSTimeInterval elapsed = -[startDate timeIntervalSinceNow];
    float ratio = elapsed / duration;
    
    if (ratio > 1.0) ratio = 1.0;
    
    int i, aniCount = [animations count];
    for (i = 0; i < aniCount; i++)
        [[animations objectAtIndex:i] performAnimation:ratio];
    
    NSEnableScreenUpdates();
    
    if (ratio == 1.0) {
        [startDate release];
        startDate = nil;

        [drawingTimer invalidate];
        [self autorelease];
    }
}

@end
