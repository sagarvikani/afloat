/*
 *  GetApplicationFlavor.h
 *  AfloatAgent
 *
 *  Created by ∞ on 08/12/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

enum {
	kCarbonApplicationFlavor = 2,
	kCocoaApplicationFlavor = 3,
	kClassicApplicationFlavor = 0,
	
	kUnidentifiedApplicationFlavor = -1
};

extern int GetApplicationFlavor();

