/*
** L0AfloatModule.h
** 
**   The superclass of all Afloat modules.
** Global modules are direct concrete subclasses
** of this class; they're singletons and live
** throughout the entire life of the app.
** Per-window modules are subclasses of
** L0AfloatWindowModule, an abstract
** subclass.
** 
** 
**   This source file is part of Afloat and is
** subject to the terms of a (BSD) license.
** 
** Copyright © 2006, Emanuele Vulcano.
** 
** The license should have been distributed
** along with this source file. If it hasn't,
** please see the Afloat development site at
** <http://millenomi.altervista.org/Afloat/Next>
** or contact the main developer at
** <millenomi+afloatlicense@gmail.com>.
*/

#import <Cocoa/Cocoa.h>


@interface L0AfloatModule : NSObject {
}

- (BOOL) willValidateMenuItem:(NSMenuItem*) item forWindow:(NSWindow*) wnd shouldEnable:(BOOL*) shouldEnable;
- (BOOL) willHandleEvent:(NSEvent*) evt;

@end
