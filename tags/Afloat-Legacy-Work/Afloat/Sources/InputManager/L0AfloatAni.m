/*
** L0AfloatAni.m
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

#import "L0AfloatAni.h"


@implementation L0AfloatAni

- (void) willBegin {}
- (void) didEnd {}

- (L0SlideRecoveryStrategy) slideRecoveryStrategy { return L0AllowSkipRecovery; }

- (void) performAt:(float) progress sliding:(BOOL) sliding {
	[self performAt:progress];
}

- (void) performAt:(float) progress {}

@end
