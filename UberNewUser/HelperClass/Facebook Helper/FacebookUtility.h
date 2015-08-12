//
//  FacebookUtility.h
//  NewFBapiDemo
//
//  Created by Jignesh on 15/05/13.
//  Copyright (c) 2013 Jignesh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>


#define FBID @"952611324805792"

extern NSString *const UD_FBACCESSTOKENDATA;//FBAccessTokenDataDictionary

typedef void (^LoginCompletionBlock)(BOOL success, NSError *error);
typedef void (^FBCompletionBlock)(id response, NSError *error);
typedef void (^FBFriendCompletionBlock)(NSArray *friends, NSError *error);

@protocol FacebookUtilityDelegate <NSObject>
@optional


@end

@interface FacebookUtility : NSObject
{
    
}
@property (nonatomic, assign) id<FacebookUtilityDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *dictUserInfo;
@property (strong, nonatomic) NSMutableArray *arrFBFriendList;
@property (strong, nonatomic) FBSession *session;
//init and shared object
-(id) init;
+ (FacebookUtility *)sharedObject;
//for login chek
-(BOOL)isLogin;
//get fb token
-(void)getFBToken;
//login in FB
-(void)loginInFacebook:(LoginCompletionBlock)isLogin;
//logout from facebook
-(void)logOutFromFacebook;
//Fetch User Info
-(void)fetchMeWithFBCompletionBlock:(FBCompletionBlock)fbCompletion;
//Fetch Friends Info
- (void)fetchFriendsWithFBFriendCompletionBlock:(FBFriendCompletionBlock)fbFriends;
//Post on My wall
-(void)postOnMyFacebookWall:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion;
//Post On Friends Wall with FeedDialog
-(void)postOnFriendFacebookWallWithDialog:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion;

//-(void)postOnFacebookFriendsWall;

-(void)getCommentsOfPost:(NSString *)postID WithCompletionBlock:(FBFriendCompletionBlock)fbFriends;
-(void)getFriendProfilePicID:(NSString *)friendID WithCompltionBlock:(FBCompletionBlock)fbCompletion;

-(void)sendCommentsOfPost:(NSString *)postID andMsg:(NSString *)strMsg WithCompletionBlock:(FBCompletionBlock)fbCompletion;

//Search Post
-(void)searchPost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult;
-(void)searchHomePost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult;

@end
