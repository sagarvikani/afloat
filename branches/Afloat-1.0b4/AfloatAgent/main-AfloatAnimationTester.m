/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#import <Cocoa/Cocoa.h>
#import "AfloatAnimator.h"

@interface AfloatTestAni : NSObject <AfloatAnimation>
@end

@implementation AfloatTestAni

- (void) performAnimation:(float) progress {
	NSLog(@"%f", progress);
}

@end

int main(int argc, const char* argv[]) {
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	
	NSDate* begin = [NSDate date], * end;
	
	AfloatAnimator* i = [[AfloatAnimator alloc] initWithApproximateDuration:3.0];
	[i addAnimation:[[AfloatTestAni new] autorelease]];
	[i run];
	[i release];
	
	end = [NSDate date];
	
	NSTimeInterval timePassed = [end timeIntervalSinceDate:begin];
	NSLog(@"passati %f sec.", timePassed);
	
	[pool release];
	return 0;
}