//
//  main.m
//  AfloatAgent

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

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
