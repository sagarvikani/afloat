#import "AfloatLoader.h"

#import <sys/types.h>
#import <mach_inject_bundle/mach_inject_bundle.h>

@implementation AfloatLoader

- (void) applicationDidFinishLaunching:(NSNotification*) notif {
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self selector:@selector(didLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
}

- (void) dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [super dealloc];
}

- (NSString*) pathToAfloatBundle {
    return [[NSBundle mainBundle] pathForResource:@"AfloatPayload" ofType:@"bundle"];
}

- (void) didLaunchApplication:(NSNotification*) notif {
    NSString* bundleIdentifier = [[notif userInfo] objectForKey:@"NSApplicationBundleIdentifier"];

    if ([bundleIdentifier isEqual:@"com.apple.Xcode"] ||
        [bundleIdentifier isEqual:@"com.apple.dock"] ||
        [bundleIdentifier isEqual:@"com.apple.systempreferences"])
        return;
    
    const char* fsRepToAfloatBundle = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:[self pathToAfloatBundle]];

    NSNumber* pidNumber = [[notif userInfo] objectForKey:@"NSApplicationProcessIdentifier"];
        
    pid_t pid = (pid_t) [pidNumber intValue];
    mach_error_t err = mach_inject_bundle_pid(fsRepToAfloatBundle, pid);
	
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
		
		default:
			NSLog(@"altro errore o tutto ok: %d", err);
			break;
	}
    
    NSLog(@"%@", [[notif userInfo] descriptionInStringsFileFormat]);
}

@end
