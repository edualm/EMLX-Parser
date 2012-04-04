//
//  MEXEMLXFinder.m
//  EMLXParser
//

/*
 
 Copyright (c) 2012 Eduardo Almeida
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "MEXEMLXFinder.h"

#import "NSString+MEXAddons.h"

@implementation MEXEMLXFinder

+ (NSArray *)mailDraftsURLs {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Mail/V2/Mailboxes/" stringByExpandingTildeInPath]]) {
        NSArray *subpaths = [[NSFileManager defaultManager] subpathsAtPath:[@"~/Library/Mail/V2/Mailboxes/" stringByExpandingTildeInPath]];
        
        for (NSString *subpath in subpaths)
            if ([subpath containsString:@"Drafts"]) {
                NSString *thePath = [[@"~/Library/Mail/V2/Mailboxes/" stringByExpandingTildeInPath] stringByAppendingPathComponent:subpath];
                
                thePath = [thePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                NSURL *directoryURL = [NSURL URLWithString:thePath]; // URL pointing to the directory you want to browse
                
                NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
                
                NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                                     enumeratorAtURL:directoryURL
                                                     includingPropertiesForKeys:keys
                                                     options:0
                                                     errorHandler:^(NSURL *url, NSError *error) {
                                                         // Handle the error.
                                                         // Return YES if the enumeration should continue after the error.
                                                         return YES;
                                                     }];
                
                for (NSURL *url in enumerator) { 
                    NSError *error;
                    NSNumber *isDirectory = nil;
                    
                    if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error])
                        NSLog(@"Couldn't get EMLX.");
                    
                    else if (![isDirectory boolValue])
                        if ([[[url path] pathExtension] isEqual:@"emlx"]) {
                            BOOL added = NO;
                            
                            for (id aPath in paths)
                                if ([aPath isEqual:url]) {
                                    added = YES;
                                    break;
                                }
                            
                            if (!added)
                                [paths addObject:url];
                        }
                }
            }
    }
    
    return [paths copy];
}

@end
