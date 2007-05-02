//
//  AfloatPreferences.h
//  AfloatAgent
//
//  Created by ∞ on 07/01/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AfloatPreferences : NSObject {

}

+ (id) sharedInstance;

- (float) defaultTransparency;
- (void) setDefaultTransparency:(float) t;

- (BOOL) shouldUseSinkRatherThanMinimize;
- (void) setShouldUseSinkRatherThanMinimize:(BOOL) useSink;

- (BOOL) boolForKey:(NSString*) key withDefault:(BOOL) def;
- (void) setBool:(BOOL) val forKey:(NSString*) key;

- (float) floatForKey:(NSString*) key withDefault:(float) def;
- (void) setFloat:(float) val forKey:(NSString*) key;

- (id) objectForKey:(NSString*) key;
- (void) setObject:(id) object forKey:(NSString*) key;

// private
- (void) _notifyChanges;
@end
