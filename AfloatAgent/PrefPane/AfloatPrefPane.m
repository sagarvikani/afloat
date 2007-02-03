//
//  AfloatPrefPane.m
//  AfloatAgent

/*
 
 Copyright © 2006, Emanuele Vulcano.
 
 This file is part of Afloat.
 
 Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.
 
 Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
 
 */

#import "AfloatPrefPane.h"
#import "AfloatLogging.h"

#import "LoginItemsAE.h"

#import <unistd.h>
#import <signal.h>
#import <sys/types.h>

#import <Security/Security.h>
#import <Carbon/Carbon.h>

#define kAfloatAgentBundleIdentifier @"net.infinite-labs.Afloat.Agent"

#import "AfloatPreferences.h"

static OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend);

static AuthorizationRef authorization = NULL;

static AuthorizationRef AfloatPrefPaneGetAuthorization() {
    if (authorization)
        return authorization;
    
    if (AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorization) == noErr) {
        AuthorizationItem authItems[1];
        authItems[0].name = kAuthorizationRightExecute;
        authItems[0].valueLength = 0;
        authItems[0].value = NULL;
        authItems[0].flags = 0;
        
        AuthorizationRights executionRights;
        executionRights.count = 1;
        executionRights.items = authItems;
        
        if (AuthorizationCopyRights(authorization, &executionRights, kAuthorizationEmptyEnvironment, kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed, NULL) == noErr)
            return authorization;
        
        AuthorizationFree(authorization, kAuthorizationFlagDestroyRights);
    }
    
    return NULL;
}

static void AfloatPrefPaneClearAuthorization() {
    if (authorization) {
        AuthorizationFree(authorization, kAuthorizationFlagDestroyRights);
        authorization = NULL;
    }
}

@implementation AfloatPrefPane

- (void) didSelect {
	[self upgradePreviousVersionsIfRequired];
	
	upgrading = NO;
	
	[self willChangeValueForKey:@"afloatEnabled"]; 
	id <AfloatAgent> agent = [self afloatAgent];
	if (agent) {
		NSString* version = nil;
		
		@try {
			version = [agent currentVersion];
		} @catch (NSException* ex) {
		}
		
		AfloatLog(@"Afloat has detected a running Agent. When asked about its version, it responded: %@", version);
		
		if (!version || ![[[self bundle] objectForInfoDictionaryKey:@"CFBundleVersion"] isEqualToString:version]) {
			AfloatLog(@"Afloat gets disabled and re-enabled as it's a different (lower?) version.");
			upgrading = YES;
			[self setAfloatEnabled:NO withUIAllowed:NO];
			[self setAfloatEnabled:YES];
		} else
			[self canProceedWithEnablingWithUIAllowed:YES];
			
	} else
		[self canProceedWithEnablingWithUIAllowed:YES];
	[self didChangeValueForKey:@"afloatEnabled"];
	
}

- (void) upgradePreviousVersionsIfRequired {
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* path = [@"~/Library/Application Support/SIMBL/Plugins/Afloat.bundle" stringByStandardizingPath];
	[fm removeFileAtPath:path handler:nil];
}

- (void) willUnselect {
    [aboutPanel orderOut:self];
    AfloatPrefPaneClearAuthorization();
    [super willUnselect];
}

- (IBAction) showAboutPanel:(id) sender {
    [aboutPanel center];
    [aboutPanel makeKeyAndOrderFront:self];
}

- (IBAction) openLicense:(id) sender {
    NSString* path = [[self bundle] pathForResource:@"License" ofType:@"pdf"];
    if (path)
        [[NSWorkspace sharedWorkspace] openFile:path];
    else
        NSBeep();
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
	//#define AfloatDebugAuthorization 1
	// please note: Afloat is meant to be built as a 32-bit binary thingy, hence the i386.
	// who knows what tricks can x86_64 play with mach_*?
	// I don't want to be the one who finds out.	
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
#if defined(__i386__)
	return (minor >= 4 && build >= 4); // i386 10.4.4 and later.
#else
    return (minor >= 5); // PPC Leopard and later
#endif
}

- (BOOL) authorize {
	AuthorizationRef auth;
	
	if (auth = AfloatPrefPaneGetAuthorization()) {
		NSLog(@"Afloat preference pane: Authorizing the Agent.");
		
		NSString* pathToAgentBundle = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
		NSBundle* agentBundle = [[[NSBundle alloc] initWithPath:pathToAgentBundle] autorelease];
		const char* pathToAgentExecC = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[agentBundle executablePath]];
		
		char* args[] = {
			"--Afloat-Authorize",
			NULL
		};
		
		AuthorizationExecuteWithPrivileges(auth, pathToAgentExecC, kAuthorizationFlagDefaults, args, NULL);
		
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
			NSLocalizedString(@"Recent Mac OS X versions require an administrator to authorize modules, such as Afloat, that change the way other applications work.\n\nThis must be done only once, and will require an administrator's name and password.",
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
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		
		if (upgrading) {
			upgrading = NO;
			[self performSelector:@selector(showLogoutPrompt) withObject:nil afterDelay:0.01];
		}
	}
}

