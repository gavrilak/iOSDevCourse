//
//  TTComment.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/4/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUser;
@class TTGroup;

@interface TTComment : NSObject

@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *like_count;
@property (assign,nonatomic) BOOL can_like;
@property (strong,nonatomic) NSString *from_id;
@property (strong,nonatomic) NSString *coment_id;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) TTUser *from_user;
@property (strong,nonatomic) TTGroup *from_group;
@property (strong,nonatomic) NSArray *attachment;


- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
