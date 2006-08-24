/*
** L0AfloatAnimationServices.m
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

#import "L0AfloatAnimationServices.h"


@implementation  L0AfloatStepAnimator (L0AfloatOnlyAdditions)

// TODO tie all of these onto the preferences.

+ (id) slowAnimator {
	return [[[self alloc] initWithDuration:1.5 steps:20] autorelease];
}

+ (id) normalAnimator {
	return [[[self alloc] initWithDuration:0.5 steps:20] autorelease];
}

+ (id) quickAnimator {
	return [[[self alloc] initWithDuration:0.25 steps:10] autorelease];
}

@end
