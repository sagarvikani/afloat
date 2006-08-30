/*
** L0AfloatWindowGhoster.m
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


#import "L0AfloatWindowGhoster.h"
#import "L0AfloatWindowFloater.h"
#import "L0Afloat.h"

@implementation L0AfloatWindowGhoster

- (BOOL) isGhost {
	return [[self window] ignoresMouseEvents];
}

- (void) setGhost:(BOOL) ghost {
	L0AfloatWindowFloater* flt = [L0AfloatWindowFloater floaterForWindow:[self window]];
	if (ghost) {
		[flt setTransparency:L0AfloatTranslucent];
		[flt setAlwaysOnTop:YES];
		[flt suspendMouseTracking];
		[[self window] setIgnoresMouseEvents:YES];
	} else {
		if ([flt transparency] == L0AfloatTranslucent)
			[flt setTransparency:L0AfloatOpaque];
		[flt setAlwaysOnTop:NO];
		[flt resumeMouseTracking];
		[[self window] setIgnoresMouseEvents:NO];
	}
}

- (BOOL) willValidateMenuItem:(NSMenuItem*) item forWindow:(NSWindow*) wnd shouldEnable:(BOOL*) shouldEnable {
	if ([item action] == @selector(L0Afloat_windowGhosterMakeGhost:)) {
		*shouldEnable = [self isGhost];
		[item setState:[self isGhost]? NSOnState : NSOffState];
		return YES;
	}
	
	return NO;
}

+ (id) ghosterForWindow:(NSWindow*) wnd {
	return [[L0Afloat sharedInstance] findOrCreateModuleOfClass:self forWindow:wnd];
}

@end

@implementation NSApplication (L0AfloatWindowGhosterAdditions)

- (IBAction) L0Afloat_windowGhosterMaterializeAllGhosts:(id) sender {
	NSEnumerator* enu = [[self windows] objectEnumerator];
	NSWindow* wnd;
	while (wnd = [enu nextObject]) {
		[[L0AfloatWindowGhoster ghosterForWindow:wnd] setGhost:NO];
	}
}

@end

@implementation NSWindow (L0AfloatWindowGhosterAdditions)

- (IBAction) L0Afloat_windowGhosterMakeGhost:(id) sender {
	L0AfloatWindowGhoster* ghost = [L0AfloatWindowGhoster ghosterForWindow:self];
	[ghost setGhost:![ghost isGhost]];
}

@end