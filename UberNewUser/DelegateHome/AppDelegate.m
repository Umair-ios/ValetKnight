//
//  AppDelegate.m
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FacebookUtility.h"
#import <GooglePlus/GooglePlus.h>
#import "Stripe.h"
#import "Constants.h"
#import "ProviderDetailsVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SplunkMint/SplunkMint.h>

@implementation AppDelegate
@synthesize vcProvider, vcPickup;


#pragma mark -
#pragma mark - UIApplication Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [GMSServices provideAPIKey:Google_Map_Key];
    // Override point for customization after application launch.

    if (StripePublishableKey) {
        [Stripe setDefaultPublishableKey:StripePublishableKey];
    }
    // Right, that is the point
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        //register to receive notifications
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotif)
    {
        //Handle remote notification
        [self handleRemoteNotification:application userInfo:launchOptions];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];

    [[Mint sharedInstance] initAndStartSession:@"54dfe338"];
    //return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

#pragma mark -
#pragma mark - Push Notification Methods

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* strdeviceToken = [[NSString alloc]init];
    strdeviceToken=[self stringWithDeviceToken:deviceToken];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:strdeviceToken forKey:PREF_DEVICE_TOKEN];
    
    [prefs synchronize];
    //UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Token " message:strdeviceToken delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    //[alert show];
    ////NSLog(@"My token is: %@",strdeviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    ////NSLog(@"Failed to get token, error: %@", error);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"121212121212121212" forKey:PREF_DEVICE_TOKEN];
    [prefs synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary *aps=[userInfo valueForKey:@"aps"];
    NSMutableDictionary *msg=[aps valueForKey:@"message"];
    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",[aps valueForKey:@"alert"]] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"cancel", nil];
//    
//    [alert show];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRideCompleted"]) {
        return;
    }

    if ([msg count] > 0) {
        dictBillInfo=[msg valueForKey:@"bill"];
        is_walker_started=[[msg valueForKey:@"is_walker_started"] intValue];
        is_walker_arrived=[[msg valueForKey:@"is_walker_arrived"] intValue];
        is_started=[[msg valueForKey:@"is_walk_started"] intValue];
        is_completed=[[msg valueForKey:@"is_completed"] intValue];
        is_dog_rated=[[msg valueForKey:@"is_walker_rated"] intValue];
        
        if ([dictBillInfo count] > 0)
        {
            if (vcProvider) {
                [vcProvider.timerForCheckReqStatuss invalidate];
                [vcProvider.timerForTimeAndDistance invalidate];
                vcProvider.timerForTimeAndDistance=nil;
                vcProvider.timerForCheckReqStatuss=nil;
                
//                if (![[NSUserDefaults standardUserDefaults]boolForKey:@"tripDone"]) {
//                    [vcProvider checkDriverStatus];
//                }
            }
        }
        else {
            [vcProvider checkDriverStatus];
        }
    }
    else {
        // Handle push when all the drivers have rejected / not responded
        // [APPDELEGATE showToastMessage:[aps valueForKey:@"alert"]];
    }
}

-(void)handleRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *aps=[userInfo valueForKey:@"aps"];
    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",[aps valueForKey:@"alert"]] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"cancel", nil];
//    
//    [alert show];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRideCompleted"]) {
        return;
    }
    
    if ([[[userInfo valueForKey:@"aps"] valueForKey:@"message"] isEqual:[NSDictionary class]]) {
        NSMutableDictionary *msg=[aps valueForKey:@"message"];
        
        if ([msg count] > 0) {
            dictBillInfo=[msg valueForKey:@"bill"];
            is_walker_started=[[msg valueForKey:@"is_walker_started"] intValue];
            is_walker_arrived=[[msg valueForKey:@"is_walker_arrived"] intValue];
            is_started=[[msg valueForKey:@"is_walk_started"] intValue];
            is_completed=[[msg valueForKey:@"is_completed"] intValue];
            is_dog_rated=[[msg valueForKey:@"is_walker_rated"] intValue];
            
            if (dictBillInfo!=nil)
            {
                if (vcProvider) {
                    [vcProvider.timerForCheckReqStatuss invalidate];
                    [vcProvider.timerForTimeAndDistance invalidate];
                    vcProvider.timerForTimeAndDistance=nil;
                    vcProvider.timerForCheckReqStatuss=nil;
                }
            }
        }
    }
    else {
        [APPDELEGATE showToastMessage:[aps valueForKey:@"alert"]];
    }
//    if (vcProvider)
//    {
//        [vcProvider checkDriverStatus];
//    }
}

