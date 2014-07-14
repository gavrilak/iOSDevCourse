//
//  TTPhoto.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/12/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTPhoto.h"

@implementation TTPhoto

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.width = [[responseObject objectForKey:@"width"] integerValue];
        self.height = [[responseObject objectForKey:@"height"] integerValue];
        self.photo_75 = [responseObject objectForKey:@"photo_75"];
        self.photo_130 = [responseObject objectForKey:@"photo_130"];
        self.photo_807 = [responseObject objectForKey:@"photo_807"];
        self.photo_604 = [responseObject objectForKey:@"photo_604"];
        self.photo_1280 = [responseObject objectForKey:@"photo_1280"];
        self.photo_2560 = [responseObject objectForKey:@"photo_2560"];
    }
    return self;
}

@end
