/*
** L0AfloatTransparencyUI.h
** 
**   This class manages the "Transparency for
** this window" sheet.
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


@interface L0AfloatTransparencyUI : NSWindowController {
    NSWindow* targetWindow;
    IBOutlet NSSlider* transparencySlider;
}

- (id) initWithTargetWindow:(NSWindow*) targetWindow;

- (IBAction) takeTransparencyValueFromSender:(id) sender;
- (IBAction) beginDocumentModalPanel:(id) sender;
- (IBAction) endDocumentModalPanel:(id) sender;

@end
