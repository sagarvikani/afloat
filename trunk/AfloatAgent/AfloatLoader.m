
/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import "AfloatLoader.h"
#import "AfloatLogging.h"

#import <sys/sysctl.h>
#import <sys/types.h>
#import <mach_inject_bundle/mach_inject_bundle.h>

// From the Rosetta article in Apple's Universal Binary
// Programming Guidelines, second edition.
static int sysctlbyname_with_pid (const char *name, pid_t pid, 
								  void *oldp, size_t *oldlenp, 
								  void *newp, size_t newlen)
{
    if (pid == 0) {
        if (sysctlbyname(name, oldp, oldlenp, newp, newlen) == -1)  {
            fprintf(stderr, "sysctlbyname_with_pid(0): sysctlbyname  failed:"
					"%s\n", strerror(errno));
            return -1;
        }
    } else {
        int mib[CTL_MAXNAME];
        size_t len = CTL_MAXNAME;
        if (sysctlnametomib(name, mib, &len) == -1) {
            fprintf(stderr, "sysctlbyname_with_pid: sysctlnametomib  failed:"
					"%s\n", strerror(errno));
            return -1;
        }
        mib[len] = pid;
        len++;
        if (sysctl(mib, len, oldp, oldlenp, newp, newlen) == -1)  {
            fprintf(stderr, "sysctlbyname_with_pid: sysctl  failed:"
                    "%s\n", strerror(errno));
            return -1;
        }
    }
    return 0;
}

static BOOL AfloatApplicationIsNative(pid_t pid)
{
#if defined(__i386__)
    int ret = 0;
    size_t sz = sizeof(ret);
	
    if (sysctlbyname_with_pid("sysctl.proc_native", pid, 
							  &ret, &sz, NULL, 0) == -1) {
		if (errno == ENOENT) {
            // sysctl doesn't exist, which means that this version of Mac OS 
            // pre-dates Rosetta, so the application must be native.
            return YES;
        }
        fprintf(stderr, "(is_pid_native) AfloatApplicationIsNative: sysctlbyname_with_pid  failed:" 
                "%s\n", strerror(errno));
        return NO;
    }
	
    return ret != 0;
#else
	return YES;
#endif
}

@implementation AfloatLoader

- (void) applicationDidFinishLaunching:(NSNotification*) notif {
    // we cache our own build number -- will need it in case of an upgrade.
    myVersion = [[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] description] copy];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self selector:@selector(didLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(ignoreApplicationWhenInjecting:) name:kAfloatAlreadyLoadedNotification object:kAfloatDistributedObjectIdentifier];
	
	NSConnection* con = [NSConnection defaultConnection];
	[con setRootObject:self];
	if (![con registerName:kAfloatDistributedObjectIdentifier])
		[NSApp terminate:self];
	
	[self injectInAllApps];
	
	CFURLGetFSRef((CFURLRef) [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]], &selfRef);
	checkExistanceTimer = [[NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(_checkUninstall:) userInfo:nil repeats:YES] retain];
}

- (void) _checkUninstall:(NSTimer*) timer {
	NSURL* myURL = (NSURL*) CFURLCreateFromFSRef(NULL, &selfRef);
	if (!myURL) {
		AfloatLog(@"The Agent was moved or deleted (uninstalled?), hence it now quits.");
		[[NSApplication sharedApplication] terminate:self];
	}

	[myURL release];
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
		
		[self loadAfloatInApplicationWithPID:[appData objectForKey:@"NSApplicationProcessIdentifier"] bundleID:bundleID name:[appData objectForKey:@"NSApplicationName"]];
	}
	
	[doNotLoadList release]; doNotLoadList = nil;
}

