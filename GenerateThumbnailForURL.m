#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#include "Dot.h"
#include <stdio.h>
/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
#if 0
    NSData *imageData = [Dot dataFromDotFile: (__bridge NSURL *)url format:@"-Tsvg"];
    NSData *data = NULL;
    if (imageData)
    {
        NSString *svg = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
        
        NSMutableString *html = [[NSMutableString alloc] init];
        [html appendString:@"<html>"];
        [html appendString:@"<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"];
        [html appendString:@"<head></head><body><h1>Dot SVG preview</h1>"];
        
        [html appendString:svg];
        
        [html appendString:@"</body></html>"];
        data = [html dataUsingEncoding:NSUTF8StringEncoding];
        
        FILE *fp = fopen("/Volumes/Macintosh-HD/Test.localized/TrySomething/mylisp/dot/some.html", "wb");
        if(fp)
        {
            while(fp)
            {
                const char *szText = [html cStringUsingEncoding:NSUTF8StringEncoding];
                if(!szText)
                {
                    break;
                }
                int nLen = strlen(szText);
                fwrite(szText, 1, nLen, fp);
                break;
            }while(false);
            fclose(fp);
        }
    }
    
    if (data) {
        double w = 600;
        double h = 800;
        NSRect viewRect = NSMakeRect(0.0, 0.0, w, h);
        float scale = maxSize.height / 800.0;
        NSSize scaleSize = NSMakeSize(scale, scale);
        CGSize thumbSize = NSSizeToCGSize(
                                          NSMakeSize((maxSize.width * (w / h)),
                                                     maxSize.height));
        
        WebView* webView = [[WebView alloc] initWithFrame: viewRect];
        [webView scaleUnitSquareToSize: scaleSize];
        [[[webView mainFrame] frameView] setAllowsScrolling:NO];
        [[webView mainFrame] loadData: data
                             MIMEType: @"text/html"
                     textEncodingName: @"utf-8"
                              baseURL: nil];
        
        while([webView isLoading]) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
        }
        
        [webView display];
        
        CGContextRef context =
        QLThumbnailRequestCreateContext(thumbnail, thumbSize, false, NULL);
        
        if (context) {
            NSGraphicsContext* nsContext =
            [NSGraphicsContext
             graphicsContextWithGraphicsPort: (void*) context
													flipped: [webView isFlipped]];
            
            [webView displayRectIgnoringOpacity: [webView bounds]
                                      inContext: nsContext];
            
            QLThumbnailRequestFlushContext(thumbnail, context);
            
            CFRelease(context);
        }
    }
#endif
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
