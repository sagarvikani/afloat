#import "AfloatCocoa.h"

#import <objc/objc-class.h>
#import "AfloatHub.h"

@implementation AfloatCocoa

// From SIMBL creator, ...
- (BOOL) renameSelector:(SEL) select ofClass:(Class) cls toNewSelector:(SEL) newSel {
    Method method = nil;
	
    method = class_getInstanceMethod(cls, select);
    if (method == nil)
        return NO;
	
    method->method_name = newSel;
    return YES;
}

- (BOOL) bypassSelector:(SEL) original ofClass:(Class) cls throughNewSelector:(SEL) newSel keepOriginalAs:(SEL) kept {
	BOOL res = [self renameSelector:original ofClass:cls toNewSelector:kept];

	if (res)
		res = [self renameSelector:newSel ofClass:cls toNewSelector:original];
	
	return res;
}

- (id) init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeFocusedWindow:) name:NSWindowDidBecomeMainNotification object:nil];
		
		[self bypassSelector:@selector(dealloc) ofClass:[NSWindow class] throughNewSelector:@selector(afloatDealloc) keepOriginalAs:@selector(afloatDeallocOriginal)];
		
		[[AfloatHub sharedHub] setFocusedWindow:[[NSApp mainWindow] afloatTopWindow]];
	}
	
	return self;
}

- (void) didChangeFocusedWindow:(NSNotification*) notif {
	[[AfloatHub sharedHub] setFocusedWindow:[notif object]];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (NSArray*) windows {
	NSEnumerator* enu = [[NSApp windows] objectEnumerator];
	NSWindow* wnd;
	NSMutableSet* topWindows = [NSMutableSet set];
	
	while (wnd = [enu nextObject])
		[topWindows addObject:[wnd afloatTopWindow]];
	
	return [topWindows allObjects];
}

- (id) focusedWindow {
	return [[[NSApp orderedWindows] objectAtIndex:0] afloatTopWindow];
}

@end

@implementation NSWindow (AfloatCocoaAdditions)

- (void) afloatDealloc {
	[[AfloatHub sharedHub] willRemoveWindow:self];
	[self afloatDeallocOriginal];
}

- (id) afloatTopWindow {
	NSWindow* me = self;
	while ([me parentWindow])
		me = [me parentWindow];
		
	return me;
}

@end
