//
//  TTServerManager.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "AFNetworking.h"
#import "TTServerManager.h"
#import "TTLoginViewController.h"
#import "TTAccessToken.h"
#import "TTGroup.h"
#import "TTWall.h"
#import "TTVideo.h"
#import "TTDocuments.h"
#import "TTComment.h"
#import "TTTopics.h"
#import "TTAlbum.h"
#import "TTPhoto.h"

static NSString* kToken = @"kToken";
static NSString* kExpirationDate = @"kExpirationDate";
static NSString* kUserId = @"kUserId";

NSString * const iOSDevCourseGroupID = @"58860049";

@interface TTServerManager ()

@property (strong,nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (strong, nonatomic) TTAccessToken *accessToken;
@property (strong,nonatomic) dispatch_queue_t requestQueue;

@end

@implementation TTServerManager

+ (TTServerManager *)sharedManager {
    
    static TTServerManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[TTServerManager alloc]init];
        
    });
    
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.requestQueue = dispatch_queue_create("iOSDevCourse.requestVk", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://api.vk.com/method/"]];
        self.accessToken = [[TTAccessToken alloc]init];
        [self loadSettings];
    }
    return self;
}

- (void)saveSettings:(TTAccessToken *)token {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token.token forKey:kToken];
    [userDefaults setObject:token.expirationDate forKey:kExpirationDate];
    [userDefaults setObject:token.userId forKey:kUserId];
    [userDefaults synchronize];
}

- (void)loadSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken.token = [userDefaults objectForKey:kToken];
    self.accessToken.expirationDate = [userDefaults objectForKey:kExpirationDate];
    self.accessToken.userId = [userDefaults objectForKey:kUserId];
    
}

- (void)authorizeUser:(void(^)(TTUser* user))completion {
    
    if ([self.accessToken.expirationDate compare:[NSDate date]] == NSOrderedDescending) {
        
        [self getUserById:self.accessToken.userId onSuccess:^(TTUser *user) {
            
            if (completion) {
                completion(user);
            }
            
        } onFailure:^(NSError *error) {
            if (completion) {
                completion(nil);
            }
        }];
        
    } else {
    
        TTLoginViewController* vc = [[TTLoginViewController alloc] initWithCompletionBlock:^(TTAccessToken *token) {
            
            [self saveSettings:token];
            self.accessToken = token;

            if (token) {
                
                [self getUserById:self.accessToken.userId onSuccess:^(TTUser *user) {
                    
                    if (completion) {
                        completion(user);
                    }
                    
                } onFailure:^(NSError *error) {
                    if (completion) {
                        completion(nil);
                    }
                }];
                
            } else if (completion) {
                completion(nil);
            }
            
        }];
        
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        
        [mainVC presentViewController:nav animated:YES completion:nil];
        
    }
}

