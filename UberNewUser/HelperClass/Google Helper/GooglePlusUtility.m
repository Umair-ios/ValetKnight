//
//  GooglePlusUtility.m
//  JTravel
//
//  Created by Elluminati - macbook on 07/07/14.
//  Copyright (c) 2014 innoways. All rights reserved.
//

#import "GooglePlusUtility.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation GooglePlusUtility
{
    GPPSignIn *signIn;
}

#pragma mark -
#pragma mark - Init And Shared Object

-(id) init
{
    if((self = [super init]))
    {
         signIn= [GPPSignIn sharedInstance];
        [signIn signOut];
        
        signIn.shouldFetchGooglePlusUser = YES;
        //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
        signIn.shouldFetchGoogleUserEmail = YES;
        signIn.shouldFetchGoogleUserID = YES;
        // You previously set kClientId in the "Initialize the Google+ client" step
        signIn.clientID = kClientId;
        
        // Uncomment one of these two statements for the scope you chose in the previous step
        signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
        //signIn.scopes = @[ @"profile" ];            // "profile" scope
        
        // Optional: declare signIn.actions, see "app activities"
        signIn.delegate = self;
        //[signIn trySilentAuthentication];
        
        
    }
    return self;
}

+ (GooglePlusUtility *)sharedObject
{
    static GooglePlusUtility *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[GooglePlusUtility alloc] init];
    });
    return obj;
}

-(BOOL)isLogin
{
    BOOL isLogin=FALSE;
    if ([GPPSignIn sharedInstance].authentication) {
        isLogin=TRUE;
    }
    return isLogin;
}

-(void)loginWithBlock:(LoginGoogleCompletionBlock)block
{
    if (block) {
        complateLogin=[block copy];
    }
    [[GPPSignIn sharedInstance]authenticate];
}

-(void)shareImage:(UIImage *)img
{
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    //id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
    
    // Set any prefilled text that you might want to suggest
    [shareBuilder setPrefillText:@"#Paramos"];
    [shareBuilder attachImage:img];

    [shareBuilder open];
}

#pragma mark -
#pragma mark - GPPSignInDelegate

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{/*
    ////NSLog(@"Received error %@ and auth object %@",error, auth);
    if (complateLogin) {
        if (error==nil) {
            complateLogin(auth,error);
        }else{
            complateLogin(auth,error);
        }
    }*/
    
    if (error) {
        // Do some error handling here.
    } else {
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:auth];
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                    } else {
                        // Retrieve the display name and "about me" text
                        
                        NSMutableString *imageURLString =[NSMutableString stringWithString:person.image.url] ;
                        [imageURLString replaceCharactersInRange: [imageURLString rangeOfString: @"sz=50"] withString: @"sz=200"];
                        
                       NSString *strName=[NSString stringWithFormat:@"%@",person.displayName];
                        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                        [dict setObject:signIn.userEmail forKey:@"email"];
                        [dict setObject:signIn.userID forKey:@"userid"];
                        [dict setObject:strName forKey:@"name"];
                        [dict setObject:imageURLString forKey:@"profile_image"];
                        [dict setObject:person.gender forKey:@"gender"];
                        [dict setObject:person.name.familyName forKey:@"surname"];
                        [dict setObject:person.name.givenName forKey:@"username"];

                        
                        if (complateLogin) {
                            if (error==nil) {
                                complateLogin(dict,error);
                            }else{
                                complateLogin(dict,error);
                            }
                        }
                    }
                }];
    }
    
   
    
    //[self shareImage:[UIImage imageNamed:@"map"]];
    /*
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    plusService.apiVersion = @"v1";
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
            
                [self.vcBase dismissViewControllerAnimated:NO completion:^{
                    [self shareImage:[UIImage imageNamed:@"map"]];
                }];
            }];
    
    */
    /*
    
    [self.vcBase dismissViewControllerAnimated:NO completion:^{
        [self shareImage:[UIImage imageNamed:@"map"]];
    }];
     */
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    if (self.vcBase) {
        [[self.vcBase navigationController] pushViewController:viewController animated:YES];
    }
}

@end
