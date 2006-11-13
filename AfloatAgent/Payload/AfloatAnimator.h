//
//  AfloatAnimator.h

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */

#import <Cocoa/Cocoa.h>

@protocol AfloatAnimation
- (void) performAnimation:(float) progress;
@end

@interface NSObject (AfloatAnimatorEaseCalculator)
- (float) animatorProgressForLinearProgress:(float) progress;
@end

@interface AfloatAnimator : NSObject {
	NSMutableArray* animations;
	NSTimeInterval duration;
}

- (id) initWithApproximateDuration:(NSTimeInterval) duration;

- (void) addAnimation:(id) target;
- (void) run;
// - (void) runWithinMainThread;

@end
