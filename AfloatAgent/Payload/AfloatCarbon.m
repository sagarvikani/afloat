/*
 *  AfloatCarbon.c
 *  AfloatAgent
 */

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#include "AfloatCarbon.h"
#include <stdio.h>

void AfloatCarbonInstall(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
	// fprintf(stderr, "Afloat was injected in a Carbon application but Carbon support isn't implemented yet.\n");
}

@implementation AfloatCarbon

- (void) performInstallOnMainThread {
	CFRunLoopRef runLoop = (CFRunLoopRef) GetCFRunLoopFromEventLoop(GetMainEventLoop());
	CFRunLoopObserverRef delayer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAfterWaiting, NO, 0, &AfloatCarbonInstall, NULL);
	CFRunLoopAddObserver(runLoop, delayer, kCFRunLoopDefaultMode);
	CFRelease(delayer);
}

@end