- (void)getGroupById:(NSString *)group_id
           onSuccess:(void (^) (TTGroup *group))success
           onFailure:(void (^) (NSError *error)) failure {
    
    NSDictionary *parameters = @{@"group_id"        : group_id,
                                 @"fields"          : @"description,counters,members_count,status",
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };
    
    [self.requestOperationManager GET:@"groups.getById" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            
            NSArray *objects = [responseObject objectForKey:@"response"];
            
            TTGroup *group = [[TTGroup alloc]initWithDictionary:[objects firstObject]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.group = group;
                success(group);
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getUserById:(NSString *)user_id
          onSuccess:(void (^)(TTUser *user))success
          onFailure:(void (^)(NSError *))failure {
    
    NSDictionary *parameters = @{@"user_ids"        : user_id,
                                 @"fields"          : @"photo_100",
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };
    
    [self.requestOperationManager GET:@"users.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            
            NSArray *objects = [responseObject objectForKey:@"response"];
            TTUser *user = [[TTUser alloc]initWithDictionary:[objects firstObject]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success) {
                    success(user);
                }
            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)getUsersByIds:(NSArray *)user_ids
          onSuccess:(void (^)(NSArray *usersArray))success
          onFailure:(void (^)(NSError *))failure {
    
    NSDictionary *parameters = @{@"user_ids"        : user_ids,
                                 @"fields"          : @"photo_100",
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };
    
    [self.requestOperationManager GET:@"users.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            
            NSArray *objects = [responseObject objectForKey:@"response"];
            
            NSMutableArray *arrayWithobjects = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [objects count]; i++) {
                TTUser *user = [[TTUser alloc]initWithDictionary:[objects objectAtIndex:i]];
                [arrayWithobjects addObject:user];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success) {
                    success(arrayWithobjects);
                }
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)getWallPostGroup:(NSString *)group_id
                   count:(NSInteger)count
                  offset:(NSInteger)offset
               onSuccess:(void (^) (NSArray *wallPost))success
               onFailure:(void (^) (NSError *error))failure {

    NSString *idGroup = [NSString stringWithFormat:@"%@",group_id];

    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }

    NSDictionary *parameters = @{@"owner_id"        : idGroup,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"filter"          : @"all",
                                 @"extended"        : @"1",
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"wall.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSArray *wallArray = [objects objectForKey:@"items"];
            
            NSArray *profilesArray = [objects objectForKey:@"profiles"];
            
            NSMutableArray *arrayWithProfiles = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dict in profilesArray) {
                
                TTUser *user = [[TTUser alloc]initWithDictionary:dict];
                
                [arrayWithProfiles addObject:user];
                
            }
            
            TTGroup *group = [[TTGroup alloc]initWithDictionary:[[objects objectForKey:@"groups"] objectAtIndex:0]];
            
            NSMutableArray *arrayWithWall = [[NSMutableArray alloc]init];
            
            
            for (int i = 0; i < [wallArray count]; i++) {
                
                TTWall *wall = [[TTWall alloc]initWithDictionary:[wallArray objectAtIndex:i]];
                
                if ([wall.from_id hasPrefix:@"-"]) {
                    
                    wall.from_group = group;
                    [arrayWithWall addObject:wall];
                    continue;
                }
                
                for (TTUser *user in arrayWithProfiles) {
                    
                    if ([wall.from_id isEqualToString:user.user_id]) {
                        
                        wall.from_user = user;
                        [arrayWithWall addObject:wall];
                        break;
                    }
                    
                }
                
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success) {
                    success(arrayWithWall);
                }
            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];



}

- (void)getVideo:(NSString *)group_id
         videoid:(NSString *)video_id
       onSuccess:(void (^) (TTVideo *video))success
       onFailure:(void (^) (NSError *error)) failure {
    
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",group_id];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSString *videos = [NSString stringWithFormat:@"%@_%@",idGroup,video_id];
    
    NSDictionary *parameters = @{@"owner_id"        : idGroup,
                                 @"videos"          : videos,
                                 @"count"           : @(1),
                                 @"offset"          : @(0),
                                 @"v"               : @"5.21",
                                 @"width"           : @"320",
                                 @"extended"        : @"1",
                                 @"access_token"    : self.accessToken.token };
    
    
    [self.requestOperationManager GET:@"video.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSArray *videoArray = [objects objectForKey:@"items"];
            TTVideo *video = [[TTVideo alloc]initWithDictionary:[videoArray firstObject]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success) {
                    success(video);
                }
                
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}

- (void)getVideoGroup:(NSString *)group_id
                count:(NSInteger)count
               offset:(NSInteger)offset
            onSuccess:(void (^) (NSArray *videoGroupArray))success
            onFailure:(void (^) (NSError *error)) failure {
    
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",group_id];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *parameters = @{@"owner_id"        : idGroup ,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"width"           : @"320",
                                 @"extended"        : @"1",
                                 @"access_token"    : self.accessToken.token };
    
    
    [self.requestOperationManager GET:@"video.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSArray *videoArray = [objects objectForKey:@"items"];
            
            NSMutableArray *arrayWithVideo = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [videoArray count]; i++) {
                
                TTVideo *user = [[TTVideo alloc]initWithDictionary:[videoArray objectAtIndex:i]];
                
                [arrayWithVideo addObject:user];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(arrayWithVideo);
                }
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}

- (void)getVideoComment:(NSString *)group_id
                videoid:(NSString *)video_id
                  count:(NSInteger)count
                 offset:(NSInteger)offset
              onSuccess:(void (^) (NSArray *videoCommentArray))success
              onFailure:(void (^) (NSError *error)) failure {
    
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",group_id];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *parameters = @{@"owner_id"        : idGroup ,
                                 @"video_id"        : video_id,
                                 @"need_likes"      : @"1",
                                 @"sort"            : @"desc",
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };
    
    
    [self.requestOperationManager GET:@"video.getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(self.requestQueue, ^{
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSArray *objectsArray = [objects objectForKey:@"items"];
            
            NSMutableArray *arrayWithobjects = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [objectsArray count]; i++) {
                
                TTComment *comment = [[TTComment alloc]initWithDictionary:[objectsArray objectAtIndex:i]];
                
                [arrayWithobjects addObject:comment];
                
            }
            
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_enter(group);
            
            NSArray *users = [arrayWithobjects valueForKeyPath:@"@distinctUnionOfObjects.from_id"];
            
            [self getUsersByIds:users onSuccess:^(NSArray *usersArray) {
                
                for (int i = 0; i < [arrayWithobjects count]; i++) {
                    
                    TTComment *comment = [arrayWithobjects objectAtIndex:i];
                    
                    for (TTUser *user in usersArray) {
                        if ([comment.from_id isEqualToString:user.user_id]) {
                            comment.from_user = user;
                            break;
                        }
                    }
                }
                
                dispatch_group_leave(group);
                
            } onFailure:^(NSError *error) {
                
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    
                    if (success) {
                        success(arrayWithobjects);
                    }
                });
            });
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}

