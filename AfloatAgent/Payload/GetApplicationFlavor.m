/*
 *  GetApplicationFlavor.c
 *  AfloatAgent
 *
 *  Created by ∞ on 08/12/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "GetApplicationFlavor.h"

// This code from:
// http://developer.apple.com/qa/qa2006/qa1372.html
int GetApplicationFlavor()
{
	// GetApplicationFlavor returns:
	//     -1 if the application flavor could not be identified
	//      0 if the application is a Mac OS Classic application
	//      2 if the application is a Carbon application
	//      3 if the application is a Cocoa application
	
	static int flavor = -1;
	OSStatus status;
	CFDictionaryRef processInfoDict = NULL;
	CFNumberRef processInfoFlavor = NULL;
	
	if (flavor == -1)
	{
		ProcessSerialNumber psn;
		status = GetCurrentProcess(&psn);
		require_noerr(status, GetCurrentProcess);
		
		processInfoDict = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		require(processInfoDict != NULL, ProcessInformationCopyDictionary);
		
		processInfoFlavor = CFDictionaryGetValue(processInfoDict, CFSTR("Flavor"));
		require(processInfoFlavor != NULL, CFDictionaryGetValue);
		
		CFNumberGetValue(processInfoFlavor, kCFNumberIntType, &flavor);
	}
	
CFDictionaryGetValue:
ProcessInformationCopyDictionary:
GetCurrentProcess:
		
		if (processInfoFlavor != NULL)
			CFRelease(processInfoFlavor);
	if (processInfoDict != NULL)
		CFRelease(processInfoDict);
	
	return flavor;
}