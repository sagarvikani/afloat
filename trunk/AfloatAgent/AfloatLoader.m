
/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */

#import "AfloatLoader.h"

#import <sys/types.h>
#import <mach_inject_bundle/mach_inject_bundle.h>

@implementation AfloatLoader

- (void) applicationDidFinishLaunching:(NSNotification*) notif {
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self selector:@selector(didLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(ignoreApplicationWhenInjecting:) name:kAfloatAlreadyLoadedNotification object:kAfloatDistributedObjectIdentifier];
	
	NSConnection* con = [NSConnection defaultConnection];
	[con setRootObject:self];
	if (![con registerName:kAfloatDistributedObjectIdentifier])
		[NSApp terminate:self];
	
	[self injectInAllApps];
}

// -----

- (void) injectInAllApps {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kAfloatRollCallNotification object:kAfloatDistributedObjectIdentifier userInfo:nil deliverImmediately:YES];
	
	waitTimer = [[NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(injectPhaseTwo:) userInfo:nil repeats:NO] retain];
	doNotLoadList = [[NSMutableArray alloc] init];
}

- (void) ignoreApplicationWhenInjecting:(NSNotification*) notif {
	if (!waitTimer) return;
	
	NSString* s = [[notif userInfo] objectForKey:kAfloatApplicationBundleID];
	if (s != nil) {
		[doNotLoadList addObject:s];
		[waitTimer invalidate];
		[waitTimer release];
		waitTimer = [[NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(injectPhaseTwo:) userInfo:nil repeats:NO] retain];
	}
}

- (void) injectPhaseTwo:(NSTimer*) timer {
	[waitTimer release]; waitTimer = nil;
	
	NSEnumerator* enu = [[[NSWorkspace sharedWorkspace] launchedApplications] objectEnumerator];
	NSDictionary* appData;
	
	while (appData = [enu nextObject]) {
		NSString* bundleID = [appData objectForKey:@"NSApplicationBundleIdentifier"];
		
		if ([doNotLoadList containsObject:bundleID])
			continue;
		
		[self loadAfloatInApplicationWithPID:[appData objectForKey:@"NSApplicationProcessIdentifier"] bundleID:bundleID];
	}
	
	[doNotLoadList release]; doNotLoadList = nil;
}

- (void) loadAfloatInApplicationWithPID:(NSNumber*) pidNumber bundleID:(NSString*) bundleID {

	// standard blacklist -- we NEVER load in these apps!
	if ([bundleID isEqual:@"com.apple.Xcode"] ||
        [bundleID isEqual:@"com.apple.dock"] ||
        [bundleID isEqual:@"com.apple.systempreferences"])
        return;
	
	// get the native rep to the path to Afloat's bundle
	const char* fsRepToAfloatBundle = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[self pathToAfloatBundle]];
	
	// grab the app's pid from the NSNumber*
	pid_t pid = (pid_t) [pidNumber intValue];
    mach_error_t err = mach_inject_bundle_pid(fsRepToAfloatBundle, pid);
	
	// TODO remove logging from the shipping version
	switch (err) {
		case err_mach_inject_bundle_couldnt_find_inject_entry_symbol:
			NSLog(@"err_mach_inject_bundle_couldnt_find_inject_entry_symbol");
			break;
			
		case err_mach_inject_bundle_couldnt_find_injection_bundle:
			NSLog(@"err_mach_inject_bundle_couldnt_find_injection_bundle");
			break;
			
		case err_mach_inject_bundle_couldnt_load_framework_bundle:
			NSLog(@"err_mach_inject_bundle_couldnt_load_framework_bundle");
			break;
			
		case err_mach_inject_bundle_couldnt_load_injection_bundle:
			NSLog(@"err_mach_inject_bundle_couldnt_load_injection_bundle");
			break;
		
		case 0:
			NSLog(@"Loaded without error");
			break;
			
		default:
			NSLog(@"error from mach_inject that I don't know: %d", err);
			break;
	}
	
	NSLog(@"Loaded in %@, with PID %@", bundleID, pidNumber);
}

// -----

- (oneway void) disable {
	[NSApp terminate:self];
}

- (void) dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[waitTimer release];
	[doNotLoadList release];
	
    [super dealloc];
}

- (NSString*) pathToAfloatBundle {
    return [[NSBundle mainBundle] pathForResource:@"AfloatPayload" ofType:@"bundle"];
}

- (void) didLaunchApplication:(NSNotification*) notif {
    NSString* bundleIdentifier = [[notif userInfo] objectForKey:@"NSApplicationBundleIdentifier"];
	NSNumber* pidNumber = [[notif userInfo] objectForKey:@"NSApplicationProcessIdentifier"];
	
	[self loadAfloatInApplicationWithPID:pidNumber bundleID:bundleIdentifier];
}

@end
