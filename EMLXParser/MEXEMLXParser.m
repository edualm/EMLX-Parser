//
//  MEXEMLXParser.m
//  EMLXParser
//

/*
 
 Copyright (c) 2012 Eduardo Almeida
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "MEXEMLXParser.h"
#import "MEXBase64.h"

#import "NSString+MEXAddons.h"

@implementation MEXEMLXParser

@synthesize emlxFileURL;

- (id)initWithEMLXFile:(NSURL *)filePath {
    if ((self = [super init])) {
        self.emlxFileURL = filePath;
    }
    
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    if ([dataString containsString:@"Content-Type: multipart"])
        messageType = kMultiPartMessage;
    else
        messageType = kNormalMessage;
    
    if (messageType == kMultiPartMessage)
        NSLog(@"Loaded multipart message.");
    else
        NSLog(@"Loaded normal message.");
    
    return self;
}

- (NSString *)subject {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
    
    if (!part)
        part = dataString;
    
    return [part stringBetweenString:@"Subject: " andString:@"\n"];
}

- (NSArray *)to {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
    
    if (!part)
        part = dataString;
    
    part = [part stringByReplacingOccurrencesOfString:@",\n" withString:@"-next-"];
    
    part = [part stringBetweenString:@"To: " andString:@"\n"];
    
    NSMutableArray *addresses = [[part componentsSeparatedByString:@"-next-"] mutableCopy];
    
    for (NSString *address in addresses) {
        if ([address characterAtIndex:0] == [@" " characterAtIndex:0]) {
            NSString *newAddr = [address stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [addresses addObject:newAddr];
            [addresses removeObject:address];
        }
    }
    
    return addresses.copy;
}

- (NSString *)sender {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
    
    if (!part)
        part = dataString;
    
    return [part stringBetweenString:@"From: " andString:@"\n"];
}

- (NSArray *)cc {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
    
    if (!part)
        part = dataString;
    
    part = [part stringByReplacingOccurrencesOfString:@",\n" withString:@"-next-"];
    
    part = [part stringBetweenString:@"Cc: " andString:@"\n"];
    
    NSMutableArray *addresses = [[part componentsSeparatedByString:@"-next-"] mutableCopy];
    
    for (NSString *address in addresses) {
        if ([address characterAtIndex:0] == [@" " characterAtIndex:0]) {
            NSString *newAddr = [address stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [addresses addObject:newAddr];
            [addresses removeObject:address];
        }
    }
    
    return addresses.copy;
}

- (NSArray *)bcc {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
    
    if (!part)
        part = dataString;
    
    part = [part stringByReplacingOccurrencesOfString:@",\n" withString:@"-next-"];
    
    part = [part stringBetweenString:@"Bcc: " andString:@"\n"];
    
    NSMutableArray *addresses = [[part componentsSeparatedByString:@"-next-"] mutableCopy];
    
    for (NSString *address in addresses) {
        if ([address characterAtIndex:0] == [@" " characterAtIndex:0]) {
            NSString *newAddr = [address stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [addresses addObject:newAddr];
            [addresses removeObject:address];
        }
    }
    
    return addresses.copy;
}

- (NSString *)messageID {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    return [dataString stringBetweenString:@"Message-Id: <" andString:@">"];
}

- (NSString *)messageUUID {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    return [dataString stringBetweenString:@"X-Universally-Unique-Identifier: " andString:@"\n"];
}

- (NSString *)messageBody {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    if (messageType == kMultiPartMessage) {
        while (YES) {
            NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
            
            if ([part containsString:@"Content-Type: text/html;"]) {
                NSLog(@"Part is html message.");
                
                NSString *partToRemove = [part stringFromTheBeginningTo:@"\n\n"];
                
                NSString *htmlStr = [part stringByRemovingSubstring:partToRemove];
                
                NSString *strToRemove = [part stringBetweenString:@"<object type=\"application/x-apple-msg-attachment\"" andString:@"</object>"];
                
                if (strToRemove) {
                    strToRemove = [[@"<object type=\"application/x-apple-msg-attachment\"" stringByAppendingString:strToRemove] stringByAppendingString:@"</object>"];
                    
                    htmlStr = [htmlStr stringByRemovingSubstring:strToRemove];
                }
                
                return htmlStr;
            }
            
            if (!part)
                break;
            
            NSLog(@"The current part: %@", part);
            
            dataString = [dataString stringByRemovingSubstring:part];
            
            dataString = [dataString substringFromIndex:13];
        }
    } else {
        NSString *partToRemove = [dataString stringFromTheBeginningTo:@"\n\n"];
        
        return [dataString stringBetweenString:partToRemove andString:@"<?xml"];
    }
    
    return nil;
}

- (NSArray *)attachments {
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *attachmentsArray = [[NSMutableArray alloc] init];
    
    while (YES) {
        NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
        
        if ([part containsString:@"Content-Transfer-Encoding: base64"]) {
            NSLog(@"Part is base64-encoded attachment.");
            
            NSString *partToRemove = [part stringFromTheBeginningTo:@"\n\n"];
            
            NSString *filename = [partToRemove stringBetweenString:@"filename=" andString:@"\n"];
            
            if ([filename characterAtIndex:0] == [@"\"" characterAtIndex:0])
                filename = [filename substringFromIndex:1];
            
            if ([filename characterAtIndex:(filename.length - 1)] == [@"\"" characterAtIndex:0])
                filename = [filename substringToIndex:(filename.length - 2)];
            
            NSLog(@"The filename is %@.", filename);
            
            NSString *base64Str = [part stringByRemovingSubstring:partToRemove];
            
            NSData *attachmentData = [MEXBase64 decodeBase64WithString:base64Str];
            
            [attachmentsArray addObject:attachmentData];
            
        }
        
        NSLog(@"The current part: %@", part);
        
        if (!part)
            break;
        
        dataString = [dataString stringByRemovingSubstring:part];
        
        dataString = [dataString substringFromIndex:13];
    }
    
    return attachmentsArray;

}

- (NSArray *)attachmentPathsDumpedToFolder:(NSString *)path cleaningFolder:(BOOL)shouldCleanFolder {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"Couldn't create working folder.");
            return nil;
        }
    
    if (shouldCleanFolder) {
        NSLog(@"Cleaning path: %@", path);
        
        NSFileManager* fm = [[NSFileManager alloc] init];
        NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];    
        NSError* err = nil;
        BOOL res;
        
        NSString* file;
        while (file = [en nextObject]) {
            res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
            if (!res && err) {
                NSLog(@"Hmm... %@", err);
                return nil;
            }
        }
    }
    
    NSString *dataString = [NSString stringWithContentsOfFile:[emlxFileURL path] encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *pathsArray = [[NSMutableArray alloc] init];
    
    while (YES) {
        NSString *part = [dataString stringFromTheBeginningTo:@"--Apple-Mail="];
        
        if ([part containsString:@"Content-Transfer-Encoding: base64"]) {
            NSLog(@"Part is base64-encoded attachment.");
            
            NSString *partToRemove = [part stringFromTheBeginningTo:@"\n\n"];
            
            NSString *filename = [partToRemove stringBetweenString:@"filename=" andString:@"\n"];
            
            if ([filename characterAtIndex:0] == [@"\"" characterAtIndex:0])
                filename = [filename substringFromIndex:1];
            
            if ([filename characterAtIndex:(filename.length - 1)] == [@"\"" characterAtIndex:0])
                filename = [filename substringToIndex:(filename.length - 2)];
            
            NSLog(@"The filename is %@.", filename);
            
            NSString *base64Str = [part stringByRemovingSubstring:partToRemove];
            
            NSData *attachmentData = [MEXBase64 decodeBase64WithString:base64Str];
            
            if ([attachmentData writeToFile:[path stringByAppendingPathComponent:filename] atomically:YES]) {
                NSLog(@"Wrote attachment to disk: %@", [path stringByAppendingPathComponent:filename]);
                [pathsArray addObject:[path stringByAppendingPathComponent:filename]];
            } else
                return nil;
            
        }
        
        NSLog(@"The current part: %@", part);
        
        if (!part)
            break;
        
        dataString = [dataString stringByRemovingSubstring:part];
        
        dataString = [dataString substringFromIndex:13];
    }
    
    return pathsArray.copy;
}


@end
