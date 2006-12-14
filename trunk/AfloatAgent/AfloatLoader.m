
/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import "AfloatLoader.h"

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
		
	// grab the app's pid from the NSNumber*
	pid_t pid = (pid_t) [pidNumber intValue];

	// fix -- Rosetta and Afloat don't mix well, so we do nothing on nonnative apps
	if (!AfloatApplicationIsNative(pid))
		return;
		
	// get the native rep to the path to Afloat's bundle
	const char* fsRepToAfloatBundle = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[self pathToAfloatBundle]];		

	// do it!
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

- (pid_t) processID {
	return getpid();
}

// -----

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
