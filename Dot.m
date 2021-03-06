//
//  Dot.m
//  quicklook-dot
//
//  Created by Besi on 09.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Dot.h"

@implementation Dot

+(NSData *)dataFromDotFile: (NSURL *) dotFile format:(NSString *)format
{
    NSPipe *pipe = [NSPipe pipe];
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath: @"/usr/local/bin/dot"];
//    [task setArguments: [NSArray arrayWithObjects: @"dot", [dotFile path], @"-Tpng", @"-Kfdp", nil]];
    //[task setArguments: [NSArray arrayWithObjects: @"dot", [dotFile path], format, nil]];
    [task setArguments: [NSArray arrayWithObjects: [dotFile path], format, nil]];
//    [task setArguments: [NSArray arrayWithObjects: @"-la", nil]];
    [task setStandardOutput: pipe];
    
    [task launch];
    
    return [[pipe fileHandleForReading] readDataToEndOfFile];
}

@end
