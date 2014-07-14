//
//  TTTopics.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTUser.h"

@interface TTTopics : NSObject

@property (strong,nonatomic) NSString *topicsid;
@property (strong,nonatomic) NSString *last_comment;
@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *updated;
@property (strong,nonatomic) NSString *comments;
@property (strong,nonatomic) NSString *updated_by;
@property (strong,nonatomic) TTUser *user;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
