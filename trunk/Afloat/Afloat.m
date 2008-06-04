/*
Copyright (c) 2008, Emanuele Vulcano
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Afloat.h"
#import <math.h>
#import "JRSwizzle.h"

#import "AfloatStorage.h"
#import "AfloatPanelController.h"
#import "AfloatBadgeController.h"
#import "Afloat_AfloatNagging.h"

#define kAfloatTranslucentAlphaValue (0.7f)
#define kAfloatMinimumAlphaValue (0.3f)
#define kAfloatOverlayAlphaValue (0.4f)

#define kAfloatLastAlphaValueKey @"AfloatLastAlphaValue"
#define kAfloatTrackingAreaKey @"AfloatTrackingArea"
#define kAfloatTrackedViewKey @"AfloatTrackedView"
#define kAfloatLastSpacesSettingKey @"AfloatLastSpacesSetting"
#define kAfloatAlphaValueAnimationEnabledKey @"AfloatAlphaValueAnimationEnabled"
#define kAfloatIsOverlayKey @"AfloatIsOverlay"

///////////////////////////////////////

@interface NSApplication (Afloat)
- (void) afloat_sendEvent:(NSEvent*) event;
@end

///////////////////////////////////////

@interface Afloat ()

- (NSUInteger) indexForInstallingInMenu:(NSMenu*) m; 
- (void) install;

- (void) beginTrackingWindow:(NSWindow*) w;
- (void) endTrackingWindow:(NSWindow*) w;

- (BOOL) isWindowIgnoredByAfloat:(NSWindow*) w;

@end


@implementation Afloat

+ (id) sharedInstance {
	static id myself = nil;
	if (!myself) myself = [self new];
	return myself;
}

+ (void) load {
	static BOOL alreadyLoaded = NO;
	if (alreadyLoaded) return; alreadyLoaded = YES;
	
	[[self sharedInstance] install];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		AfloatStorage* shared = [AfloatStorage sharedStorage];
		shared.delegate = self;
	}
	return self;
}

- (void) storage:(AfloatStorage*) s willRemoveMutableDictionary:(NSMutableDictionary*) d forWindow:(NSWindow*) w {
	
	[self endTrackingWindow:w];
	
}

- (void) install {
	// Set up menu items ---------------------------------------
	
	NSMenu* menu = [NSApp windowsMenu];
	if (!menu) {
		L0Log(@"%@ found no Window menu in NSApp %@", self, NSApp);
		return;
	}
	
	NSUInteger index = [self indexForInstallingInMenu:menu];
	
	[NSBundle loadNibNamed:@"Afloat" owner:self];
	
	NSImage* badge = [[NSImage alloc] initWithContentsOfFile:
					  [[self bundle] pathForImageResource:@"AfloatMenuBadge"]];
	
	NSArray* a = [NSArray arrayWithArray:[_menuWithItems itemArray]];
	
	if (index < [menu numberOfItems] && ![[menu itemAtIndex:index] isSeparatorItem])
		[menu insertItem:[NSMenuItem separatorItem] atIndex:index];

	for (NSMenuItem* item in a) {
		[_menuWithItems removeItem:item];
		
		if (![item isSeparatorItem])
			[item setImage:badge];
		
		[menu insertItem:item atIndex:index];
		index++;
	}

	if (index < [menu numberOfItems] && ![[menu itemAtIndex:index] isSeparatorItem])
		[menu insertItem:[NSMenuItem separatorItem] atIndex:index];

	[badge release];
	
	[_menuWithItems release]; _menuWithItems = nil;
	
	// Set up swizzling sendEvents: in NSApplication --------------
	
	NSError* err = nil;
	BOOL result = [NSApplication jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(afloat_sendEvent:) error:&err];
	
	if (!result) // we want this to be visible to end users, too :)
		NSLog(@"<Afloat> Could not install events filter (error: %@). Some features may not work.", err);
	
	// Nag, nag, nag, nag, nag, nag, nag, nag...
	// delayed -- PS already slows down app launch enough.
	//[self checkForNagOnInstall];
	[self performSelector:@selector(checkForNagOnInstall) withObject:nil afterDelay:7.0];
}

- (NSUInteger) indexForInstallingInMenu:(NSMenu*) m {
	NSUInteger i = 0, lastSeparator = -1;
	for (NSMenuItem* item in [m itemArray]) {
		if ([item isSeparatorItem])
			lastSeparator = i;
		else if ([item action] == @selector(arrangeInFront:))
			return i + 1;
		
		i++;
	}
	
	if (lastSeparator != -1)
		return lastSeparator + 1;
	else
		return 0;
}

- (NSBundle*) bundle {
	return [NSBundle bundleForClass:[self class]];
}

- (IBAction) toggleAlwaysOnTop:(id) sender {
	NSWindow* c = [self currentWindow];
	L0Log(@"window = %@ titled %@", c, [c title]);
	L0Log(@"windows = %@", [NSApp orderedWindows]);
	for (NSWindow* w in [NSApp orderedWindows]) {
		L0Log(@"titled = %@", [w title]);
		L0Log(@"visible = %d", [w isVisible]);
	}
	[self setKeptAfloat:![self isWindowKeptAfloat:c] forWindow:c showBadgeAnimation:YES];
}

- (BOOL) validateMenuItem:(NSMenuItem*) item {
	if ([item action] == @selector(toggleAlwaysOnTop:)) {
		NSWindow* c = [self currentWindow];
		if (!c)
			[item setState:NSOffState];
		else
			[item setState:[self isWindowKeptAfloat:c]? NSOnState : NSOffState];
		return c != nil;
	} else if ([item action] == @selector(showWindowFileInFinder:))
		return [[self currentWindow] representedURL]? [[[self currentWindow] representedURL] isFileURL] : NO;
	
	return YES;
}

- (BOOL) isWindowKeptAfloat:(NSWindow*) w {
	return [w level] != NSNormalWindowLevel;
}

- (void) setKeptAfloat:(BOOL) afloat forWindow:(NSWindow*) c showBadgeAnimation:(BOOL) animated {
	L0Log(@"window = %@, will be afloat = %d, was afloat = %d", c, afloat, [self isWindowKeptAfloat:c]);
	BOOL wasAfloat = [self isWindowKeptAfloat:c];		

	if ([c level] == NSNormalWindowLevel && afloat) {
		[c setLevel:NSFloatingWindowLevel];
		
		if (!wasAfloat && animated) {
			L0LogS(@"Starting begin keeping afloat animation...");
			[[AfloatBadgeController badgeControllerForWindow:c] animateWithBadgeType:AfloatBadgeDidBeginKeepingAfloat];
		}

	} else if ([c level] == NSFloatingWindowLevel && !afloat) {
		[c setLevel:NSNormalWindowLevel];
		
		if (wasAfloat && animated) {
			L0LogS(@"Starting end keeping afloat animation...");
			[[AfloatBadgeController badgeControllerForWindow:c] animateWithBadgeType:AfloatBadgeDidEndKeepingAfloat];
		}
	}
	
	if (!afloat && [self isWindowOverlay:c] && !_settingOverlay)
		[self setOverlay:NO forWindow:c animated:animated showBadgeAnimation:NO];
}

- (void) setOnAllSpaces:(BOOL) spaces forWindow:(NSWindow*) c {
	if ([c collectionBehavior] != NSWindowCollectionBehaviorCanJoinAllSpaces && spaces) {
		[AfloatStorage setSharedValue:[NSNumber numberWithUnsignedInteger:[c collectionBehavior]]
							   window:c key:kAfloatLastSpacesSettingKey];
		[c setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	} else {
		NSNumber* n = [AfloatStorage sharedValueForWindow:c key:kAfloatLastSpacesSettingKey];
		NSUInteger setting = NSWindowCollectionBehaviorDefault;
		if (c)
			setting = [n unsignedIntegerValue];
		
		[c setCollectionBehavior:setting];
		[AfloatStorage removeSharedValueForWindow:c key:kAfloatLastSpacesSettingKey];
	}
}

- (BOOL) isWindowOnAllSpaces:(NSWindow*) w {
	return [w collectionBehavior] == NSWindowCollectionBehaviorCanJoinAllSpaces;
}

- (NSWindow*) currentWindow {
	NSWindow* w;
	
	w = [NSApp keyWindow];
	if (![self isWindowIgnoredByAfloat:w]) return w;
	
	w = [NSApp mainWindow];
	if (![self isWindowIgnoredByAfloat:w]) return w;
	
	for (NSWindow* window in [NSApp orderedWindows]) {
		if (![self isWindowIgnoredByAfloat:window])
			return window;
	}
	
	return nil;
}

- (BOOL) isWindowIgnoredByAfloat:(NSWindow*) w {
	return [w isKindOfClass:[NSPanel class]] || ![w isVisible];
}

- (IBAction) makeTranslucent:(id) sender {
	[self setAlphaValue:kAfloatTranslucentAlphaValue forWindow:[self currentWindow] animated:YES];
}

- (IBAction) makeOpaque:(id) sender {
	[self setAlphaValue:1.0 forWindow:[self currentWindow] animated:YES];
}

- (IBAction) makeMoreTransparent:(id) sender {
	[self setAlphaValueByDelta:-0.1 forWindow:[self currentWindow] animate:NO];
}

- (IBAction) makeLessTransparent:(id) sender {
	[self setAlphaValueByDelta:0.1 forWindow:[self currentWindow] animate:NO];
}

- (float) currentAlphaValueForWindow:(NSWindow*) window {
	id alphaValue = [AfloatStorage sharedValueForWindow:window key:kAfloatLastAlphaValueKey];
	return (alphaValue)? [alphaValue floatValue] : [window alphaValue];
}

- (void) setAlphaValueByDelta:(float) delta forWindow:(NSWindow*) window animate:(BOOL) animate {
	if (!window) return;
	
	float a = [self currentAlphaValueForWindow:window];	
	[self setAlphaValue:a + delta forWindow:window animated:animate];
}

- (void) setAlphaValue:(float) f forWindow:(NSWindow*) window animated:(BOOL) animate {
	if (!window) return;
	
	if (f > 1.0)
		f = 1.0;
	else if (f < kAfloatMinimumAlphaValue)
		f = kAfloatMinimumAlphaValue;
	
	[AfloatStorage setSharedValue:[NSNumber numberWithFloat:f] window:window key:kAfloatLastAlphaValueKey];
	
	if (f == 1.0)
		[self endTrackingWindow:window];
	else
		[self beginTrackingWindow:window];
	
	if (animate) {
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.3];
			[[window animator] setAlphaValue:f];
		[NSAnimationContext endGrouping];
	} else
		[window setAlphaValue:f];
}

- (void) setAlphaValueAnimatesOnMouseOver:(BOOL) animates forWindow:(NSWindow*) window {
	if (animates)
		[AfloatStorage setSharedValue:[NSNumber numberWithBool:YES] window:window key:kAfloatAlphaValueAnimationEnabledKey];
	else
		[AfloatStorage removeSharedValueForWindow:window key:kAfloatAlphaValueAnimationEnabledKey];
}

- (BOOL) alphaValueAnimatesOnMouseOverForWindow:(NSWindow*) window {
	return [AfloatStorage sharedValueForWindow:window key:kAfloatAlphaValueAnimationEnabledKey] != nil;
}

- (void) beginTrackingWindow:(NSWindow*) window {
	L0Log(@"window = %@", window);
	if ([AfloatStorage sharedValueForWindow:window key:kAfloatTrackingAreaKey])
		return;
	
	NSView* v = [[window contentView] superview];
	NSTrackingArea* tracker = [[NSTrackingArea alloc] initWithRect:[v bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect owner:self userInfo:nil];
	[v addTrackingArea:tracker];
	
	[AfloatStorage setSharedValue:tracker window:window key:kAfloatTrackingAreaKey];
	[AfloatStorage setSharedValue:v window:window key:kAfloatTrackedViewKey];
	
	L0Log(@"tracker = %@ view = %@", tracker, v);
}

- (void) endTrackingWindow:(NSWindow*) window {
	L0Log(@"window = %@", window);
	NSTrackingArea* area = [AfloatStorage sharedValueForWindow:window key:kAfloatTrackingAreaKey];
	NSView* view = [AfloatStorage sharedValueForWindow:window key:kAfloatTrackedViewKey];
	if (view && area)
		[view removeTrackingArea:area];
	
	[AfloatStorage removeSharedValueForWindow:window key:kAfloatTrackingAreaKey];
	[AfloatStorage removeSharedValueForWindow:window key:kAfloatTrackedViewKey];
}

- (void) mouseEntered:(NSEvent*) e {
	L0Log(@"%@", e);
	
	if (![self alphaValueAnimatesOnMouseOverForWindow:[e window]]) return;
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.2];
	[[[e window] animator] setAlphaValue:1.0];
	[NSAnimationContext endGrouping];
}

- (void) mouseExited:(NSEvent*) e {
	L0Log(@"%@", e);
	
	if (![self alphaValueAnimatesOnMouseOverForWindow:[e window]]) return;
	
	id alphaValue = [AfloatStorage sharedValueForWindow:[e window] key:kAfloatLastAlphaValueKey];
	if (!alphaValue) return;
	
	float a = [alphaValue floatValue];
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.5];
	[[[e window] animator] setAlphaValue:a];
	[NSAnimationContext endGrouping];	
}

- (IBAction) showAdjustEffectsPanel:(id) sender {
	NSWindow* w = [self currentWindow];
	if (!w) { NSBeep(); return; }
	
	AfloatPanelController* ctl = [AfloatPanelController panelControllerForWindow:w];
	[ctl toggleWindow:self];
}												 

- (void) setOverlay:(BOOL) overlay forWindow:(NSWindow*) w animated:(BOOL) animated showBadgeAnimation:(BOOL) badge {
	_settingOverlay = YES;
	
	if (overlay) {
		[self setKeptAfloat:YES forWindow:w showBadgeAnimation:badge];
		[self setAlphaValue:kAfloatOverlayAlphaValue forWindow:w animated:animated];
		[self setAlphaValueAnimatesOnMouseOver:NO forWindow:w];
		[w setIgnoresMouseEvents:YES];
		[AfloatStorage setSharedValue:[NSNumber numberWithBool:YES] window:w key:kAfloatIsOverlayKey];
	} else {
		if ([w alphaValue] <= kAfloatOverlayAlphaValue)
			[self setAlphaValue:1.0 forWindow:w animated:animated];
		// [self setAlphaValueAnimatesOnMouseOver:YES forWindow:w];
		[self setKeptAfloat:NO forWindow:w showBadgeAnimation:badge];
		[w setIgnoresMouseEvents:NO];
		[AfloatStorage removeSharedValueForWindow:w key:kAfloatIsOverlayKey];
	}
	
	_settingOverlay = NO;
}

- (BOOL) isWindowOverlay:(NSWindow*) overlay {
	return [AfloatStorage sharedValueForWindow:overlay key:kAfloatIsOverlayKey] != nil;
}

- (IBAction) disableAllOverlays:(id) sender {
	[self disableAllOverlaysShowingBadgeAnimation:YES];
}

- (void) disableAllOverlaysShowingBadgeAnimation:(BOOL) badge {
	for (NSWindow* w in [NSApp orderedWindows]) {
		if (![self isWindowIgnoredByAfloat:w])
			[self setOverlay:NO forWindow:w animated:YES showBadgeAnimation:badge];
	}
}

- (IBAction) showWindowFileInFinder:(id) sender {
	NSURL* url = [[self currentWindow] representedURL];
	if (!url || ![url isFileURL]) { NSBeep(); return; }
	
	[[NSWorkspace sharedWorkspace] selectFile:[url path] inFileViewerRootedAtPath:@""];
}

@end

@implementation NSApplication (Afloat)

- (void) afloat_sendEvent:(NSEvent*) evt {
	unsigned mods = [evt modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    NSPoint ori;
    Afloat* hub = [Afloat sharedInstance];
	NSWindow* wnd;
    
    if (mods == (NSCommandKeyMask | NSControlKeyMask)) {
        
        switch ([evt type]) {
// The three-finger swipe gesture on a multitouch (MB Air/Pro) trackpad
#define kAfloatNSSwipeGestureEvent (31)
			case kAfloatNSSwipeGestureEvent: {
				NSWindow* w = [evt window];
				if ([hub isWindowIgnoredByAfloat:w]) w = [hub currentWindow];
				if (w) {
					if ([evt deltaY] > 0)
						[hub setKeptAfloat:YES forWindow:w showBadgeAnimation:YES];
					else if ([evt deltaY] < 0)
						[hub setKeptAfloat:NO forWindow:w showBadgeAnimation:YES];
					return; // filter it
				}
			}
				
            case NSLeftMouseDown:
                return; // filter it
                
            case NSLeftMouseDragged:
                if (!(wnd = [hub currentWindow])) return;
				
                ori = [wnd frame].origin;
                ori.x += [evt deltaX];
                ori.y -= [evt deltaY];
                [wnd setFrameOrigin:ori];
                return; // filter it once done
                
			case NSLeftMouseUp:
				return; // filter it
				
			case NSScrollWheel:
				[hub setAlphaValueByDelta:([evt deltaY] * 0.10) forWindow:[hub currentWindow] animate:NO];
				return; // filter it
				
        }
    }
    
    // If we didn't return above, we return the event to its
    // regular code path.
    [self afloat_sendEvent:evt];
}

@end