- (void)getDocumentGroup:(NSString *)group_id
                   count:(NSInteger)count
                  offset:(NSInteger)offset
               onSuccess:(void (^) (NSArray *docGroupArray))success
               onFailure:(void (^) (NSError *error)) failure {

    NSString *idGroup = [NSString stringWithFormat:@"%@",group_id];

    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }

    NSDictionary *parameters = @{@"owner_id"        : idGroup,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"docs.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{

            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSArray *documentsArray = [objects objectForKey:@"items"];

            NSMutableArray *arrayWithData = [[NSMutableArray alloc]init];

            for (int i = 0; i < [documentsArray count]; i++) {

                TTDocuments *doc = [[TTDocuments alloc]initWithDictionary:[documentsArray objectAtIndex:i]];
                [arrayWithData addObject:doc];

            }

            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithData);
            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}

- (void)postLikeOnWall:(NSString*)groupID
                 inPost:(NSString*)postID
                   type:(NSString *)type
              onSuccess:(void(^)(NSDictionary* result))success
              onFailure:(void(^)(NSError* error, NSInteger statusCode))failure {


    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];

    if ([type isEqualToString:@"topic_comment"]) {

        if (![idGroup hasPrefix:@"-"]) {
            idGroup = [@"-" stringByAppendingString:idGroup];
        }

    }
    
    NSDictionary *parameters = @{@"type"            : type,
                                 @"owner_id"        : idGroup,
                                 @"item_id"         : postID,
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager POST:@"likes.add" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {

        
        
        if (success) {
            success(responseObject);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];

}

- (void)repostOnMyWall:(NSString*)groupID
                 inPost:(NSString*)postID
            withMessage:(NSString*)message
              onSuccess:(void(^)(NSDictionary* result))success
              onFailure:(void(^)(NSError* error, NSInteger statusCode))failure {
    
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];
        
        if (![idGroup hasPrefix:@"-"]) {
            idGroup = [@"-" stringByAppendingString:idGroup];
        }
    
    NSString *object = [NSString stringWithFormat:@"wall%@_%@",idGroup,postID];
    
    NSDictionary *parameters = @{@"object"          : object,
                                 @"message"         : message,
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };
    
    [self.requestOperationManager POST:@"wall.repost" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
        
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
}

- (void)postDeleteLikeOnWall:(NSString*)groupID
                       inPost:(NSString*)postID
                         type:(NSString *)type
                    onSuccess:(void(^)(NSDictionary* result))success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode))failure {


    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];

    if ([type isEqualToString:@"topic_comment"]) {

        if (![idGroup hasPrefix:@"-"]) {
            idGroup = [@"-" stringByAppendingString:idGroup];
        }

    }

    NSDictionary *parameters = @{@"type"            : type,
                                 @"owner_id"        : idGroup,
                                 @"item_id"         : postID,
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager POST:@"likes.delete" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {

        if (success) {
            success(responseObject);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];

}

- (void)getTopicsGroup:(NSString *)group_id
                 count:(NSInteger)count
                offset:(NSInteger)offset
             onSuccess:(void (^) (NSArray *topicsGroupArray))success
             onFailure:(void (^) (NSError *error)) failure {

    NSDictionary *parameters = @{@"group_id"        : group_id,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"extended"        : @"1",
                                 @"preview"         : @"2",
                                 @"preview_length"  : @"0",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"board.getTopics" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{

            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSArray *topicsArray = [objects objectForKey:@"items"];
            NSArray *profileArray = [objects objectForKey:@"profiles"];

            NSMutableArray *arrayWithData = [[NSMutableArray alloc]init];
            NSMutableArray *arrayWithLastUser = [[NSMutableArray alloc]init];

            for (int i = 0; i < [profileArray count]; i++) {
                TTUser *user = [[TTUser alloc]initWithDictionary:[profileArray objectAtIndex:i]];
                [arrayWithLastUser addObject:user];
            }

            for (int i = 0; i < [topicsArray count]; i++) {

                TTTopics *topics = [[TTTopics alloc]initWithDictionary:[topicsArray objectAtIndex:i]];

                for (TTUser *user in arrayWithLastUser) {

                    if ([topics.updated_by isEqualToString:user.user_id]) {
                        topics.user = user;
                        [arrayWithData addObject:topics];
                        break;
                    }

                }

            }

            dispatch_async(dispatch_get_main_queue(), ^{

                success(arrayWithData);

            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}

- (void)getCommentTopicById:(NSString *)ids
                    ownerID:(NSString *)ownerIDs
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray *wallComment))success
                  onFailure:(void (^) (NSError *error)) failure {

    NSDictionary *parameters = @{@"topic_id"        : ids,
                                 @"group_id"        : ownerIDs,
                                 @"need_likes"      : @"1",
                                 @"sort"            : @"desc",
                                 @"extended"        : @"1",
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"board.getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{

            NSLog(@"%@",responseObject);
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSArray *commentsArray = [objects objectForKey:@"items"];
            NSArray *profilesArray = [objects objectForKey:@"profiles"];

            NSMutableArray *arrayWithWallComent = [[NSMutableArray alloc]init];
            NSMutableArray *arrayWithProfile = [[NSMutableArray alloc]init];

            for (int i = 0; i < [commentsArray count]; i++) {

                TTComment *comment = [[TTComment alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
                [arrayWithWallComent addObject:comment];

            }

            for (int i = 0; i < [profilesArray count]; i++) {

                TTUser *user = [[TTUser alloc]initWithDictionary:[profilesArray objectAtIndex:i]];
                [arrayWithProfile addObject:user];

            }

            for (TTComment *comment in arrayWithWallComent) {

                for (TTUser *user in arrayWithProfile) {
                    if ([comment.from_id isEqualToString:user.user_id]) {
                        comment.from_user = user;
                        break;
                    }
                }

            }

            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithWallComent);
            });
        });


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}

- (void)getMembersInGroupId:(NSString *)ids
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray *membersArray))success
                  onFailure:(void (^) (NSError *error)) failure {

    NSDictionary *parameters = @{@"group_id"        : ids ,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"sort"            : @"id_asc",
                                 @"fields"          : @"first_name,last_name,photo_50,photo_100",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"groups.getMembers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{

            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSArray *userArray = [objects objectForKey:@"items"];

            NSMutableArray *arrayWithMembers = [[NSMutableArray alloc]init];

            for (int i = 0; i < [userArray count]; i++) {

                TTUser *user = [[TTUser alloc]initWithDictionary:[userArray objectAtIndex:i]];

                [arrayWithMembers addObject:user];

            }

            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithMembers);
            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}


