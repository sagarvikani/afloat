/*
 *  GetApplicationFlavor.c
 *  AfloatAgent
 */

/*

Copyright © 2006, Emanuele Vulcano.

This file is part of Afloat.

    Afloat is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

    Afloat is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with Afloat; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

*/

#include "GetApplicationFlavor.h"
#include <stdint.h>

// This code from:
// http://developer.apple.com/qa/qa2006/qa1372.html
int GetApplicationFlavor()
{
	// GetApplicationFlavor returns:
	//     -1 if the application flavor could not be identified
	//      0 if the application is a Mac OS Classic application
	//      2 if the application is a Carbon application
	//      3 if the application is a Cocoa application
	
	static int32_t flavor = -2;
	OSStatus status;
	CFDictionaryRef processInfoDict = NULL;
	CFNumberRef processInfoFlavor = NULL;
	
	if (flavor == -2)
	{
		ProcessSerialNumber psn;
		status = GetCurrentProcess(&psn);
		require_noerr(status, GetCurrentProcess);
		
		processInfoDict = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		require(processInfoDict != NULL, ProcessInformationCopyDictionary);
		
		processInfoFlavor = CFDictionaryGetValue(processInfoDict, CFSTR("Flavor"));
		require(processInfoFlavor != NULL, CFDictionaryGetValue);
		
		CFNumberGetValue(processInfoFlavor, kCFNumberSInt32Type, &flavor);
	}
	
CFDictionaryGetValue:
ProcessInformationCopyDictionary:
GetCurrentProcess:
    
	if (processInfoDict != NULL)
		CFRelease(processInfoDict);
	
	return flavor == -2? -1 : flavor;
}