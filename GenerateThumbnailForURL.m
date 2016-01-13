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
#if 1
    LOG_FILE_LINE("");
    NSData *imageData = [Dot dataFromDotFile: (__bridge NSURL *)url format:@"-Tsvg"];
    NSData *data = imageData;
    [data writeToFile:@"/Volumes/Macintosh-HD/Test.localized/TrySomething/mylisp/dot/some.html" atomically:true];
    LOG_FILE_LINE("");

    CFDictionaryRef properties = (__bridge CFDictionaryRef) [NSDictionary dictionary];
    CFDictionaryRef prop = (__bridge CFDictionaryRef) [NSDictionary dictionary];
//    QLThumbnailRequestSetImageAtURL(thumbnail, url, properties);
    QLThumbnailRequestSetThumbnailWithDataRepresentation(thumbnail,
                                          (__bridge CFDataRef) imageData,
                                          kUTTypeHTML,
                                          properties, prop
                                          );
    LOG_FILE_LINE("");
    return noErr;
    if (0 && imageData)
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
    
    LOG_FILE_LINE("");
    if (data) {
        LOG_FILE_LINE("");
        double w = 60;
        double h = 80;
        NSRect viewRect = NSMakeRect(0.0, 0.0, w, h);
        float scale = maxSize.height / 80.0;
        NSSize scaleSize = NSMakeSize(scale, scale);
        CGSize thumbSize = NSSizeToCGSize(
                                          NSMakeSize((maxSize.width * (w / h)),
                                                     maxSize.height));
        
        LOG_FILE_LINE("");
        WebView* webView = [[WebView alloc] initWithFrame: viewRect];
        LOG_FILE_LINE("");
        [webView scaleUnitSquareToSize: scaleSize];
        LOG_FILE_LINE("");
        [[[webView mainFrame] frameView] setAllowsScrolling:NO];
        LOG_FILE_LINE("");
        [[webView mainFrame] loadData: data
                             MIMEType: @"text/html"
                     textEncodingName: @"utf-8"
                              baseURL: nil];
        
        LOG_FILE_LINE("");
        while([webView isLoading]) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
        }
        
        LOG_FILE_LINE("");
        [webView display];
        LOG_FILE_LINE("");
        
        CGContextRef context =
        QLThumbnailRequestCreateContext(thumbnail, thumbSize, false, NULL);
        
        LOG_FILE_LINE("");
        if (context) {
            LOG_FILE_LINE("");
            NSGraphicsContext* nsContext =
            [NSGraphicsContext
             graphicsContextWithGraphicsPort: (void*) context
													flipped: [webView isFlipped]];
            
            LOG_FILE_LINE("");
            [webView displayRectIgnoringOpacity: [webView bounds]
                                      inContext: nsContext];
            
            LOG_FILE_LINE("");
            QLThumbnailRequestFlushContext(thumbnail, context);
            
            LOG_FILE_LINE("");
            CFRelease(context);
        }
        LOG_FILE_LINE("");
    }
    LOG_FILE_LINE("");
#endif
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
