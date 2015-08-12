//
//  FacebookUtility.m
//  NewFBapiDemo
//
//  Created by Jignesh on 15/05/13.
//  Copyright (c) 2013 Jignesh. All rights reserved.
//

#import "FacebookUtility.h"

NSString *const UD_FBACCESSTOKENDATA=@"FBAccessTokenDataDictionary";

@implementation FacebookUtility

@synthesize delegate;
@synthesize session = _session;
@synthesize dictUserInfo=_dictUserInfo,arrFBFriendList=_arrFBFriendList;


#pragma mark -
#pragma mark - Init And Shared Object

-(id) init
{
    if((self = [super init]))
    {
        
    }
    return self;
}

+ (FacebookUtility *)sharedObject
{
    static FacebookUtility *objFBUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objFBUtility = [[FacebookUtility alloc] init];
    });
    return objFBUtility;
}

#pragma mark -
#pragma mark - Login and Permitions methods

-(NSArray *)getPermissionsArray
{
    static NSArray *permissions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //permissions = [[NSArray alloc] initWithObjects:@"user_birthday",@"email", @"publish_stream", @"offline_access",@"publish_actions",  @"user_location",  @"user_hometown",  @"user_about_me", @"user_relationships",@"user_address",@"user_relationships",@"read_stream",@"read_friendlists", nil];
        permissions = [[NSArray alloc] initWithObjects:@"email", nil];
    });
    return permissions;
}

-(BOOL)isLogin
{
    BOOL isLogin=FALSE;
    if (self.session.isOpen) {
        isLogin=TRUE;
    }
    return isLogin;
}

-(void)getFBToken
{
    if (!self.session.isOpen) {
        // create a fresh session object
        self.session = [[FBSession alloc] initWithPermissions:[self getPermissionsArray]];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                // we recurse here, in order to update buttons and labels
                [FBSession setActiveSession:self.session];
            }];
        }
    }
    else{
        if (self.session.state==FBSessionStateOpen) {
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                // we recurse here, in order to update buttons and labels
                [FBSession setActiveSession:self.session];
            }];
        }
    }
}

-(void)loginInFacebook:(LoginCompletionBlock)isLogin
{
    if (self.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        //[self.session closeAndClearTokenInformation];
        
        isLogin(TRUE,nil);
    }
    else {
        
        FBAccessTokenData *accessData=[FBAccessTokenData createTokenFromDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:UD_FBACCESSTOKENDATA]];
        
        if (accessData==nil) {
            if (self.session.state != FBSessionStateCreated || self.session==nil) {
                // Create a new, logged out session.
                self.session = [[FBSession alloc] initWithPermissions:[self getPermissionsArray]];
            }
            // if the session isn't open, let's open it now and present the login UX to the user
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                // and here we make sure to update our UX according to the new session state
                [FBSession setActiveSession:self.session];
                //[self LoginSuccess];
                
                NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[self.session.accessTokenData dictionary] forKey:UD_FBACCESSTOKENDATA];
                [userDefaults synchronize];
                
                
                if (!error) {
                    isLogin(TRUE,nil);
                }
                else{
                    isLogin(FALSE,error);
                }
            }];
        }
        else{
            [self.session openFromAccessTokenData:accessData completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                self.session=session;
                [FBSession setActiveSession:self.session];
                if (self.session.isOpen) {
                    isLogin(TRUE,nil);
                }
                else{
                    if (self.session.state != FBSessionStateCreated) {
                        // Create a new, logged out session.
                        self.session = [[FBSession alloc] initWithPermissions:[self getPermissionsArray]];
                    }
                    // if the session isn't open, let's open it now and present the login UX to the user
                    [self.session openWithCompletionHandler:^(FBSession *session,
                                                              FBSessionState status,
                                                              NSError *error) {
                        // and here we make sure to update our UX according to the new session state
                        [FBSession setActiveSession:self.session];
                        //[self LoginSuccess];
                        
                        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:[self.session.accessTokenData dictionary] forKey:@"FBAccessTokenDataDictionary"];
                        [userDefaults synchronize];
                        
                        
                        if (!error) {
                            isLogin(TRUE,nil);
                        }
                        else{
                            isLogin(FALSE,error);
                        }
                    }];
                }
            }];
        }
    }
}