- (NSString*)stringWithDeviceToken:(NSData*)deviceToken
{
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return [token copy] ;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{/*
  NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
  NSDictionary * dict = [defs dictionaryRepresentation];
  for (id key in dict) {
  [defs removeObjectForKey:key];
  }
  [defs synchronize];*/
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:PREF_FULL_ADDRESS];
}
- (void)userLoggedIn
{
    // Set the button title as "Log out"
    /*
     SignInVC *obj=[[SignInVC alloc]init];
     UIButton *loginButton = obj.btnFacebook;
     [loginButton setTitle:@"Log out" forState:UIControlStateNormal];
     */
    // Welcome message
    // [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    
}
#pragma mark -
#pragma mark - GPPDeepLinkDelegate

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink
{
    // An example to handle the deep link data.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deep-link Data"
                          message:[deepLink deepLinkID]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

/*
- (BOOL)application: (UIApplication *)application openURL: (NSURL *)url sourceApplication: (NSString *)sourceApplication annotation: (id)annotation
{
    return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
}
*/

#pragma mark -
#pragma mark - sharedAppDelegate

+(AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark - Loading View

-(void)showLoadingWithTitle:(NSString *)title
{
    if (viewLoading==nil) {
        viewLoading=[[UIView alloc]initWithFrame:self.window.bounds];
        viewLoading.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];//[UIColor whiteColor];
        //viewLoading.alpha=0.6f;
        
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-88)/2, ((viewLoading.frame.size.height-30)/2)-30, 88, 30)];
        img.backgroundColor=[UIColor clearColor];
        
        img.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"loading_1.png"],[UIImage imageNamed:@"loading_2.png"],[UIImage imageNamed:@"loading_3.png"], nil];
        img.animationDuration = 1.0f;
        img.animationRepeatCount = 0;
        [img startAnimating];
        [viewLoading addSubview:img];
        
        UITextView *txt=[[UITextView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-250)/2, ((viewLoading.frame.size.height-60)/2)+20, 250, 60)];
        txt.textAlignment=NSTextAlignmentCenter;
        txt.backgroundColor=[UIColor clearColor];
        txt.text=[title uppercaseString];
        txt.font=[UIFont systemFontOfSize:16];
        txt.userInteractionEnabled=FALSE;
        txt.scrollEnabled=FALSE;
        txt.textColor=[UberStyleGuide colorDefault];
        txt.font=[UberStyleGuide fontRegular];
        [viewLoading addSubview:txt];
    }
    
    [self.window addSubview:viewLoading];
    [self.window bringSubviewToFront:viewLoading];
}

-(void)showLoadingWithTitle:(NSString *)title andAlpha:(float)alpha
{
    if (viewLoading==nil) {
        viewLoading=[[UIView alloc]initWithFrame:self.window.bounds];
        viewLoading.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:alpha];//[UIColor whiteColor];
        //viewLoading.alpha=0.6f;
        
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-88)/2, ((viewLoading.frame.size.height-30)/2)-30, 88, 30)];
        img.backgroundColor=[UIColor clearColor];
        
        img.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"loading_1.png"],[UIImage imageNamed:@"loading_2.png"],[UIImage imageNamed:@"loading_3.png"], nil];
        img.animationDuration = 1.0f;
        img.animationRepeatCount = 0;
        [img startAnimating];
        [viewLoading addSubview:img];
        
        UITextView *txt=[[UITextView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-250)/2, ((viewLoading.frame.size.height-60)/2)+20, 250, 60)];
        txt.textAlignment=NSTextAlignmentCenter;
        txt.backgroundColor=[UIColor clearColor];
        txt.text=[title uppercaseString];
        txt.font=[UIFont systemFontOfSize:16];
        txt.userInteractionEnabled=FALSE;
        txt.scrollEnabled=FALSE;
        txt.textColor=[UberStyleGuide colorDefault];
        txt.font=[UberStyleGuide fontRegular];
        [viewLoading addSubview:txt];
    }
    
    [self.window addSubview:viewLoading];
    [self.window bringSubviewToFront:viewLoading];
}


-(void)hideLoadingView
{
    if (viewLoading) {
        [viewLoading removeFromSuperview];
        viewLoading=nil;
    }
}

-(void) showHUDLoadingView:(NSString *)strTitle
{
    if (HUD==nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.window];
        [self.window addSubview:HUD];
    }
    
    //HUD.delegate = self;
    //HUD.labelText = [strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    HUD.detailsLabelText=[strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    [HUD show:YES];
}

-(void) hideHUDLoadingView
{
    //[HUD removeFromSuperview];
    [HUD hide:YES];
}

-(void)showToastMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window
                                              animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.5f];
}
#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#pragma mark -
#pragma mark - Directory Path Methods

- (NSString *)applicationCacheDirectoryString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return cacheDirectory;
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark-
#pragma mark- Font Descriptor

-(id)setBoldFontDiscriptor:(id)objc
{
    if([objc isKindOfClass:[UIButton class]])
    {
        UIButton *button=objc;
        button.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return button;
    }
    else if([objc isKindOfClass:[UITextField class]])
    {
        UITextField *textField=objc;
        textField.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return textField;
        
        
    }
    else if([objc isKindOfClass:[UILabel class]])
    {
        UILabel *lable=objc;
        lable.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return lable;
    }
    return objc;
}


@end
