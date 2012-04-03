//
//  main.m
//  EMLXParser
//
//  Created by Eduardo on 17/03/12.
//  Copyright (c) 2012 Bitten Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MEXEMLXParser.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        
        MEXEMLXParser *parser = [[MEXEMLXParser alloc] initWithEMLXFile:[NSURL URLWithString:@"/Users/MegaEduX/normal.emlx"]];
        
        NSLog(@"Subject: %@", parser.subject);
        
        NSLog(@"Recipent: %@", parser.to);
        
        NSLog(@"Sender: %@", parser.sender);
        
        NSLog(@"Cc: %@", parser.cc);
        
        NSLog(@"Bcc: %@", parser.bcc);
        
        NSLog(@"Attachments: %@", parser.attachments);
        
        NSLog(@"Body: %@", parser.messageBody);
        
    }
    
    return 0;
}

