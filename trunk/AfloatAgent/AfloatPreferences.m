//
//  AfloatPreferences.m
//  AfloatAgent
//
//  Created by ∞ on 07/01/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AfloatPreferences.h"
#import <Carbon/Carbon.h>
#import <string.h>

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
    else if (CFGetTypeID(ref) == CFNumberGetTypeID()) {
        int i = def;
        CFNumberGetValue((CFNumberRef)ref, kCFNumberIntType, &i);
        ret = (i != 0)? YES : NO;
    }
    
    CFRelease(ref);
    return ret;
}

- (void) setBool:(BOOL) val forKey:(NSString*) key {
    CFBooleanRef ref = val? kCFBooleanTrue : kCFBooleanFalse;
    CFPreferencesSetAppValue((CFStringRef)key, ref, kAfloatPreferencesIdentifier);
    CFPreferencesAppSynchronize(kAfloatPreferencesIdentifier);
}

- (id) objectForKey:(NSString*) key {
    return [(id)[self copyPropertyListRefForKey:key] autorelease]; // thanks for bridging, Apple :)
}

- (void) setObject:(id) object forKey:(NSString*) key {
    if (!([object isKindOfClass:[NSDictionary class]] ||
          [object isKindOfClass:[NSArray class]] ||
          [object isKindOfClass:[NSData class]] ||
          [object isKindOfClass:[NSString class]] ||
          [object isKindOfClass:[NSNumber class]] ||
          [object isKindOfClass:[NSDate class]]))
        return;
    
    if ([object isKindOfClass:[NSNumber class]] &&
        strcmp([(NSNumber*)object objCType], @encode(BOOL)) == 0) {
        [self setBool:[(NSNumber*)object boolValue] forKey:key];
        return;
    }
    
    CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)object, kAfloatPreferencesIdentifier);
    CFPreferencesAppSynchronize(kAfloatPreferencesIdentifier);
}

@end
