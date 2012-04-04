//
//  MEXEMLXFinder.m
//  EMLXParser
//
//  Created by Eduardo Manuel on 03/04/12.
//  Copyright (c) 2012 Bitten Apps. All rights reserved.
//

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
