//
//  TTDocuments.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDocuments : NSObject

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *size;
@property (strong,nonatomic) NSString *ext;
@property (strong,nonatomic) NSString *url;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
