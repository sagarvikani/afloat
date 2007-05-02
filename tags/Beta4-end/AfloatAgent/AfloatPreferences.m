//
//  AfloatPreferences.m
//  AfloatAgent
//
//  Created by ∞ on 07/01/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AfloatAgentCommunication.h"
#import "AfloatPreferences.h"

#import "AfloatLogging.h"

#import <Carbon/Carbon.h>
#import <string.h>

#define kAfloatPreferencesIdentifier ((CFStringRef)@"net.infinite-labs.Afloat")
#define kAfloatPreferencesChangedNotification @"AfloatPreferencesChanged"

#define kAfloatDefaultTransparencyKey @"AfloatDefaultTransparency"
#define kAfloatShouldUseSinkRatherThanMinimize @"AfloatShouldUseSinkRatherThanMinimize"

@implementation AfloatPreferences

+ (id) sharedInstance {
    static id myself = nil;
    if (!myself)
        myself = [[self alloc] init];
    
    return myself;
}

- (id) init {
    if (self = [super init]) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_resync:) name:kAfloatPreferencesChangedNotification object:kAfloatDistributedObjectIdentifier];
    }
    
    return self;
}

- (void) dealloc {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

// ----

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
    [self _notifyChanges];
}

- (id) objectForKey:(NSString*) key {
    id x = [(id)[self copyPropertyListRefForKey:key] autorelease]; // thanks for bridging, Apple :)
    AfloatLog(@"-[AfloatPreferences objectForKey:%@] = %@", key, x);
    return x;
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
    [self _notifyChanges];
}

- (float) floatForKey:(NSString*) key withDefault:(float) def {
    id obj = [self objectForKey:key];
    if (!obj || ![obj respondsToSelector:@selector(floatValue)])
        return def;
    
    return [obj floatValue];
}

- (void) setFloat:(float) val forKey:(NSString*) key {
    [self setObject:[NSNumber numberWithFloat:val] forKey:key];
}


- (float) defaultTransparency {
    return [self floatForKey:kAfloatDefaultTransparencyKey withDefault:0.8];
}

- (void) setDefaultTransparency:(float) v {
    return [self setFloat:v forKey:kAfloatDefaultTransparencyKey];
}

- (BOOL) shouldUseSinkRatherThanMinimize {
    return [self boolForKey:kAfloatShouldUseSinkRatherThanMinimize withDefault:NO];
}

- (void) setShouldUseSinkRatherThanMinimize:(BOOL) useSink {
    [self setBool:useSink forKey:kAfloatShouldUseSinkRatherThanMinimize];
}

// ---

- (void) _notifyChanges {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kAfloatPreferencesChangedNotification object:(id) kAfloatDistributedObjectIdentifier];
}

- (void) _resync:(NSNotification*) n {
    AfloatLog(@"-[AfloatPreferences _resync:...]");
    
    CFPreferencesAppSynchronize(kAfloatPreferencesIdentifier);
}

@end
