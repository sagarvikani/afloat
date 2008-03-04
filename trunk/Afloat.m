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

#define kAfloatTranslucentAlphaValue (0.7f)
#define kAfloatMinimumAlphaValue (0.1)

#define kAfloatLastAlphaValueKey @"AfloatLastAlphaValue"
#define kAfloatTrackingAreaKey @"AfloatTrackingArea"
#define kAfloatTrackedViewKey @"AfloatTrackedView"

///////////////////////////////////////

@interface NSApplication (Afloat)
- (void) afloat_sendEvent:(NSEvent*) event;
@end

///////////////////////////////////////

@interface Afloat ()

- (NSUInteger) indexForInstallingInMenu:(NSMenu*) m; 
- (void) install;

- (NSWindow*) currentWindow;

- (void) setAlphaValueOfCurrentWindow:(float) f;
- (void) setAlphaValueOfCurrentWindow:(float) f animate:(BOOL) a;
- (void) setAlphaValueOfCurrentWindowByDelta:(float) delta animate:(BOOL) animate;

- (void) beginTrackingWindow:(NSWindow*) w;
- (void) endTrackingWindow:(NSWindow*) w;

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
	
	if ([c level] == NSNormalWindowLevel)
		[c setLevel:NSFloatingWindowLevel];
	else if ([c level] == NSFloatingWindowLevel)
		[c setLevel:NSNormalWindowLevel];
}

- (NSWindow*) currentWindow {
	for (NSWindow* window in [NSApp orderedWindows]) {
		if (![window isKindOfClass:[NSPanel class]])
			return window;
	}
	
	return nil;
}

- (IBAction) makeTranslucent:(id) sender {
	[self setAlphaValueOfCurrentWindow:kAfloatTranslucentAlphaValue];
}

- (IBAction) makeOpaque:(id) sender {
	[self setAlphaValueOfCurrentWindow:1.0];
}

- (IBAction) makeMoreTransparent:(id) sender {
	[self setAlphaValueOfCurrentWindowByDelta:-0.1 animate:YES];
}

- (IBAction) makeLessTransparent:(id) sender {
	[self setAlphaValueOfCurrentWindowByDelta:0.1 animate:YES];
}

- (void) setAlphaValueOfCurrentWindow:(float) f {
	[self setAlphaValueOfCurrentWindow:f animate:YES];
}

- (void) setAlphaValueOfCurrentWindowByDelta:(float) delta animate:(BOOL) animate {
	NSWindow* window = [self currentWindow]; if (!window) return;
	
	float a;
	id alphaValue = [AfloatStorage sharedValueForWindow:window key:kAfloatLastAlphaValueKey];
	a = (alphaValue)? [alphaValue floatValue] : [window alphaValue];
	
	[self setAlphaValueOfCurrentWindow:a + delta animate:animate];
}

- (void) setAlphaValueOfCurrentWindow:(float) f animate:(BOOL) animate {
	NSWindow* window = [self currentWindow]; if (!window) return;
	
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
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.5];
	[[[e window] animator] setAlphaValue:1.0];
	[NSAnimationContext endGrouping];
}

- (void) mouseExited:(NSEvent*) e {
	L0Log(@"%@", e);
	id alphaValue = [AfloatStorage sharedValueForWindow:[e window] key:kAfloatLastAlphaValueKey];
	if (!alphaValue) return;
	
	float a = [alphaValue floatValue];
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.5];
	[[[e window] animator] setAlphaValue:a];
	[NSAnimationContext endGrouping];	
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
				[hub setAlphaValueOfCurrentWindowByDelta:([evt deltaY] * 0.10) animate:NO];
				return; // filter it
				
        }
    }
    
    // If we didn't return above, we return the event to its
    // regular code path.
    [self afloat_sendEvent:evt];
}

@end