- (void) showLogoutPrompt {
	NSAlert* alert = [NSAlert new];
	[alert setMessageText:
		NSLocalizedString(@"Afloat was upgraded. Logging out is recommended after upgrading.", @"Afloat was upgraded.")
		];
	
	[alert setInformativeText:
		NSLocalizedString(@"Features from the new version of Afloat are not available until you quit and reopen applications. Logging out is the fastest way to quit all open applications.", @"Afloat was upgraded info text")
		];
	
	[alert addButtonWithTitle:
		NSLocalizedString(@"Log Out", @"Afloat was upgraded: 'log out' button.")
		];
	
	[alert addButtonWithTitle:
		NSLocalizedString(@"Continue without Logging Out", @"Afloat was upgraded: don't log out.")
		];
	
	[alert beginSheetModalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:@selector(logoutPromptDidEnd:returnCode:nothing:) contextInfo:NULL];
	[alert release];
}

- (void) logoutPromptDidEnd:(NSAlert*) prompt returnCode:(int) retCode nothing:(void*) nothing {
	if (retCode == NSAlertFirstButtonReturn) {
		SendAppleEventToSystemProcess(kAEReallyLogOut);
	}
}

- (void) setAfloatEnabled:(BOOL) enabled {
	[self setAfloatEnabled:enabled withUIAllowed:YES];
}

- (void) setAfloatEnabled:(BOOL) enabled withUIAllowed:(BOOL) ui {
	[self willChangeValueForKey:@"afloatEnabled"];
	NSString* pathToAgentBundle = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
	NSURL* URLToAgentBundle = [NSURL fileURLWithPath:pathToAgentBundle];
	
	if (enabled == NO) {
		if (![self afloatEnabled]) goto AfloatEnabledCleanup;
		
        pid_t agentPID = [self processIDForAfloatAgent];
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
		
		if (kill(agentPID, 0) == 0) {
			kill(agentPID, SIGKILL);
			AfloatLog(@"Sent a KILL signal to an non-quitting Agent.");
			
			if (ui) {
				NSAlert* agentWasKilled = [[NSAlert new] autorelease];
				[agentWasKilled setMessageText:
					NSLocalizedString(@"Afloat could not disable its support components.", @"Agent was killed message")
					];
				[agentWasKilled setInformativeText:
					NSLocalizedString(@"An attempt has been made to force quit the Afloat Agent. If this happens again, please report it to the Afloat support address, 'afloat@infinite-labs.net'.", @"Agent was killed informative text")
					];
				[agentWasKilled beginSheetModalForWindow:[[self mainView] window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
			}
		}
	} else {
		if ([self afloatEnabled]) goto AfloatEnabledCleanup;
		if (![self canProceedWithEnablingWithUIAllowed:ui]) goto AfloatEnabledCleanup;
		
		NSString* pathToAgent = [[NSBundle bundleForClass:[self class]] pathForResource:@"Afloat Agent" ofType:@"app"];
		[[NSWorkspace sharedWorkspace] openFile:pathToAgent withApplication:nil andDeactivate:NO];
		
		LIAEAddURLAtEnd((CFURLRef) URLToAgentBundle, false);
	}
	
AfloatEnabledCleanup:
		[self performSelector:@selector(didChangeValueForKey:) withObject:@"afloatEnabled" afterDelay:0.3];
}

- (id) visibleVersion {
    return [[self bundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (id) internalVersion {
    return [[self bundle] objectForInfoDictionaryKey:@"CFBundleVersion"];    
}

- (id) preferences {
    return [AfloatPreferences sharedInstance];
}

- (IBAction) chatWithInfiniteLabs:(id) sender {
	[[NSWorkspace sharedWorkspace]
		openURL:[NSURL URLWithString:@"aim:GoIM?screenname=me@infinite-labs.net"]];
}

- (IBAction) sendEmailToInfiniteLabs:(id) sender {
	[[NSWorkspace sharedWorkspace]
		openURL:[NSURL URLWithString:@"mailto:me@infinite-labs.net"]];	
}

- (BOOL) doAnimations {
	return [[AfloatPreferences sharedInstance] boolForKey:@"AfloatDoAnimation" withDefault:YES];
}

- (void) setDoAnimations:(BOOL) doesAni {
	[[AfloatPreferences sharedInstance] setBool:doesAni forKey:@"AfloatDoAnimation"];
}

@end

// from http://developer.apple.com/qa/qa2001/qa1134.html
static OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber
		kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
	
    OSStatus error = noErr;
	
    error = AECreateDesc(typeProcessSerialNumber,
						 &kPSNOfSystemProcess, sizeof(kPSNOfSystemProcess),
						 &targetDesc);
	
    if (error != noErr)
    {
        return(error);
    }
	
    error = AECreateAppleEvent(kCoreEventClass, EventToSend,
							   &targetDesc, kAutoGenerateReturnID,
							   kAnyTransactionID, &appleEventToSend);
	
    AEDisposeDesc(&targetDesc);
	
    if (error != noErr)
    {
        return(error);
    }
	
    error = AESend(&appleEventToSend, &eventReply, kAENoReply,
				   kAENormalPriority, kAEDefaultTimeout,
				   NULL, NULL);
	
    AEDisposeDesc(&appleEventToSend);
	
    if (error != noErr)
    {
        return(error);
    }
	
    AEDisposeDesc(&eventReply);
	
    return(error); //if this is noErr then we are successful
}