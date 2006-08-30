/*
** L0AfloatAni.h
** 
**   The superclass for all animations.
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

typedef enum {
	L0AllowNoStrategy = 0,
	L0AllowSkipRecovery = 1,
} L0SlideRecoveryStrategy;

@interface L0AfloatAni : NSObject {}

- (void) willBegin;
- (void) didEnd;

- (L0SlideRecoveryStrategy) slideRecoveryStrategy;

- (void) performAt:(float) progress sliding:(BOOL) sliding;
- (void) performAt:(float) progress;

@end
