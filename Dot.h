//
//  Dot.h
//  quicklook-dot
//
//  Created by Besi on 09.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Dot : NSObject {
}

+(NSData *)dataFromDotFile: (NSURL *) dotFile format:(NSString *)format;


@end

void LogToFile(const char *szLog);
void WriteSthToFile(const char *szFile, const char *szText);

#define LOG_FILE_LINE(log) do{ \
        char _iiiii_szBuf[1000]; \
        sprintf(_iiiii_szBuf, "%s (%d): %s: %s\n", __FILE__, __LINE__, __FUNCTION__, log); \
        LogToFile(_iiiii_szBuf); \
    }while(false)
