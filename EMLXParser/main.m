//
//  main.m
//  EMLXParser
//
//  Created by Eduardo on 17/03/12.
//  Copyright (c) 2012 Bitten Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MEXEMLXFinder.h"
#import "MEXEMLXParser.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSLog(@"EMLX Paths: %@", [MEXEMLXFinder mailDraftsURLs]);
        
        for (NSURL *anURL in [MEXEMLXFinder mailDraftsURLs]) {
            MEXEMLXParser *parser = [[MEXEMLXParser alloc] initWithEMLXFile:anURL];
            
            NSLog(@"Subject: %@", parser.subject);
            
            NSLog(@"Recipent: %@", parser.to);
            
            NSLog(@"Sender: %@", parser.sender);
            
            NSLog(@"Cc: %@", parser.cc);
            
            NSLog(@"Bcc: %@", parser.bcc);
            
            NSLog(@"Attachments: %@", parser.attachments);
            
            NSLog(@"Body: %@", parser.messageBody);
        }
        
        /*MEXEMLXParser *parser = [[MEXEMLXParser alloc] initWithEMLXFile:[NSURL URLWithString:@"/Users/MegaEduX/normal.emlx"]];
        
        NSLog(@"Subject: %@", parser.subject);
        
        NSLog(@"Recipent: %@", parser.to);
        
        NSLog(@"Sender: %@", parser.sender);
        
        NSLog(@"Cc: %@", parser.cc);
        
        NSLog(@"Bcc: %@", parser.bcc);
        
        NSLog(@"Attachments: %@", parser.attachments);
        
        NSLog(@"Body: %@", parser.messageBody);*/
        
    }
    
    return 0;
}

