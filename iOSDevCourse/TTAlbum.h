//
//  TTAlbum.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTAlbum : NSObject

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *description;
@property (strong,nonatomic) NSString *size;
@property (strong,nonatomic) NSString *albumid;
@property (strong,nonatomic) NSMutableArray *photosArray;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
