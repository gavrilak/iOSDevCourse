//
//  TTUser.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTUser : NSObject

@property (strong,nonatomic) NSString *user_id;
@property (strong,nonatomic) NSString *first_name;
@property (strong,nonatomic) NSString *last_name;
@property (strong,nonatomic) NSString *photo_100;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
