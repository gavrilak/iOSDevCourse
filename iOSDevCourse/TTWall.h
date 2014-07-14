//
//  TTWall.h
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/30/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUser;
@class TTGroup;

@interface TTWall : NSObject

@property (strong,nonatomic) NSString *post_id;
@property (strong,nonatomic) NSString *from_id;
@property (strong,nonatomic) NSString *owner_id;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *text;
@property (assign,nonatomic) BOOL can_like;
@property (assign,nonatomic) BOOL can_post;
@property (strong,nonatomic) NSString *likes_count;
@property (strong,nonatomic) NSString *comments_count;
@property (strong,nonatomic) TTUser *from_user;
@property (strong,nonatomic) TTGroup *from_group;
@property (strong,nonatomic) NSArray *attachment;


- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
