//
//  TTGroup.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/3/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTGroup : NSObject

@property (strong,nonatomic) NSString *group_id;
@property (strong,nonatomic) NSString *desc;
@property (strong,nonatomic) NSString *name;
@property (assign,nonatomic) BOOL is_closed;
@property (assign,nonatomic) BOOL is_member;
@property (strong,nonatomic) NSString *photo_200;
@property (strong,nonatomic) NSString *photos;
@property (strong,nonatomic) NSString *topics;
@property (strong,nonatomic) NSString *videos;
@property (strong,nonatomic) NSString *docs;
@property (strong,nonatomic) NSString *albums;
@property (strong,nonatomic) NSString *members_count;
@property (strong,nonatomic) NSString *status;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
