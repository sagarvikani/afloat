/*
 *  AfloatCarbon.c
 *  AfloatAgent
 */

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */

#include "AfloatCarbon.h"
#include <stdio.h>

void AfloatCarbonInstall(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
	fprintf(stderr, "install(erei) per un'app carbon\n");
}

@implementation AfloatCarbon

- (void) performInstallOnMainThread {
	CFRunLoopRef runLoop = (CFRunLoopRef) GetCFRunLoopFromEventLoop(GetMainEventLoop());
	CFRunLoopObserverRef delayer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAfterWaiting, NO, 0, &AfloatCarbonInstall, NULL);
	CFRunLoopAddObserver(runLoop, delayer, kCFRunLoopDefaultMode);
	CFRelease(delayer);
}

@end