-(void)logOutFromFacebook
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    
    [self.session closeAndClearTokenInformation];
    [self.session close];
    self.session=nil;
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:UD_FBACCESSTOKENDATA];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString *domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

#pragma mark -
#pragma mark - Fetch User Info

-(void)fetchMeWithFBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    if (self.session.isOpen)
    {
        FBRequest *meRequest=[[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me"]];
        [meRequest startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary* result,
           NSError *error)
         {
             fbCompletion(result,error);
         }];
    }
    else{
        fbCompletion(nil,[NSError errorWithDomain:@"FacebookSession" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Session Expired",@"Info", nil]]);
    }
}

#pragma mark -
#pragma mark - Fetch Friends Info

- (void)fetchFriendsWithFBFriendCompletionBlock:(FBFriendCompletionBlock)fbFriends
{
    //[facebook requestWithGraphPath:@"me/friends?fields=name,picture" andDelegate:self];
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me/friends?fields=name,picture"]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray* friends = [result objectForKey:@"data"];
             fbFriends(friends,error);
         }
         else{
             fbFriends(nil,error);
         }
     }];
}

#pragma mark -
#pragma mark - Post on My wall

-(void)postOnMyFacebookWall:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    FBRequest *post=[[FBRequest alloc]initWithSession:self.session graphPath:@"me/feed" parameters:dictPost HTTPMethod:@"POST"];
    [post startWithCompletionHandler: ^(FBRequestConnection *connection,
                                        NSDictionary* result,
                                        NSError *error)
     {
         fbCompletion(result,error);
     }];
}

#pragma mark -
#pragma mark - Post On Friends Wall with FeedDialog

-(void)postOnFriendFacebookWallWithDialog:(NSMutableDictionary *)dictPost WithFBCompletionBlock:(FBCompletionBlock)fbCompletion
{
    [dictPost setObject:FBID forKey:@"app_id"];
    [dictPost setObject:@"feed" forKey:@"method"];
    
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:self.session//[FBSession activeSession]
                                           parameters:dictPost
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Case A: Error launching the dialog or publishing story.
             ////NSLog(@"Error publishing story.");
             fbCompletion(nil,error);
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // Case B: User clicked the "x" icon
                 // ////NSLog(@"User canceled story publishing.");
                 fbCompletion(nil,[NSError errorWithDomain:@"StoryPublishing" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"User canceled story publishing.",@"Info", nil]]);
             }
             else {
                 // Case C: Dialog shown and the user clicks Cancel or Share
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     ////NSLog(@"User canceled story publishing.");
                     fbCompletion(nil,[NSError errorWithDomain:@"StoryPublishing" code:6969 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"User canceled story publishing.",@"Info", nil]]);
                 }
                 else {
                     // User clicked the Share button
                     NSString *postID = [urlParams valueForKey:@"post_id"];
                     // ////NSLog(@"Posted story, id: %@", postID);
                     fbCompletion(postID,error);
                 }
                 
             }
         }
     }];
}

- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

-(void)getCommentsOfPost:(NSString *)postID WithCompletionBlock:(FBFriendCompletionBlock)fbFriends
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/comments/?fields=from,message",postID]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             NSArray* friends = [result objectForKey:@"data"];
             fbFriends(friends,error);
         }
         else{
             fbFriends(nil,error);
         }
     }];
    
}


-(void)sendCommentsOfPost:(NSString *)postID andMsg:(NSString *)strMsg WithCompletionBlock:(FBCompletionBlock)fbCompletion
{
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"%@/comments?message=%@",postID,strMsg]];
    friendsRequest.HTTPMethod=@"POST";
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbCompletion(result,nil);
         }
         else{
             fbCompletion(nil,error);
         }
     }];
    
}


-(void)searchPost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult
{
    searchString=[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"search?type=post&q=%@",searchString]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbResult(result,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
    
}

-(void)searchHomePost:(NSString *)searchString WithCompletionBlock:(FBCompletionBlock)fbResult
{
    searchString=[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //@"me/home?type=post&q=%@"
    FBRequest* friendsRequest = [[FBRequest alloc]initWithSession:self.session graphPath:[NSString stringWithFormat:@"me/home?q=%@",searchString]];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error)
     {
         if (!error) {
             fbResult(result,error);
         }
         else{
             fbResult(nil,error);
         }
     }];
    
}

