//
//  AfloatPrefPane.h
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>

#import "../AfloatAgentCommunication.h"

#define AfloatPrefPane NetInfinite_LabsAfloatPrefPane

@interface AfloatPrefPane : NSPreferencePane {
}

- (pid_t) processIDForAfloatAgent;
- (id <AfloatAgent>) afloatAgent;

- (BOOL) afloatEnabled;
- (void) setAfloatEnabled:(BOOL) isOn;

- (BOOL) requiresAuthorization;
- (BOOL) canProceedWithEnablingWithUIAllowed:(BOOL) canAsk;
- (BOOL) authorize;

@end
