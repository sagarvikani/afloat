/*
Copyright (c) 2008, Emanuele Vulcano
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AfloatStorage.h"

@implementation AfloatStorage

- (id) init
{
	self = [super init];
	if (self != nil) {
		_backingStorage = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc {
	[_backingStorage release];
	[super dealloc];
}

- (id) valueForWindow:(NSWindow*) w key:(NSString*) k {
	return [[_backingStorage objectForKey:[NSValue valueWithNonretainedObject:w]] objectForKey:k];
}

- (void) setValue:(id) v window:(NSWindow*) w key:(NSString*) k {
	NSMutableDictionary* d = [self mutableDictionaryForWindow:w];
	[d setObject:v forKey:k];
}

- (NSMutableDictionary*) mutableDictionaryForWindow:(NSWindow*) w {
	NSValue* value = [NSValue valueWithNonretainedObject:w];
	NSMutableDictionary* d = [_backingStorage objectForKey:value];
	if (!d) {
		d = [NSMutableDictionary dictionary];
		[_backingStorage setObject:d forKey:value];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:w];
	}
	
	return d;
}

- (void) windowWillClose:(NSNotification*) n {
	NSValue* v = [NSValue valueWithNonretainedObject:[n object]];
	NSMutableDictionary* d = 
		[_backingStorage objectForKey:v];
	if (d) {
		[self.delegate storage:self willRemoveMutableDictionary:d forWindow:[n object]];
		[_backingStorage removeObjectForKey:v];
	}
}

- (void) removeValueForWindow:(NSWindow*) w key:(NSString*) k {
	[[self mutableDictionaryForWindow:w] removeObjectForKey:k];
}

+ (id) sharedStorage {
	static id myself = nil; if (!myself) myself = [self new];
	return myself;
}

+ (NSMutableDictionary*) sharedMutableDictionaryForWindow:(NSWindow*) window {
	return [[self sharedStorage] mutableDictionaryForWindow:window];
}

+ (id) sharedValueForWindow:(NSWindow*) w key:(NSString*) k {
	return [[self sharedStorage] valueForWindow:w key:k];
}

+ (void) removeSharedValueForWindow:(NSWindow*) w key:(NSString*) k {
	[[self sharedStorage] removeValueForWindow:w key:k];
}

+ (void) setSharedValue:(id) v window:(NSWindow*) w key:(NSString*) k {
	[[self sharedStorage] setValue:v window:w key:k];
}

@synthesize delegate = _delegate;

@end
