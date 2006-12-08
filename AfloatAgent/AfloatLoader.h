
/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import <Cocoa/Cocoa.h>
#import "AfloatAgentCommunication.h"

@interface AfloatLoader : NSObject <AfloatAgent> {
	NSTimer* waitTimer;
	NSMutableArray* doNotLoadList;
}

- (NSString*) pathToAfloatBundle;
- (void) injectInAllApps;

- (void) loadAfloatInApplicationWithPID:(NSNumber*) pidNumber bundleID:(NSString*) bundleID;

@end
