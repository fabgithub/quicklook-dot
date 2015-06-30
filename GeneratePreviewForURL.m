#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>
#include "Dot.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */


OSStatus GeneratePreviewForURL_with_svg(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
OSStatus GeneratePreviewForURL_with_img(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
OSStatus GeneratePreviewForURL_with_svg_using_web(void *thisInterface, QLPreviewRequestRef preview,
                                                  CFURLRef url, CFStringRef contentTypeUTI,
                                                  CFDictionaryRef options);

static void LogToFile(const char *szLog);
static void WriteSthToFile(const char *szFile, const char *szText);

#define LOG_FILE_LINE(log) do{ \
        char szBuf[1000]; \
        sprintf(szBuf, "%s (%d): %s: %s\n", __FILE__, __LINE__, __FUNCTION__, log); \
        LogToFile(szBuf); \
    }while(false)

static bool IsBigEnough(const char *szFile)
{
//    LOG_FILE_LINE(szFile);
    FILE *fp = fopen(szFile, "rb");
    bool bRet = false;
    if(fp)
    {
        fseek(fp, 0, SEEK_END);
        int nSize = (int) ftell(fp);
        bRet = nSize > (15 * 1024);
        fclose(fp);
        
//        char szNum[1200];
//        sprintf(szNum, "size of '%s' is %d", szFile, (int) nSize);
//        LOG_FILE_LINE(szNum);
    }
    return bRet;
}

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    int nType = 0;
    nType = 1;
//    nType = 2;
//    nType = 3;
    
    NSString *path = [(__bridge NSURL *)url path];
    if(IsBigEnough([path cStringUsingEncoding:NSUTF8StringEncoding]))
    {
        nType = 2;
    }
    
    if(nType == 1)
    {
        return GeneratePreviewForURL_with_img(thisInterface, preview, url, contentTypeUTI, options);
    }
    else if(nType == 2)
    {
        return GeneratePreviewForURL_with_svg(thisInterface, preview, url, contentTypeUTI, options);
    }
    else if(nType == 3)
    {
        return GeneratePreviewForURL_with_svg_using_web(thisInterface, preview, url, contentTypeUTI, options);
    }
    return noErr;
}
OSStatus GeneratePreviewForURL_with_img(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	
    if (QLPreviewRequestIsCancelled(preview))
        return noErr;
	NSData *imageData = [Dot dataFromDotFile: (__bridge NSURL *)url format:@"-Tpng"];
	NSImage *imageForSize = [[NSImage alloc] initWithData: imageData];
	
	CGSize canvasSize = CGSizeMake(imageForSize.size.width,imageForSize.size.height);

    @autoreleasepool {
        // Preview will be drawn in a vectorized context
        CGContextRef cgContext = QLPreviewRequestCreateContext(preview, *(CGSize *)&canvasSize, true, NULL);
        if(cgContext) { 
			
            CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData ((__bridge CFDataRef)imageData);
            CGImageRef image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
			
            CGContextDrawImage(cgContext,CGRectMake(0, 0, imageForSize.size.width, imageForSize.size.height), image);
            QLPreviewRequestFlushContext(preview, cgContext);
            
            CFRelease(cgContext);
            CFRelease(image);
        } 
 
    }
	
	return noErr;
}

OSStatus GeneratePreviewForURL_with_svg_using_web(void *thisInterface, QLPreviewRequestRef preview,
                               CFURLRef url, CFStringRef contentTypeUTI,
                               CFDictionaryRef options)
{
    NSData *imageData = [Dot dataFromDotFile: (__bridge NSURL *)url format:@"-Tsvg"];
    NSData *data = NULL;
    if (imageData)
    {
        NSString *svg = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
        
        NSMutableString *html = [[NSMutableString alloc] init];
        [html appendString:@"<html>"];
        [html appendString:@"<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"];
        [html appendString:@"<head></head><body><h1>Dot SVG preview with web view</h1>"];
        
        [html appendString:svg];
        
        [html appendString:@"</body></html>"];
        data = [html dataUsingEncoding:NSUTF8StringEncoding];
        
        const char *szText = [html cStringUsingEncoding:NSUTF8StringEncoding];
        WriteSthToFile("/Volumes/Macintosh-HD/Test.localized/TrySomething/mylisp/dot/some.html", szText);
    }
    LogToFile("\r\n\r\n*********************************\r\n");
    if (data) {
        LOG_FILE_LINE("data is ok");
        
        CGSize maxSize = NSMakeSize(60, 80);
        double w = 60;
        double h = 80;
        NSRect viewRect = NSMakeRect(0.0, 0.0, w, h);
        float scale = maxSize.height / h;
        NSSize scaleSize = NSMakeSize(scale, scale);
        CGSize thumbSize = NSSizeToCGSize(
                                          NSMakeSize((maxSize.width * (w / h)),
                                                     maxSize.height));
        LOG_FILE_LINE("before initWithFrame");
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
        
        LOG_FILE_LINE("befor whild");
        while([webView isLoading]) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
        }
        LOG_FILE_LINE("before display");
        
        [webView display];
        LOG_FILE_LINE("before create context");
        
        CGContextRef context =
        QLPreviewRequestCreateContext(preview, thumbSize, false, NULL);
        
        if (context) {
            LOG_FILE_LINE("context is ok");
            NSGraphicsContext* nsContext =
            [NSGraphicsContext
             graphicsContextWithGraphicsPort: (void*) context
													flipped: [webView isFlipped]];
            
            [webView displayRectIgnoringOpacity: [webView bounds]
                                      inContext: nsContext];
            
            QLPreviewRequestFlushContext(preview, context);
            
            CFRelease(context);
            LOG_FILE_LINE("");
        }
        else
        {
            LOG_FILE_LINE("context is null");
        }
    }
    else
    {
        LOG_FILE_LINE("data is null");
    }
    return noErr;
}
OSStatus GeneratePreviewForURL_with_svg(void *thisInterface, QLPreviewRequestRef preview,
                               CFURLRef url, CFStringRef contentTypeUTI,
                               CFDictionaryRef options)
{
    NSData *imageData = [Dot dataFromDotFile: (__bridge NSURL *)url format:@"-Tsvg"];
    if (imageData)
    {
        NSString *svg = [[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding];
        
        NSMutableString *html = [[NSMutableString alloc] init];
        [html appendString:@"<html>"];
        [html appendString:@"<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"];
        [html appendString:@"<head></head><body><h1>Dot SVG preview</h1>"];

        [html appendString:svg];
        
        [html appendString:@"</body></html>"];
        
        CFDictionaryRef properties = (__bridge CFDictionaryRef) [NSDictionary dictionary];
//        CFDictionaryRef properties = (__bridge CFDictionaryRef)@{(NSString *) kQLPreviewPropertyWidthKey: @50, (NSString *)kQLPreviewPropertyWidthKey: @50};
        QLPreviewRequestSetDataRepresentation(preview,
                                              (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding],
                                              kUTTypeHTML,
                                              properties
                                              );
    }
    
    return noErr;
}


void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
static void WriteSthToFile(const char *szFile, const char *szText)
{
    FILE *fp = fopen(szFile, "wb");
    if(fp)
    {
        do
        {
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
static void LogToFile(const char *szLog)
{
    const char *szFile = "/Volumes/Macintosh-HD/Test.localized/TrySomething/mylisp/dot/debug_log.txt";
    FILE *fp = fopen(szFile, "ab");
    if(!fp)
    {
        fp = fopen(szFile, "wb");
    }
    if(fp)
    {
        fwrite(szLog, 1, strlen(szLog), fp);
        fclose(fp);
    }
}