- (void)postVideoCreateCommentText:(NSString*)text
                             image:(NSArray *)image
                       onGroupWall:(NSString*)groupID
                           videoid:(NSString*) videoid
                         onSuccess:(void(^)(id result))success
                         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {

    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];

    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }


    if (image != nil) {
        
        NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.group.group_id,@"group_id",@"5.21",@"v",self.accessToken.token,@"access_token", nil];

        [self.requestOperationManager GET:@"photos.getWallUploadServer" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);

            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSString *upload_url = [objects objectForKey:@"upload_url"];
            NSString *user_id = [objects objectForKey:@"user_id"];

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

            [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                for (int i = 0; i < [image count]; i++) {
                    UIImage *img = [image objectAtIndex:i];
                    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i] fileName:[NSString stringWithFormat:@"file%d.png",i] mimeType:@"image/jpeg"];
                }

            } success:^(AFHTTPRequestOperation *operation, id responseObject) {

                NSLog(@"Success: %@", responseObject);

                NSString *hash = [responseObject objectForKey:@"hash"];
                NSString *photo = [responseObject objectForKey:@"photo"];
                NSString *server = [responseObject objectForKey:@"server"];


                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",self.group.group_id,@"group_id",server,@"server",photo,@"photo",hash,@"hash",@"5.21",@"v",self.accessToken.token,@"access_token", nil];

                [self.requestOperationManager GET:@"photos.saveWallPhoto" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {

                    NSLog(@"Success: %@", responseObject);

                    NSArray *objects = [responseObject objectForKey:@"response"];
                    
                    NSMutableString *attachments = [NSMutableString string];
                    
                    for (NSDictionary *dict in objects) {
                        
                        NSString *owner_id = [dict objectForKey:@"owner_id"];
                        NSString *media_id = [dict objectForKey:@"id"];
                        
                        [attachments appendString:[NSString stringWithFormat:@"photo%@_%@,",owner_id,media_id]];
                        
                    }

                    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",videoid,@"video_id",text,@"message",attachments,@"attachments",self.accessToken.token, @"access_token", nil];

                    [self.requestOperationManager POST:@"video.createComment" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {

                        NSLog(@"JSON: %@", responseObject);

                        if (success) {
                            success(responseObject);
                        }

                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                        if (failure) {
                            failure(error, operation.response.statusCode);
                        }
                    }];



                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                }];


            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        }];



    } else {

        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",text,@"message",self.accessToken.token, @"access_token", nil];

        [self.requestOperationManager POST:@"video.createComment" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {

             if (success) {
                 success(responseObject);
             }

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

             if (failure) {
                 failure(error, operation.response.statusCode);
             }
         }];
    }

}

