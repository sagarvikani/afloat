/*
** L0AfloatTransparencyUI.m
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

#import "L0AfloatTransparencyUI.h"
#import "L0AfloatWindowFloater.h"

#import "L0Afloat.h"

@implementation L0AfloatTransparencyUI

- (id) initWithTargetWindow:(NSWindow*) wnd {
    if (self = [super initWithWindowNibName:@"Transparency" owner:self]) {
        targetWindow = [wnd retain];
    }
    
    return self;
}

- (void) awakeFromNib {
    [transparencySlider setFloatValue:(1 - [targetWindow alphaValue]) * 100];
}

- (IBAction) takeTransparencyValueFromSender:(id) sender {
    L0AfloatWindowFloater* flt = (L0AfloatWindowFloater*) [[L0Afloat sharedInstance] findOrCreateModuleOfClass:[L0AfloatWindowFloater class] forWindow:targetWindow];
	[flt setTransparency:[sender intValue]];
}

- (IBAction) beginDocumentModalPanel:(id) sender {
    [self retain];
    [[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:targetWindow modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (IBAction) endDocumentModalPanel:(id) sender {
    [[self window] orderOut:self];
    [[NSApplication sharedApplication] endSheet:[self window]];
    [self release];
}

- (void) dealloc {
    [targetWindow release];
    [super dealloc];
}

@end
