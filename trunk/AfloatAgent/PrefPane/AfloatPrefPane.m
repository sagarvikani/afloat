//
//  AfloatPrefPane.m
//  AfloatAgent
//
//  Created by ∞ on 14/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

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
	return [self currentInfoForAfloatAgent] != nil;
}

- (NSDictionary*) currentInfoForAfloatAgent {
	NSArray* runningApps = [[NSWorkspace sharedWorkspace] launchedApplications];
	NSEnumerator* enu = [runningApps objectEnumerator];
	NSDictionary* it;
	
	while (it = [enu nextObject]) {
		if ([[it objectForKey:@"NSApplicationBundleIdentifier"] isEqualToString:kAfloatAgentBundleIdentifier])
			return it;
	}
	
	return nil;
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

		NSDictionary* info;
		if (info = [self currentInfoForAfloatAgent]) {
			pid_t agentPID;
			NSNumber* n = [info objectForKey:@"NSApplicationProcessIdentifier"];
			if (!n) return;
			
			agentPID = [n longValue];
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
