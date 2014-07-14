//
//  TTServerManager.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTUser.h"
#import "TTGroup.h"

@class TTVideo;

extern NSString * const iOSDevCourseGroupID;

@interface TTServerManager : NSObject

@property (strong,nonatomic) TTGroup *group;

+ (TTServerManager *)sharedManager;

- (void) authorizeUser:(void(^)(TTUser* user))completion;

- (void)getGroupById:(NSString *)group_id
           onSuccess:(void (^) (TTGroup *group))success
           onFailure:(void (^) (NSError *error))failure;

- (void)getUserById:(NSString *)user_id
          onSuccess:(void (^) (TTUser *user))success
          onFailure:(void (^) (NSError *error))failure;

- (void)getWallPostGroup:(NSString *)group_id
                   count:(NSInteger)count
                  offset:(NSInteger)offset
               onSuccess:(void (^) (NSArray *wallPost))success
               onFailure:(void (^) (NSError *error))failure;

- (void)getVideoGroup:(NSString *)group_id
                count:(NSInteger)count
               offset:(NSInteger)offset
            onSuccess:(void (^) (NSArray *videoGroupArray))success
            onFailure:(void (^) (NSError *error)) failure;

- (void)getDocumentGroup:(NSString *)group_id
                   count:(NSInteger)count
                  offset:(NSInteger)offset
               onSuccess:(void (^) (NSArray *docGroupArray))success
               onFailure:(void (^) (NSError *error)) failure;

- (void)getVideoComment:(NSString *)group_id
                videoid:(NSString *)video_id
                  count:(NSInteger)count
                 offset:(NSInteger)offset
              onSuccess:(void (^) (NSArray *videoCommentArray))success
              onFailure:(void (^) (NSError *error)) failure;

- (void)getVideo:(NSString *)group_id
         videoid:(NSString *)video_id
       onSuccess:(void (^) (TTVideo *video))success
       onFailure:(void (^) (NSError *error)) failure;

- (void)getUsersByIds:(NSArray *)user_ids
            onSuccess:(void (^)(NSArray *usersArray))success
            onFailure:(void (^)(NSError *error))failure;

- (void) postLikeOnWall:(NSString *)groupID
                 inPost:(NSString *)postID
                   type:(NSString *)type
              onSuccess:(void(^)(NSDictionary* result))success
              onFailure:(void(^)(NSError* error, NSInteger statusCode))failure;

- (void) postDeleteLikeOnWall:(NSString *)groupID
                       inPost:(NSString *)postID
                         type:(NSString *)type
                    onSuccess:(void(^)(NSDictionary* result))success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode))failure;

- (void)getTopicsGroup:(NSString *)group_id
                 count:(NSInteger)count
                offset:(NSInteger)offset
             onSuccess:(void (^) (NSArray *topicsGroupArray))success
             onFailure:(void (^) (NSError *error)) failure;

- (void)getCommentTopicById:(NSString *)ids
                    ownerID:(NSString *)ownerIDs
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray *wallComment))success
                  onFailure:(void (^) (NSError *error)) failure;

- (void)getMembersInGroupId:(NSString *)ids
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray *membersArray))success
                  onFailure:(void (^) (NSError *error)) failure;

- (void)postVideoCreateCommentText:(NSString*)text
                             image:(NSArray *)image
                       onGroupWall:(NSString*)groupID
                           videoid:(NSString*) videoid
                         onSuccess:(void(^)(id result))success
                         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)postWallCreateCommentText:(NSString*)text
                            image:(NSArray *)image
                      onGroupWall:(NSString*)groupID
                        onSuccess:(void(^)(id result))success
                        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getCommentById:(NSString *)ids
               ownerID:(NSString *)ownerIDs
                 count:(NSInteger)count
                offset:(NSInteger)offset
             onSuccess:(void (^) (NSArray *wallComment))success
             onFailure:(void (^) (NSError *error)) failure;

- (void)postWallAddCommentText:(NSString*)text
                         image:(NSArray *)image
                   onGroupWall:(NSString*)groupID
                  onGroupTopic:(NSString*)topicID
                     onSuccess:(void(^)(id result))success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode))failure;

- (void)postTopicAddCommentText:(NSString*)text
                          image:(NSArray *)image
                    onGroupWall:(NSString*)groupID
                   onGroupTopic:(NSString*)topicID
                      onSuccess:(void(^)(id result))success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode))failure;

- (void)getAlbumsGrouppById:(NSString *)ids
                      count:(NSInteger)count
                     offset:(NSInteger)offset
                  onSuccess:(void (^) (NSArray *arrayWithAlbums))success
                  onFailure:(void (^) (NSError *error)) failure;

- (void)getPhotosFromAlbumID:(NSString *)ids
                     ownerID:(NSString *)ownerIDs
                       count:(NSInteger)count offset:(NSInteger)offset
                   onSuccess:(void (^) (NSArray *arrayWithPhotos))success
                   onFailure:(void (^) (NSError *error)) failure;

- (void)postImageInAlbumsIds:(NSString *)ids
                       image:(UIImage *)image
                   onSuccess:(void (^)(id responseObject))success
                   onFailure:(void (^)(NSError *error))failure;


@end
