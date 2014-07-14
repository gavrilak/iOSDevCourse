//
//  TTUser.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTUser.h"
#import "TTServerManager.h"

@implementation TTUser

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        self.user_id = [[responseObject objectForKey:@"id"] stringValue];
        self.first_name = [responseObject objectForKey:@"first_name"];
        self.last_name = [responseObject objectForKey:@"last_name"];
        self.photo_100 = [responseObject objectForKey:@"photo_100"];
    }
    return self;
}


@end
