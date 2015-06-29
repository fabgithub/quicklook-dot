#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "Dot.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */


OSStatus GeneratePreviewForURL_with_svg(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
OSStatus GeneratePreviewForURL_with_img(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
#if 1
    return GeneratePreviewForURL_with_svg(thisInterface, preview, url, contentTypeUTI, options);
#else
    return GeneratePreviewForURL_with_img(thisInterface, preview, url, contentTypeUTI, options);
#endif
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
//			CGContextMoveToPoint(cgContext, 10, 10);
//            CGContextAddLineToPoint(cgContext, 0, -300);
//            CGRect rc = {{0, 0,}, {10, 30}};
//            CGContextFillEllipseInRect(cgContext, rc);
            
//            CGContextShowTextAtPoint(cgContext, 10, 10, "some string", 11);
            
            QLPreviewRequestFlushContext(preview, cgContext);
            
            CFRelease(cgContext);
            CFRelease(image);
        } 
 
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
        
        CFDictionaryRef properties = (__bridge CFDictionaryRef)@{(NSString *) kQLPreviewPropertyWidthKey: @500, (NSString *)kQLPreviewPropertyWidthKey: @500};
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