- (void)postWallCreateCommentText:(NSString*)text
                            image:(NSArray *)image
                      onGroupWall:(NSString*)groupID
                        onSuccess:(void(^)(id result))success
                        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    if (image != nil) {
        
        
        NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.group.group_id,@"group_id",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
        
        [self.requestOperationManager GET:@"photos.getWallUploadServer" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSString *upload_url = [objects objectForKey:@"upload_url"];
            NSString *user_id = [objects objectForKey:@"user_id"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                for (int i = 0; i < [image count]; i++) {
                    UIImage *img = [image objectAtIndex:i];
                    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i] fileName:[NSString stringWithFormat:@"file%d.png",i] mimeType:@"image/jpeg"];
                }
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"Success: %@", responseObject);
                
                NSString *hash = [responseObject objectForKey:@"hash"];
                NSString *photo = [responseObject objectForKey:@"photo"];
                NSString *server = [responseObject objectForKey:@"server"];
                
                
                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",self.group.group_id,@"group_id",server,@"server",photo,@"photo",hash,@"hash",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
                
                [self.requestOperationManager GET:@"photos.saveWallPhoto" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"Success: %@", responseObject);
                    
                    NSArray *objects = [responseObject objectForKey:@"response"];
                    
                    NSMutableString *attachments = [NSMutableString string];
                    
                    for (NSDictionary *dict in objects) {
                        
                        NSString *owner_id = [dict objectForKey:@"owner_id"];
                        NSString *media_id = [dict objectForKey:@"id"];
                        
                        [attachments appendString:[NSString stringWithFormat:@"photo%@_%@,",owner_id,media_id]];
                        
                    }
                    
                    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",text,@"message",attachments,@"attachments",self.accessToken.token, @"access_token", nil];
                    
                    [self.requestOperationManager POST:@"wall.post" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                        
                        NSLog(@"JSON: %@", responseObject);
                        
                        if (success) {
                            success(responseObject);
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        if (failure) {
                            failure(error, operation.response.statusCode);
                        }
                    }];
                    
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
        
        
    } else {
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",text,@"message",self.accessToken.token, @"access_token", nil];
        
        [self.requestOperationManager POST:@"wall.post" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            if (success) {
                success(responseObject);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
    }
    
}

- (void)getCommentById:(NSString *)ids
               ownerID:(NSString *)ownerIDs
                 count:(NSInteger)count
                offset:(NSInteger)offset
             onSuccess:(void (^) (NSArray *wallComment))success
             onFailure:(void (^) (NSError *error)) failure {


    NSDictionary *parameters = @{@"owner_id"        : ownerIDs,
                                 @"post_id"         : ids,
                                 @"need_likes"      : @"1",
                                 @"extended"        : @"1",
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"sort"            : @"desc",
                                 @"fields"          : @"first_name,last_name,photo_50,photo_100",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"wall.getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSArray *commentsArray = [objects objectForKey:@"items"];
            NSArray *profilesArray = [objects objectForKey:@"profiles"];
            
            NSMutableArray *arrayWithWallComent = [[NSMutableArray alloc]init];
            NSMutableArray *arrayWithProfile = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [commentsArray count]; i++) {
                
                TTComment *comment = [[TTComment alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
                [arrayWithWallComent addObject:comment];
                
            }
            
            for (int i = 0; i < [profilesArray count]; i++) {
                
                TTUser *user = [[TTUser alloc]initWithDictionary:[profilesArray objectAtIndex:i]];
                [arrayWithProfile addObject:user];
                
            }
            
            for (TTComment *comment in arrayWithWallComent) {
                
                for (TTUser *user in arrayWithProfile) {
                    if ([comment.from_id isEqualToString:user.user_id]) {
                        comment.from_user = user;
                        break;
                    }
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithWallComent);
            });
        });
        
        

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}

