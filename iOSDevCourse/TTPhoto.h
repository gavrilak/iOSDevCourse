//
//  TTPhoto.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/12/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPhoto : NSObject

@property (assign,nonatomic) NSInteger width;
@property (assign,nonatomic) NSInteger height;
@property (strong,nonatomic) NSString *photo_604;
@property (strong,nonatomic) NSString *photo_75;
@property (strong,nonatomic) NSString *photo_130;
@property (strong,nonatomic) NSString *photo_807;
@property (strong,nonatomic) NSString *photo_1280;
@property (strong,nonatomic) NSString *photo_2560;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