#pragma mark -
#pragma mark - FQL

-(void)getFriendProfilePicID:(NSString *)friendID WithCompltionBlock:(FBCompletionBlock)fbCompletion
{
    
    
    NSString *query =[NSString stringWithFormat:@"SELECT id,url from profile_pic where id=%@",friendID];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    query, @"query",
                                    nil];
    
    FBRequest *post=[[FBRequest alloc] initWithSession:self.session graphPath:@"fql.query" parameters:params HTTPMethod:@"GET"];
    [post startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (result) {
             /*
              {
              id = 100000522165744;
              url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash3/c7.15.63.63/s50x50/14768_579358758758191_757563939_t.jpg";
              }
              */
             fbCompletion([result objectAtIndex:0],nil);
         }
         else{
             fbCompletion(nil,error);
         }
     }];
    
}
/*
 #pragma mark -
 #pragma mark - Post on Friends wall
 
 -(void)postOnFacebookFriendsWall
 {
 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
 @"380615018626574", @"app_id",
 @"feed", @"method",
 @"100001404765028", @"to",
 @"Jigs Test",  @"message",
 @"Jigs Connect with me on SnipStamp to find out what you really want to know: What's Happening Tonight?", @"description",
 @"http://www.snipstamp.com", @"link",
 @"http://www.snipstamp.com", @"picture",
 nil];
 
 FBRequest *post=[[FBRequest alloc]initWithSession:self.session graphPath:@"100001404765028/feed/" parameters:params HTTPMethod:@"POST"];
 
 [post startWithCompletionHandler: ^(FBRequestConnection *connection,
 NSDictionary* result,
 NSError *error)
 {
 ////NSLog(@"result for Post = %@", result);
 }];
 
 }
 */



/*
 FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
 
 [requestConnection addRequest:post
 completionHandler:^(FBRequestConnection *connection,
 id result,
 NSError *error) {
 ////NSLog(@"result for Post = %@", result);
 }];
 [requestConnection start];
 */

/*
 - (void)LoginSuccess
 {
 // get the app delegate, so that we can reference the session property
 if (self.session.isOpen)
 {
 // valid account UI is shown whenever the session is open
 
 [self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
 [self.textNoteOrLink setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
 appDelegate.session.accessTokenData.accessToken]];
 
 ////NSLog(@"Login Success");
 //[self fetchMe];
 //[self fetchFriends];
 //[self postOnFacebookWall];
 //[self postOnFacebookFriendsWall];
 } else
 {
 ////NSLog(@"Login Fail");
 // login-needed account UI is shown whenever the session is closed
 
 }
 }
 */

// Put together the dialog parameters
/*
 NSMutableDictionary *params =
 [NSMutableDictionary dictionaryWithObjectsAndKeys:
 @"380615018626574", @"app_id",
 @"feed", @"method",
 @"100001404765028", @"to",
 @"try", @"caption",
 @"https://develo‌​pers.facebook.com/docs/reference/dialogs/", @"link",
 @"try link", @"name",
 @"http://fbrell.com/f8.jpg", @"picture",
 @"Using%20Dialogs%2‌​0to%20interact%20with%20users.", @"description",
 nil];
 */
/*
 NSMutableDictionary *params =
 [NSMutableDictionary dictionaryWithObjectsAndKeys:
 @"380615018626574", @"app_id",
 @"feed", @"method",
 @"100001404765028", @"to",
 @"try", @"caption",
 @"https://develo‌​pers.facebook.com/docs/reference/dialogs/", @"link",
 @"try link", @"name",
 @"http://fbrell.com/f8.jpg", @"picture",
 @"Using%20Dialogs%2‌​0to%20interact%20with%20users.", @"description",
 nil];
 */

/* dilog feed dict
 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
 @"380615018626574", @"app_id",
 @"feed", @"method",
 @"100001404765028", @"to",
 @"",  @"message",
 @"Connect with me on SnipStamp to find out what you really want to know: What's Happening Tonight?", @"description",
 @"http://www.snipstamp.com", @"link",
 @"http://www.snipstamp.com", @"picture",
 nil];
 */


@end