- (void)postWallAddCommentText:(NSString*)text
                         image:(NSArray *)image
                   onGroupWall:(NSString*)groupID
                  onGroupTopic:(NSString*)topicID
                     onSuccess:(void(^)(id result))success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode))failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    if ([image count] > 0) {
        
        NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.group.group_id,@"group_id",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
        
        [self.requestOperationManager GET:@"photos.getWallUploadServer" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSString *upload_url = [objects objectForKey:@"upload_url"];
            NSString *user_id = [objects objectForKey:@"user_id"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                for (int i = 0; i < [image count]; i++) {
                    UIImage *img = [image objectAtIndex:i];
                    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i] fileName:[NSString stringWithFormat:@"file%d.png",i] mimeType:@"image/jpeg"];
                }
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"Success: %@", responseObject);
                
                NSString *hash = [responseObject objectForKey:@"hash"];
                NSString *photo = [responseObject objectForKey:@"photo"];
                NSString *server = [responseObject objectForKey:@"server"];
                
                
                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",self.group.group_id,@"group_id",server,@"server",photo,@"photo",hash,@"hash",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
                
                [self.requestOperationManager GET:@"photos.saveWallPhoto" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"Success: %@", responseObject);
                    
                    NSArray *objects = [responseObject objectForKey:@"response"];
                    
                    NSMutableString *attachments = [NSMutableString string];
                    
                    for (NSDictionary *dict in objects) {
                        
                        NSString *owner_id = [dict objectForKey:@"owner_id"];
                        NSString *media_id = [dict objectForKey:@"id"];
                        
                        [attachments appendString:[NSString stringWithFormat:@"photo%@_%@,",owner_id,media_id]];
                        
                    }
                    
                    NSDictionary *parameters = @{@"owner_id"        : groupID,
                                                 @"post_id"         : topicID,
                                                 @"text"            : text,
                                                 @"attachments"     : attachments,
                                                 @"v"               : @"5.21",
                                                 @"access_token"    : self.accessToken.token };
                    
                    [self.requestOperationManager POST:@"wall.addComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                        
                        NSLog(@"JSON: %@", responseObject);
                        
                        if (success) {
                            success(responseObject);
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        if (failure) {
                            failure(error, operation.response.statusCode);
                        }
                    }];
                    
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
        
        
    } else {
        
        NSDictionary *parameters = @{@"owner_id"        : groupID,
                                     @"post_id"         : topicID,
                                     @"text"            : text,
                                     @"v"               : @"5.21",
                                     @"access_token"    : self.accessToken.token };
        
        [self.requestOperationManager POST:@"wall.addComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
            
            if (success) {
                success(responseObject);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
    }
    
}

- (void)postTopicAddCommentText:(NSString*)text
                         image:(NSArray *)image
                   onGroupWall:(NSString*)groupID
                  onGroupTopic:(NSString*)topicID
                     onSuccess:(void(^)(id result))success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode))failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    if ([image count] > 0) {
        
        NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.group.group_id,@"group_id",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
        
        [self.requestOperationManager GET:@"photos.getWallUploadServer" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSString *upload_url = [objects objectForKey:@"upload_url"];
            NSString *user_id = [objects objectForKey:@"user_id"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                for (int i = 0; i < [image count]; i++) {
                    UIImage *img = [image objectAtIndex:i];
                    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i] fileName:[NSString stringWithFormat:@"file%d.png",i] mimeType:@"image/jpeg"];
                }
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"Success: %@", responseObject);
                
                NSString *hash = [responseObject objectForKey:@"hash"];
                NSString *photo = [responseObject objectForKey:@"photo"];
                NSString *server = [responseObject objectForKey:@"server"];
                
                
                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",self.group.group_id,@"group_id",server,@"server",photo,@"photo",hash,@"hash",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
                
                [self.requestOperationManager GET:@"photos.saveWallPhoto" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"Success: %@", responseObject);
                    
                    NSArray *objects = [responseObject objectForKey:@"response"];
                    
                    NSMutableString *attachments = [NSMutableString string];
                    
                    for (NSDictionary *dict in objects) {
                        
                        NSString *owner_id = [dict objectForKey:@"owner_id"];
                        NSString *media_id = [dict objectForKey:@"id"];
                        
                        [attachments appendString:[NSString stringWithFormat:@"photo%@_%@,",owner_id,media_id]];
                        
                    }
                    
                    NSDictionary *parameters = @{@"group_id"        : groupID,
                                                 @"topic_id"        : topicID,
                                                 @"text"            : text,
                                                 @"attachments"     : attachments,
                                                 @"v"               : @"5.21",
                                                 @"access_token"    : self.accessToken.token };
                    
                    [self.requestOperationManager POST:@"board.addComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                        
                        NSLog(@"JSON: %@", responseObject);
                        
                        if (success) {
                            success(responseObject);
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        if (failure) {
                            failure(error, operation.response.statusCode);
                        }
                    }];
                    
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
        
        
    } else {
        
        NSDictionary *parameters = @{@"group_id"        : groupID,
                                     @"topic_id"        : topicID,
                                     @"text"            : text,
                                     @"v"               : @"5.21",
                                     @"access_token"    : self.accessToken.token };
        
        [self.requestOperationManager POST:@"board.addComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
            
            if (success) {
                success(responseObject);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (failure) {
                failure(error, operation.response.statusCode);
            }
        }];
    }
    
}

