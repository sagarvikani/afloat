//
//  AfloatWindowInfo.m
//  AfloatAgent
//
//  Created by ∞ on 01/02/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AfloatWindowInfo.h"
#import "AfloatLogging.h"

static NSMutableDictionary* _windowInfos = nil;

@interface AfloatWindowInfoDictionary : NSProxy {
	NSMutableDictionary* realDictionary;
	NSWindow* window;
}

- (id) initWithDictionary:(NSMutableDictionary*) dictionary window:(NSWindow*) window;
+ (id) dictionaryWithDictionary:(NSMutableDictionary*) d window:(NSWindow*) w;

@end

@implementation AfloatWindowInfoDictionary

- (id) initWithDictionary:(NSMutableDictionary*) dictionary window:(NSWindow*) w {
	realDictionary = [dictionary retain];
	window = /* weak */ w;
	
	return self;
}

+ (id) dictionaryWithDictionary:(NSMutableDictionary*) d window:(NSWindow*) w {
	return [[[self alloc] initWithDictionary:d window:w] autorelease];
}

- (NSString*) description {
	return [realDictionary description];
}

- (void) removeObjectForKey:(id <NSCopying>) key {
	AfloatLog(@"-[AfloatWindowInfoDictionary removeObjectForKey:%@]", key);
	id obj = [realDictionary objectForKey:key];
	if (obj && [obj respondsToSelector:@selector(afloatWillRemoveFromWindow:)])
		[obj afloatWillRemoveFromWindow:window];

	[realDictionary removeObjectForKey:key];
}

- (void) setObject:(id) object forKey:(id <NSCopying>) key {
	AfloatLog(@"-[AfloatWindowInfoDictionary setObject:%@ forKey:%@]", object, key);
	
	id oldObject = [realDictionary objectForKey:key];
	if (oldObject && [oldObject respondsToSelector:@selector(afloatWillRemoveFromWindow:)])
		[oldObject afloatWillRemoveFromWindow:window];
	
	[realDictionary setObject:object forKey:key];
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL) sel {
	return [realDictionary methodSignatureForSelector:sel];
}

- (void) forwardInvocation:(NSInvocation*) invocation {
	[invocation setTarget:realDictionary];
    [invocation invoke];	
}

- (void) dealloc {
	[realDictionary release];

	[super dealloc];
}

@end

// ------

NSMutableDictionary* AfloatGetWindowInfoForWindow(id window) {
	if (_windowInfos == nil)
		_windowInfos = [[NSMutableDictionary alloc] init];
		
	NSValue* wnd = [NSValue valueWithNonretainedObject:window];
	id dict = [_windowInfos objectForKey:wnd];
	if (!dict) {
		dict = [AfloatWindowInfoDictionary dictionaryWithDictionary:[NSMutableDictionary dictionary] window:window];
		[_windowInfos setObject:dict forKey:wnd];
	}
	
	return dict;
}

void AfloatSetWindowInfoForWindow(id window, NSString* key, id value) {
	[AfloatGetWindowInfoForWindow(window) setObject:value forKey:key];
}

void AfloatClearWindowInfoForWinow(id window) {
	NSValue* wnd = [NSValue valueWithNonretainedObject:window];
	NSMutableDictionary* dict = [_windowInfos objectForKey:wnd];
	NSEnumerator* enu = [dict keyEnumerator];
	
	id key;
	while (key = [enu nextObject]) {
		id object = [dict objectForKey:key];
		if ([object respondsToSelector:@selector(afloatWillRemoveFromWindow:)])
			[object afloatWillRemoveFromWindow:window];
	}
	
	[_windowInfos removeObjectForKey:wnd];
}
