//
//  AfloatPrefPane.m
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import "../AfloatAgentCommunication.h"

#import "AfloatPrefPane.h"
#import <unistd.h>
#import <signal.h>
#import <sys/types.h>

#define kAfloatAgentBundleIdentifier @"net.infinite-labs.Afloat.Agent"

@implementation AfloatPrefPane

- (void) didSelect {
	[super didSelect];
	[self willChangeValueForKey:@"afloatEnabled"]; [self didChangeValueForKey:@"afloatEnabled"];
}

- (BOOL) afloatEnabled {
	return [self processIDForAfloatAgent] != 0;
}

- (pid_t) processIDForAfloatAgent {
	@try {
		id <AfloatAgent> agent = [self afloatAgent];
		return [agent processID];
	} @catch (NSException* ex) {
	}
	
	return (pid_t)0;
}

- (id <AfloatAgent>) afloatAgent {
	id x = [NSConnection rootProxyForConnectionWithRegisteredName:kAfloatDistributedObjectIdentifier host:nil];
	[x setProtocolForProxy:@protocol(AfloatAgent)];
	return x;
}

- (void) setAfloatEnabled:(BOOL) enabled {
	if (enabled == NO) {
		if (![self afloatEnabled]) return;
		
		[[self afloatAgent] disable];
	
		sleep(1); // we give it time to die gracefully

		pid_t agentPID = [self processIDForAfloatAgent];
		if (agentPID != 0) {
			kill(agentPID, SIGKILL);
			
			NSAlert* agentWasKilled = [[NSAlert new] autorelease];
			[agentWasKilled setMessageText:
				NSLocalizedString(@"Afloat could not disable its support components.", @"Agent was killed message")
				];
			[agentWasKilled setInformativeText:
				NSLocalizedString(@"An attempt has been made to force quit the Afloat Agent. If this happens again, please report it to the Afloat support address, 'afloat@infinite-labs.net'.", @"Agent was killed informative text")
				];
			[agentWasKilled beginSheetModalForWindow:[[self mainView] window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
		}
	} else {
		if ([self afloatEnabled]) return;
		NSString* pathToAgent = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
		[[NSWorkspace sharedWorkspace] launchApplication:pathToAgent];
		sleep(1); // to give it time to start
	}
}

@end
