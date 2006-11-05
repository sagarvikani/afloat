//
//  AfloatAnimator.h
//  AfloatAgent
//
//  Created by ∞ on 04/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

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
- (void) runWithinMainThread;

@end

@interface AfloatKVCAnimation : NSObject <AfloatAnimation>

- (id) initWithObject:(id) object key:(NSString*) key fromValue:(NSNumber*) value toValue:(NSNumber*) tovalue;
- (void) performAnimation:(float) progress;

@end