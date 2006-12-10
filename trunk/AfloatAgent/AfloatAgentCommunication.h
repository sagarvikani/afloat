
/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */

#import <sys/types.h>

#define kAfloatDistributedObjectIdentifier @"net.infinite-labs.Afloat.Agent.DO"

#define kAfloatRollCallNotification @"AfloatRollCallNotification"

#define kAfloatAlreadyLoadedNotification @"AfloatAlreadyLoadedNotification"
#define kAfloatApplicationBundleID @"AfloatApplicationBundleID"

@protocol AfloatAgent

- (oneway void) disable;
- (pid_t) processID;

@end