//
//  BashRun.m
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

#import "NSTask.h"
#import "BashRun.h"

#if !(TARGET_IPHONE_SIMULATOR)
static NSString *locateCommandInPath(NSString *command, NSString *shellPath) {
    
    NSTask *which = [[NSTask alloc] init];
    [which setLaunchPath:shellPath];
    [which setArguments:@[@"-c", [NSString stringWithFormat:@"which %@", command]]];

    NSPipe *outPipe = [NSPipe pipe];
    [which setStandardOutput:outPipe];

    [which launch];
    [which waitUntilExit];

    NSFileHandle *read = [outPipe fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    if ([stringRead containsString:@"not found"] || [stringRead isEqualToString:@""]) {
        return NULL;
    }
        
    return stringRead;
}
#endif

NSString *_Nonnull runCommandInPath(NSString *_Nonnull command) {
    #if !(TARGET_IPHONE_SIMULATOR)
    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    NSString *shellPath = [environmentDict objectForKey:@"SHELL"];
    
    NSString *binary = [command componentsSeparatedByString:@" "][0];
    if (!locateCommandInPath(binary, shellPath)) {
        NSException *exception = [NSException exceptionWithName:@"Binary not found" reason:[NSString stringWithFormat:@"%@ doesn't exist in $PATH", binary] userInfo:nil];
        @throw exception;
    }
    
    NSTask *task = [[NSTask alloc] init];
    
    NSPipe *output = [NSPipe pipe];
    [task setStandardOutput: output];
    
    [task setLaunchPath:shellPath];
    [task setArguments:@[@"-c", command]];
    @try {
        [task launch];
        [task waitUntilExit];
    }
    @catch (NSException *e) {
        @throw e;
    }
    
    NSData * dataRead = [output.fileHandleForReading readDataToEndOfFile];
    return [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    #endif
    return @"";
}
