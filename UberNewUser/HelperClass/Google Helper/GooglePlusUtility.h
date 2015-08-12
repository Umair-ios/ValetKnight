//
//  GooglePlusUtility.h
//  JTravel
//
//  Created by Elluminati - macbook on 07/07/14.
//  Copyright (c) 2014 innoways. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>

#define kClientId @"64484691710-3uq1ca0756acpo4r77of9496gunmtjaf.apps.googleusercontent.com"


typedef void (^LoginGoogleCompletionBlock)(id response, NSError *error);

@interface GooglePlusUtility : NSObject<GPPSignInDelegate>
{
    LoginGoogleCompletionBlock complateLogin;
}
@property(nonatomic,strong)UIViewController *vcBase;

+ (GooglePlusUtility *)sharedObject;
-(BOOL)isLogin;
-(void)loginWithBlock:(LoginGoogleCompletionBlock)block;
-(void)shareImage:(UIImage *)img;

@end
