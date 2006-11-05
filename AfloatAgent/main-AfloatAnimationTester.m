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