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

#import "AfloatPrefPane.h"

#import "LoginItemsAE.h"

#import <unistd.h>
#import <signal.h>
#import <sys/types.h>

#import <Security/Security.h>

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

- (BOOL) requiresAuthorization {
	//#define kAfloatDebugAuthorization 1
	// please note: Afloat is meant to be built as a 32-bit binary thingy, hence the i386.
	// who knows what tricks can x86_64 play with mach_*?
	// I don't want to be the one who finds out.
#if defined(__i386__) || defined(kAfloatDebugAuthorization)
	
	NSString* pathToAgentBundle = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
	NSBundle* agentBundle = [[[NSBundle alloc] initWithPath:pathToAgentBundle] autorelease];
	NSDictionary* stats = [[NSFileManager defaultManager] fileAttributesAtPath:[agentBundle executablePath] traverseLink:NO];
	
	if ([[stats objectForKey:NSFileGroupOwnerAccountID] longValue] == 9 &&
		[[stats objectForKey:NSFilePosixPermissions] longValue] == 02755)
		return NO;
	
	long minor, build;
	if (Gestalt(gestaltSystemVersionMinor, &minor) != noErr) {
		// ABORT! Todo.
		return NO;
	}
	
	if (Gestalt(gestaltSystemVersionBugFix, &build) != noErr) {
		// ABORT! Todo.
		return NO;
	}
	
	return (minor >= 4 && build >= 6); // i386 10.4.6 and later.
#else
	return NO; // no need to check this on PPC
#endif
}

- (BOOL) authorize {
	OSStatus err;
	AuthorizationRef auth;
	
	if ((err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth)) == noErr) {
		NSLog(@"Afloat preference pane: Authorizing the Agent.");
		
		NSString* pathToAgentBundle = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
		NSBundle* agentBundle = [[[NSBundle alloc] initWithPath:pathToAgentBundle] autorelease];
		const char* pathToAgentExecC = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[agentBundle executablePath]];

		char* args[] = {
			"--Afloat-RepairPrivileges",
			NULL
		};
		
		AuthorizationExecuteWithPrivileges(auth, pathToAgentExecC, kAuthorizationFlagDefaults, args, NULL);
		
		AuthorizationFree(auth, kAuthorizationFlagDestroyRights);
		
		usleep(500000);
	} else
		return NO;
	
	return ![self requiresAuthorization];
}

- (BOOL) canProceedWithEnablingWithUIAllowed:(BOOL) canAsk {
	if (![self requiresAuthorization])
		return YES;
	
	// set up authorization asynchronously if canAsk
	if (canAsk) {
		NSAlert* alert = [[NSAlert new] autorelease];
		
		[alert setMessageText:
			NSLocalizedString(@"Afloat must be authorized by an administrator before it can be enabled.",
							  @"Authorization prompt message.")
			];
		
		[alert setInformativeText:
			NSLocalizedString(@"For security reasons, recent Mac OS X versions require an administrator to authorize modules, such as Afloat, that change the way other applications work.\n\nThis must be done only once, and will require an administrator's name and password.",
							  @"Authorization prompt info text")
			];
		
		[alert addButtonWithTitle:
			NSLocalizedString(@"Authorize", @"Authorization prompt accept button")
			];
		[alert addButtonWithTitle:
			NSLocalizedString(@"Cancel", @"Authorization prompt cancel button")
			];
		
		[alert beginSheetModalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:@selector(authorizationPromptDidEnd:returnCode:nothing:) contextInfo:nil];
	}
	
	return NO;
}

- (void) authorizationPromptDidEnd:(NSAlert*) alert returnCode:(int) retCode nothing:(void*) nothing {
	if (retCode == NSAlertFirstButtonReturn) {
		if ([self authorize]) [self setAfloatEnabled:YES];
	}
}

- (void) setAfloatEnabled:(BOOL) enabled {
	[self willChangeValueForKey:@"afloatEnabled"];
	NSString* pathToAgentBundle = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
	NSURL* URLToAgentBundle = [NSURL fileURLWithPath:pathToAgentBundle];
	
	if (enabled == NO) {
		if (![self afloatEnabled]) goto AfloatEnabledCleanup;
		
		[[self afloatAgent] disable];
	
		// remove the login item
		NSString* pathToAgentBundle = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
		NSURL* URLToAgentBundle = [NSURL fileURLWithPath:pathToAgentBundle];
		
		NSArray* loginItems = nil;
		LIAECopyLoginItems((CFArrayRef*) &loginItems);
		[loginItems autorelease];
		
		int i, j;
		for (i = 0, j = 0; i < [loginItems count]; i++, j++) {
			// no nsenumerators, because we're going to need the index
			if ([[[loginItems objectAtIndex:i] objectForKey:(id) kLIAEURL] isEqualTo:URLToAgentBundle]) {
				LIAERemove((CFIndex)j);
				j--;
			}
		}
		
		sleep(1); // we give the agent time to die gracefully
		
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
		if ([self afloatEnabled]) goto AfloatEnabledCleanup;
		if (![self canProceedWithEnablingWithUIAllowed:YES]) goto AfloatEnabledCleanup;
		
		NSString* pathToAgent = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
		[[NSWorkspace sharedWorkspace] openFile:pathToAgent withApplication:nil andDeactivate:NO];
		
		LIAEAddURLAtEnd((CFURLRef) URLToAgentBundle, false);
		sleep(1); // to give it time to start
	}
	
AfloatEnabledCleanup:
		[self performSelector:@selector(didChangeValueForKey:) withObject:@"afloatEnabled" afterDelay:0.1];
}

@end
