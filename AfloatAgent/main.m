//
//  main.m
//  AfloatAgent

/*
 *  This file is part of Afloat and is © Emanuele Vulcano, 2006.
 *  <afloat@infinite-labs.net>
 *  
 *  Afloat's source code is licensed under a BSD license.
 *  Please see the included LICENSE file for details.
 */


#import <Cocoa/Cocoa.h>

#import <strings.h>
#include <sys/types.h>
#include <sys/stat.h>

int main(int argc, char *argv[]) {
	if (argc == 2 && strcmp(argv[1], "--Afloat-RepairPrivileges") == 0) {
		if (geteuid() != 0) // we are not root.
			return 1;
		
		NSAutoreleasePool* pool = [NSAutoreleasePool new];
		
		NSString* selfPath = [[NSBundle mainBundle] executablePath];
		const char* selfPathC = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:selfPath];
		
		int i;
		if ((i = chown(selfPathC, -1, 9 /* procmod */)) == 0)
			i = chmod(selfPathC, 02755); // setgid bit set
		
		NSLog(@"Authorization done with result %d. (nonzero means trouble.)", i);
		
		[pool release];
		
		return i;
	}
	
    return NSApplicationMain(argc,  (const char **) argv);
}
