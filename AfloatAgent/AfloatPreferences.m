//
//  AfloatPreferences.m
//  AfloatAgent
//
//  Created by ∞ on 07/01/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AfloatPreferences.h"
#import <Carbon/Carbon.h>

#define kAfloatPreferencesIdentifier ((CFStringRef)@"net.infinite-labs.Afloat")

@implementation AfloatPreferences

+ (id) sharedInstance {
    static id myself = nil;
    if (!myself)
        myself = [[self alloc] init];
    
    return myself;
}

- (CFPropertyListRef) copyPropertyListRefForKey:(NSString*) key {
    return CFPreferencesCopyAppValue((CFStringRef)key, kAfloatPreferencesIdentifier);
}

- (BOOL) boolForKey:(NSString*) key withDefault:(BOOL) def {
    CFPropertyListRef ref = [self copyPropertyListRefForKey:key];
    
    if (!ref)
        return def;
    
    BOOL ret = def;
    if (CFGetTypeID(ref) == CFBooleanGetTypeID())
        ret = CFBooleanGetValue((CFBooleanRef)ref)? YES : NO;
    
    CFRelease(ref);
    return ret;
}

- (id) objectForKey:(NSString*) key {
    return [(id)[self copyPropertyListRefForKey:key] autorelease]; // thanks for bridging, Apple :)
}

@end
