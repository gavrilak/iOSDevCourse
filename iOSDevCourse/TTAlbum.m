//
//  TTAlbum.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTAlbum.h"

@implementation TTAlbum


- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.title = [responseObject objectForKey:@"title"];
        self.albumid = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"id"] integerValue]];
        self.size = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"size"] integerValue]];
        self.description = [responseObject objectForKey:@"description"];  
    }
    return self;
}

@end
