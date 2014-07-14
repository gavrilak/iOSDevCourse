//
//  TTWall.m
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/30/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTWall.h"
#import "TTPhoto.h"
#import "TTVideo.h"
#import "UIImageView+AFNetworking.h"
#import "TTServerManager.h"

@implementation TTWall


- (instancetype)initWithDictionary:(NSDictionary *) responseObject {

    self = [super init];
    if (self) {
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"dd MMM yyyy "];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        NSArray *attachments = [responseObject objectForKey:@"attachments"];
        
        NSMutableArray *tempImageArray = [NSMutableArray array];
        
        for (NSDictionary *dict in attachments) {
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
                
                TTPhoto *photo = [[TTPhoto alloc]initWithDictionary:[dict objectForKey:@"photo"]];
                [tempImageArray addObject:photo];
            }
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"video"]) {
                
                TTVideo *video = [[TTVideo alloc]initWithDictionary:[dict objectForKey:@"video"]];
                [tempImageArray addObject:video];
            }
            
        }
        
        self.attachment = tempImageArray;
        self.text = [self stringByStrippingHTML:[responseObject objectForKey:@"text"]];
        self.owner_id = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"owner_id"]];
        self.post_id = [[responseObject objectForKey:@"id"] stringValue];
        self.likes_count = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"likes"] objectForKey:@"count"]];
        self.can_like = [[[responseObject objectForKey:@"likes"] objectForKey:@"can_like"] boolValue];
        self.can_post = [[[responseObject objectForKey:@"comments"] objectForKey:@"can_post"] boolValue];
        self.comments_count = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"comments"] objectForKey:@"count"]];
        self.from_id = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"from_id"] integerValue]];

    }
    
    return self;
}

- (NSString *) stringByStrippingHTML:(NSString *)string {
    
    NSRange r;
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    }
    
    return string;
}

@end
