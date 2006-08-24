/*
** L0AfloatModule.m
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

#import "L0AfloatModule.h"


@implementation L0AfloatModule

- (BOOL) willValidateMenuItem:(NSMenuItem*) item forWindow:(NSWindow*) wnd shouldEnable:(BOOL*) shouldEnable {
	return NO;
}

- (BOOL) willHandleEvent:(NSEvent*) evt {
	return NO;
}

@end
