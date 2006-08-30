/*
** L0AfloatWindowTransitions.m
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

#import "L0AfloatWindowTransitions.h"
#import "L0Afloat.h"

#import "L0AfloatAnimationServices.h"
#import "L0AfloatWindowFloater.h"

@implementation L0AfloatWindowTransitions

+ (id) sharedInstance {
	static id myself = nil;
	if (!myself)
		myself = [[self alloc] init];

	return myself;
}

- (id) init {
	if (self = [super init])
		[[L0Afloat sharedInstance] bypassSelector:@selector(orderWindow:relativeTo:) ofClass:[NSWindow class] throughNewSelector:@selector(L0Afloat_orderWindow:relativeTo:) keepOriginalAs:@selector(L0Afloat_appKitOrderWindow:relativeTo:)];
	
	return self;
}

@end

@implementation NSWindow (L0AfloatWindowTransitionsAdditions)

- (void) L0Afloat_orderWindow:(NSWindowOrderingMode) order relativeTo:(int) wnd {
	if (![self isVisible] && order != NSWindowOut) {
		float alpha = [self alphaValue];
		[self setAlphaValue:0];
		L0AfloatWindowAlphaAnimation* alphaAni = [[L0AfloatWindowAlphaAnimation alloc] initForWindow:self fromAlpha:0 toAlpha:alpha];
		NSRect frame = [self frame];
		frame.origin.y += 10;
		L0AfloatWindowFrameAnimation* frameAni = [[L0AfloatWindowFrameAnimation alloc] initForWindow:self fromFrame:frame toFrame:[self frame]];
		
		L0AfloatMulticastStepAnimator* ani = [L0AfloatMulticastStepAnimator normalAnimator];
		[ani setAnimations:[NSArray arrayWithObjects:alphaAni, frameAni, nil]];

		[self L0Afloat_appKitOrderWindow:order relativeTo:wnd];
		[ani run];
		
		[alphaAni release];
		[frameAni release];
	} else if ([self isVisible] && order == NSWindowOut) {
		float alpha = [self alphaValue];
		L0AfloatWindowAlphaAnimation* alphaAni = [[L0AfloatWindowAlphaAnimation alloc] initForWindow:self fromAlpha:alpha toAlpha:0];
		NSRect frame = [self frame];
		frame.origin.y += 10;
		L0AfloatWindowFrameAnimation* frameAni = [[L0AfloatWindowFrameAnimation alloc] initForWindow:self fromFrame:[self frame] toFrame:frame];
		
		L0AfloatMulticastStepAnimator* ani = [L0AfloatMulticastStepAnimator quickAnimator];
		[ani setAnimations:[NSArray arrayWithObjects:alphaAni, frameAni, nil]];
		
		[ani run];
		[self L0Afloat_appKitOrderWindow:NSWindowOut relativeTo:wnd];
		[self setAlphaValue:alpha];
		
		[alphaAni release];
		[frameAni release];
	} else
		[self L0Afloat_appKitOrderWindow:order relativeTo:wnd];
}

@end