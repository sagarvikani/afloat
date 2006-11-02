/*
 *  AfloatCarbon.h
 *  AfloatAgent
 */

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */

#include <Carbon/Carbon.h>
#import "AfloatImplementation.h"

extern void AfloatCarbonInstall(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

@interface AfloatCarbon : AfloatImplementation {}

@end