- (void)getAlbumsGrouppById:(NSString *)ids
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray *arrayWithAlbums))success
                  onFailure:(void (^) (NSError *error)) failure {

    NSString *idGroup = [NSString stringWithFormat:@"%@",ids];

    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }

    NSDictionary *parameters = @{@"owner_id"        : idGroup ,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"photos.getAlbums" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSArray *commentsArray = [objects objectForKey:@"items"];

            NSMutableArray *arrayWithAlbums = [[NSMutableArray alloc]init];

            for (int i = 0; i < [commentsArray count]; i++) {

                TTAlbum *album = [[TTAlbum alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
                [arrayWithAlbums addObject:album];

            }

            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithAlbums);
            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];

}

- (void)getPhotosFromAlbumID:(NSString *)ids
                     ownerID:(NSString *)ownerIDs
                       count:(NSInteger)count offset:(NSInteger)offset
                   onSuccess:(void (^) (NSArray *arrayWithPhotos))success
                   onFailure:(void (^) (NSError *error)) failure {

    NSString *idGroup = [NSString stringWithFormat:@"%@",ownerIDs];

    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }

    NSDictionary *parameters = @{@"owner_id"        : idGroup ,
                                 @"album_id"        : ids,
                                 @"count"           : @(count),
                                 @"offset"          : @(offset),
                                 @"extended"        : @"1",
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };

    [self.requestOperationManager GET:@"photos.get" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        dispatch_async(self.requestQueue, ^{

            NSDictionary *objects = [responseObject objectForKey:@"response"];

            NSArray *photosArray = [objects objectForKey:@"items"];

            NSMutableArray *arrayWithPhotos = [[NSMutableArray alloc]init];

            for (int i = 0; i < [photosArray count]; i++) {

                TTPhoto *photo = [[TTPhoto alloc]initWithDictionary:[photosArray objectAtIndex:i]];

                [arrayWithPhotos addObject:photo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                success(arrayWithPhotos);
            });
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];


}

- (void)postImageInAlbumsIds:(NSString *)ids
                       image:(UIImage *)image
                   onSuccess:(void (^)(id responseObject))success
                   onFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = @{@"group_id"        : self.group.group_id,
                                 @"album_id"        : ids,
                                 @"v"               : @"5.21",
                                 @"access_token"    : self.accessToken.token };
    
    [self.requestOperationManager GET:@"photos.getUploadServer" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        NSString *upload_url = [objects objectForKey:@"upload_url"];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:imageData name:@"file1" fileName:@"file1.png" mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *parameters = @{@"album_id"        : [responseObject objectForKey:@"aid"],
                                         @"group_id"        : [responseObject objectForKey:@"gid"],
                                         @"server"          : [responseObject objectForKey:@"server"],
                                         @"photos_list"     : [responseObject objectForKey:@"photos_list"],
                                         @"hash"            : [responseObject objectForKey:@"hash"],
                                         @"v"               : @"5.21",
                                         @"access_token"    : self.accessToken.token };
            
            [self.requestOperationManager GET:@"photos.save" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                success(responseObject);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

//- (void)getGroupMembersCountById:(NSString *)ids
//                       onSuccess:(void (^) (NSString *membersCount))success
//                       onFailure:(void (^) (NSError *error)) failure {
//    
//    NSDictionary *parameters = @{@"group_id"        : ids ,
//                                 @"count"           : @"0",
//                                 @"offset"          : @"0",
//                                 @"v"               : @"5.21",
//                                 @"access_token"    : self.accessToken.token };
//    
//    [self.requestOperationManager GET:@"groups.getMembers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            NSDictionary *objects = [responseObject objectForKey:@"response"];
//            NSString *membersCount = [NSString stringWithFormat:@"%ld",(long)[[objects objectForKey:@"count"] integerValue]];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//               success(membersCount);
//            });
//        });
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(error);
//    }];
//    
//}



//- (void)getCityWithIds:(NSString *)ids onSuccess:(void (^) (NSString *city)) success onFailure:(void (^) (NSError *error)) failure {
//    
//    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"city_ids", nil];
//    
//    [self.requestOperationManager GET:@"database.getCitiesById" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSArray *objects = [responseObject objectForKey:@"response"];
//        NSString* city = [[objects firstObject] objectForKey:@"name"];
//        success(city);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //NSLog(@"Error: %@", error);
//        failure(error);
//    }];
//    
//}


//- (void)getCountryWithIds:(NSString *)ids onSuccess:(void (^) (NSString *country)) success onFailure:(void (^) (NSError *error)) failure {
//
//    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"country_ids", nil];
//    
//    [self.requestOperationManager GET:@"database.getCountriesById" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //NSLog(@"JSON: %@", responseObject);
//        
//        NSArray *objects = [responseObject objectForKey:@"response"];
//        NSString* country = [[objects firstObject] objectForKey:@"name"];
//        success(country);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        failure(error);
//    }];
//    
//}

@end
