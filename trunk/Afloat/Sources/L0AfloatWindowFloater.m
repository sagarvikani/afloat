/*
** L0AfloatWindowFloater.m
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

#import "L0AfloatWindowFloater.h"
#import "L0Afloat.h"

#import "L0AfloatAnimationServices.h"
#import "L0AfloatTransparencyUI.h"

@implementation L0AfloatWindowFloater

- (void) setAlwaysOnTop:(BOOL) top {
	NSWindow* wnd = [self window];
	if ([wnd isKindOfClass:[NSPanel class]]) {
		NSBeep();
		return;
	}
	
	if ([wnd level] == NSNormalWindowLevel && top)
		[wnd setLevel:NSFloatingWindowLevel];
	else if ([wnd level] == NSFloatingWindowLevel && !top)
		[wnd setLevel:NSNormalWindowLevel];
}

- (BOOL) isAlwaysOnTop {
	return [[self window] level] == NSFloatingWindowLevel;
}

////////////////

- (void) setFloating:(BOOL) floating {
	[self setAlwaysOnTop:floating];
	[self setTransparency:L0AfloatTranslucent];
}
- (BOOL) isFloating {
	return [self isAlwaysOnTop];
}

///////////////

- (id) initForWindow:(NSWindow*) wnd {
	if (self = [super initForWindow:wnd])
		transparency = (int)[self transparencyFromAlpha:[[self window] alphaValue]];
	
	return self;
}

- (int) transparencyFromAlpha:(float) alpha {
	int transp = (int)(100 - (100.0 * alpha));
	if (transp > 90) transp = 90;
	if (transp < 10) transp = 10;
	return transp;
}

- (float) alphaFromTransparency:(int) transp {
	if (transp > 90) transp = 90;
	if (transp < 10) transp = 10;
	
	return ((100 - transp) / 100.0);	
}

- (int) transparency { return transparency; }
- (void) setTransparency:(int) transp {
	float alpha = [self alphaFromTransparency:transp];
	// [[self window] setAlphaValue:alpha];
	
	L0AfloatSimpleStepAnimator* ani = [L0AfloatSimpleStepAnimator normalAnimator];
	L0AfloatWindowAlphaAnimation* alphaAni = [[L0AfloatWindowAlphaAnimation alloc] initForWindow:[self window] fromAlpha:[window alphaValue] toAlpha:alpha];
	[ani setAnimation:alphaAni];
	[ani run];
	[alphaAni release];
	
	if (transp != L0AfloatOpaque)
		[self beginMouseTracking];
	else
		[self endMouseTracking];
	
	transparency = transp;
}

- (void) beginMouseTracking {
	if (windowTag != 0)
		return;
	
	NSView* view = nil;	
	NSView* titlebarView = [[[self window] standardWindowButton:NSWindowCloseButton] superview];
	if (titlebarView)
		view = titlebarView;
	else
		view = [[self window] contentView];
	
	windowTag = [view addTrackingRect:[view frame] owner:self userData:NULL assumeInside:NO];
}

- (void) endMouseTracking {
	if (windowTag == 0)
		return;
	
	NSView* view = nil;	
	NSView* titlebarView = [[[self window] standardWindowButton:NSWindowCloseButton] superview];
	if (titlebarView)
		view = titlebarView;
	else
		view = [[self window] contentView];
	
	[view removeTrackingRect:windowTag];
	windowTag = 0;
	[self resumeMouseTracking];
}

- (void) suspendMouseTracking {
	trackingSuspended = YES;
}

- (void) resumeMouseTracking {
	trackingSuspended = NO;
}

- (void) mouseEntered:(NSEvent *) event {
	//NSLog(@"in:%@", event);
	if (trackingSuspended)
		return;
	
	L0AfloatSimpleStepAnimator* ani = [L0AfloatSimpleStepAnimator quickAnimator];
	L0AfloatWindowAlphaAnimation* alphaAni = [[L0AfloatWindowAlphaAnimation alloc] initForWindow:[self window] fromAlpha:[window alphaValue] toAlpha:1.0];
	[ani setAnimation:alphaAni];
	[ani run];
	[alphaAni release];
}

- (void) mouseExited:(NSEvent*) event {
	//NSLog(@"out:%@", event);
	if (trackingSuspended)
		return;
	
	[self setTransparency:transparency];
}

- (void) dealloc {
	[self endMouseTracking];
	[super dealloc];
}

///////////////

- (BOOL) willValidateMenuItem:(NSMenuItem*) item forWindow:(NSWindow*) wnd shouldEnable:(BOOL*) shouldEnable {
	if ([item action] == @selector(L0Afloat_windowFloaterToggleAlwaysOnTop:)) {
		*shouldEnable = (![wnd isKindOfClass:[NSPanel class]]);
		[item setState:[self isAlwaysOnTop]? NSOnState : NSOffState];
		return YES;
	}
	
	return NO;
}

+ (L0AfloatWindowFloater*) floaterForWindow:(NSWindow*) wnd {
	return (L0AfloatWindowFloater*) [[L0Afloat sharedInstance]
		findOrCreateModuleOfClass:self forWindow:wnd];
}

@end

@implementation NSWindow (L0AfloatWindowFloaterAdditions)

- (IBAction) L0Afloat_windowFloaterToggleAlwaysOnTop:(id) sender {
	L0AfloatWindowFloater* flt = [L0AfloatWindowFloater floaterForWindow:self];
	[flt setAlwaysOnTop:![flt isAlwaysOnTop]];
}

- (IBAction) L0Afloat_windowFloaterSetOpaque:(id) sender {
	L0AfloatWindowFloater* flt = [L0AfloatWindowFloater floaterForWindow:self];
	[flt setTransparency:L0AfloatOpaque];
}

- (IBAction) L0Afloat_windowFloaterSetTranslucent:(id) sender {
	L0AfloatWindowFloater* flt = [L0AfloatWindowFloater floaterForWindow:self];
	[flt setTransparency:L0AfloatTranslucent];	
}

- (IBAction) L0Afloat_windowFloaterSetAlmostInvisible:(id) sender {
	L0AfloatWindowFloater* flt = [L0AfloatWindowFloater floaterForWindow:self];
	[flt setTransparency:L0AfloatAlmostInvisible];
}

- (IBAction) L0Afloat_windowFloaterShowTransparencyPanel:(id) sender {
	L0AfloatTransparencyUI* ui = [[L0AfloatTransparencyUI alloc] initWithTargetWindow:self];
	[ui beginDocumentModalPanel:self];
	[ui autorelease];
}

@end