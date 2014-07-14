//
//  TTComment.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/4/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTComment.h"
#import "TTPhoto.h"

@implementation TTComment

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.like_count = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"likes"] objectForKey:@"count"]];
        self.can_like = [[[responseObject objectForKey:@"likes"] objectForKey:@"can_like"] boolValue];
        
        
        NSArray *strArray = [[responseObject objectForKey:@"text"] componentsSeparatedByString:@"]"];
        
        if ([strArray count] > 1) {
            
            NSArray *newStrArray = [[strArray firstObject] componentsSeparatedByString:@"|"];
            
           self.text = [NSString stringWithFormat:@"%@%@",[newStrArray lastObject],[strArray lastObject]];
            
            
        } else {
            self.text = [responseObject objectForKey:@"text"];
        }

        self.coment_id = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"id"]];
        NSMutableArray *tempImageArray = [NSMutableArray array];
        NSArray *attachments = [responseObject objectForKey:@"attachments"];
        
        for (NSDictionary *dict in attachments) {
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"link"]) {

                self.url = [[[attachments objectAtIndex:0] objectForKey:@"link"] objectForKey:@"url"];
            } else if ([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
                
                TTPhoto *photo = [[TTPhoto alloc]initWithDictionary:[dict objectForKey:@"photo"]];
                [tempImageArray addObject:photo];
            }
        }
        
        self.attachment = tempImageArray;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"dd MMM yyyy "];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        self.from_id = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"from_id"]];
        
    }
    return self;
}

@end
