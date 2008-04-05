//
//  AfloatPanelController.h
//  AfloatHUD
//
//  Created by ∞ on 04/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AfloatPanelController : NSWindowController {
	NSWindow* _parentWindow;
	float lastAlpha;
}

- (id) initAttachedToWindow:(NSWindow*) window;
+ (id) panelControllerForWindow:(NSWindow*) w;

- (IBAction) hideWindow:(id) sender;
- (IBAction) toggleWindow:(id) sender;

- (IBAction) disableAllOverlays:(id) sender;

@property(retain) NSWindow* parentWindow;
@property float alphaValue;
@property(getter=isKeptAfloat) BOOL keptAfloat;
@property(getter=isOnAllSpaces) BOOL onAllSpaces;
@property(getter=isOverlay) BOOL overlay;
@property BOOL alphaValueAnimatesOnMouseOver;

@property(readonly) BOOL canSetAlphaValueAnimatesOnMouseOver;

@end