- (void) loadAfloatInApplicationWithPID:(NSNumber*) pidNumber bundleID:(NSString*) bundleID name:(NSString*)name {

	// standard blacklist -- we NEVER load in these apps!
	if ([bundleID isEqual:@"com.apple.Xcode"] ||
        [bundleID isEqual:@"com.apple.dock"] ||
        [bundleID isEqual:@"com.apple.systempreferences"])
    { AfloatLog(@"Afloat not loaded in %@ (%@)", bundleID, pidNumber); return; }
//#define AfloatTerminalRequiredForTesting
#ifdef AfloatTerminalRequiredForTesting
    if ([bundleID isEqual:@"com.apple.Terminal"])
        return;
#endif
		
	// grab the app's pid from the NSNumber*
	pid_t pid = (pid_t) [pidNumber intValue];

	// fix -- Rosetta and Afloat don't mix well, so we do nothing on nonnative apps
	if (!AfloatApplicationIsNative(pid))
    { AfloatLog(@"Afloat not loaded in %@ (%@) -- not loading in Rosetta applications.", bundleID, pidNumber); return; }
    
    // fix -- we don't load in Java apps.
    if ([name isEqualToString:@"java"])
    { AfloatLog(@"Afloat not loaded in %@ (%@) -- not loading in Java applications.", bundleID, pidNumber); return; }
		
	// get the native rep to the path to Afloat's bundle
	const char* fsRepToAfloatBundle = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[self pathToAfloatBundle]];		

    
    // aaaaand...
	// do it!
	mach_error_t err = mach_inject_bundle_pid(fsRepToAfloatBundle, pid);

	AfloatLog(@"Load command issued for %@, with PID %@", bundleID, pidNumber);
	switch (err) {
		case err_mach_inject_bundle_couldnt_find_inject_entry_symbol:
			AfloatLog(@"err_mach_inject_bundle_couldnt_find_inject_entry_symbol");
			break;
			
		case err_mach_inject_bundle_couldnt_find_injection_bundle:
			AfloatLog(@"err_mach_inject_bundle_couldnt_find_injection_bundle");
			break;
			
		case err_mach_inject_bundle_couldnt_load_framework_bundle:
			AfloatLog(@"err_mach_inject_bundle_couldnt_load_framework_bundle");
			break;
			
		case err_mach_inject_bundle_couldnt_load_injection_bundle:
			AfloatLog(@"err_mach_inject_bundle_couldnt_load_injection_bundle");
			break;
		
		case 5:
			AfloatLog(@"OS X security prevented the injection");
			AfloatLog(@"The Agent is not authorized to inject code in this app. Use the Afloat pane of System Preferences to authorize it, or use --Afloat-Authorize as root on the command line.");
			// [[NSApplication sharedApplication] terminate:self];
			break;
			
		case 0:
			AfloatLog(@"Loaded without error");
			break;
			
		default:
			AfloatLog(@"error from mach_inject that I don't know: %d", err);
			break;
	}
	
}

// -----

- (oneway void) disable {
	[NSApp terminate:self];
}

- (pid_t) processID {
	return getpid();
}

- (NSString*) currentVersion {
    return myVersion;
}

// -----

- (void) dealloc {
    [myVersion release];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[waitTimer release];
	[doNotLoadList release];
	
	[checkExistanceTimer release];
	
    [super dealloc];
}

- (NSString*) pathToAfloatBundle {
    return [[NSBundle mainBundle] pathForResource:@"AfloatPayload" ofType:@"bundle"];
}

- (void) didLaunchApplication:(NSNotification*) notif {
    NSString* bundleIdentifier = [[notif userInfo] objectForKey:@"NSApplicationBundleIdentifier"];
	NSNumber* pidNumber = [[notif userInfo] objectForKey:@"NSApplicationProcessIdentifier"];
	NSString* name = [[notif userInfo] objectForKey:@"NSApplicationName"];
    
    AfloatLog(@"%@", [notif userInfo]);
    
	[self loadAfloatInApplicationWithPID:pidNumber bundleID:bundleIdentifier name:name];
}

@end
