//
//  TTVideo.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTVideo : NSObject

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *views;
@property (strong,nonatomic) NSString *description;
@property (strong,nonatomic) NSString *like_count;
@property (assign,nonatomic) BOOL can_like;
@property (strong,nonatomic) NSString *owner_id;
@property (strong,nonatomic) NSString *videoid;
@property (strong,nonatomic) NSString *photoURL;
@property (strong,nonatomic) NSString *duration;
@property (strong,nonatomic) NSString *fileURl;
@property (strong,nonatomic) NSString *playerURl;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
