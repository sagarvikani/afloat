//
//  AfloatPayloadEntryPoint.m
//  AfloatAgent
//
//  Created by ∞ on 23/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AfloatPayloadEntryPoint.h"
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

#import "AfloatCarbon.h"
#import "AfloatCocoa.h"

void AfloatPayloadEntryPoint() /* __attribute__((constructor)) */ {	
	// we ensure that Afloat gets installed in the main thread of the
	// app. NSApp == nil might not work, but is a good indicator of
	// the Cocoainess/Carboniness of the app we're in.
	// to be extra sure, we also wait for the next spin of the
	// main run loop.
	
	if (NSApp != nil) // Cocoa has a nice one-liner for this.
		[[AfloatCocoa sharedInstance] performSelectorOnMainThread:@selector(install) withObject:nil waitUntilDone:NO];
	else { // Carbon does NOT have a nice one-liner for this, but anyway...
		CFRunLoopRef runLoop = (CFRunLoopRef) GetCFRunLoopFromEventLoop(GetMainEventLoop());
		CFRunLoopObserverRef delayer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAfterWaiting, NO, 0, &AfloatCarbonInstall, NULL);
		CFRunLoopAddObserver(runLoop, delayer, kCFRunLoopDefaultMode);
		CFRelease(delayer);
	}
}