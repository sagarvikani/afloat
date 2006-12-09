//
//  AfloatImplementation.h
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import <Cocoa/Cocoa.h>

@interface NSObject (AfloatWindowObject)
- (BOOL) alwaysOnTop;
- (void) setAlwaysOnTop:(BOOL) aot;
- (void) beginMouseTrackingWithOwner:(id) owner;
- (void) endMouseTracking;

- (void) setOverlayWindow:(BOOL) ov;
- (BOOL) overlayWindow;

- (void) setIgnoresMouseEvents:(BOOL) ime;
- (BOOL) ignoresMouseEvents;
@end

@interface AfloatImplementation : NSObject {}

- (BOOL) performInstallOnMainThread;

- (NSArray* /* of id <AfloatWindow> */) windows;
- (id /* <AfloatWindow> */) focusedWindow;

+ (id) sharedInstance;

@end
