//
//  AfloatPayloadEntryPoint.m
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


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
	
	Class implClass = nil;
	
	if (NSApp != nil)
		implClass = [AfloatCocoa class];
	else
		implClass = [AfloatCarbon class];
	
	[(AfloatImplementation*)[implClass sharedInstance] performInstallOnMainThread];
}
