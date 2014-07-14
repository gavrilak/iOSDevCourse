//
//  TTDocuments.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDocuments.h"

@implementation TTDocuments

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.title = [responseObject objectForKey:@"title"];
        self.size = [NSByteCountFormatter stringFromByteCount:[[responseObject objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleFile];
        self.ext = [responseObject objectForKey:@"ext"];
        self.url = [responseObject objectForKey:@"url"];
        
    }
    return self;
}
@end
