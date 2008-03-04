/*
Copyright (c) 2008, Emanuele Vulcano
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>

@interface AfloatStorage : NSObject {
	NSMutableDictionary* _backingStorage;
	id _delegate;
}

+ (id) sharedStorage;
+ (NSMutableDictionary*) sharedMutableDictionaryForWindow:(NSWindow*) window;
+ (id) sharedValueForWindow:(NSWindow*) w key:(NSString*) k;
+ (void) setSharedValue:(id) v window:(NSWindow*) w key:(NSString*) k;

- (id) valueForWindow:(NSWindow*) w key:(NSString*) k;
- (void) setValue:(id) v window:(NSWindow*) w key:(NSString*) k;

- (NSMutableDictionary*) mutableDictionaryForWindow:(NSWindow*) w;

@property(assign) id delegate;

- (void) removeValueForWindow:(NSWindow*) w key:(NSString*) k;
+ (void) removeSharedValueForWindow:(NSWindow*) w key:(NSString*) k;

@end

@interface NSObject (AfloatStorageDelegate)
- (void) storage:(AfloatStorage*) s willRemoveMutableDictionary:(NSMutableDictionary*) d forWindow:(NSWindow*) w;
@end
