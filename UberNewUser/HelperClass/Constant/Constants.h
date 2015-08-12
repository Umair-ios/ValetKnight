
#define GOOGLE_KEY @"AIzaSyByboue4BEXZk_q0UDH81abfs3UGpySHoA"

#define Google_Map_Key @"AIzaSyCsgFWaJXLqIVFXkj2vVwP8-oor3kc3C5I"
#define Address_URL @"https://maps.googleapis.com/maps/api/geocode/json?"

/*#define API_URL @"http://taxinow.xyz/user/"//Live
#define SERVICE_URL @"http://taxinow.xyz/"
#define PRIVACY_URL @"http://taxinow.xyz/termsncondition"*/

#define API_URL @"http:/52.26.255.47/user/"//Live
#define SERVICE_URL @"http://52.26.255.47/"
#define PRIVACY_URL @"http://52.26.255.47/termsncondition"

typedef enum
{
    MenuItemWrite = 0,
    MenuItemSearch = 1,
    MenuItemSetup = 2,
    MenuItemAddon = 3,
}SelectedMenuItem;

typedef enum
{
    SocialTypeFacebook = 0,
    SocialTypeTwitter = 1,
    SocialTypeLinkedIn = 2
}SocialType;

// MACROS
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//AppDelegate
#define APPDELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
//UserDefault
#define USERDEFAULT [NSUserDefaults standardUserDefaults]

//Colors
#define COLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define COLORPURPAL [UIColor colorWithRed:(153.0/255.0) green:(102.0/255) blue:(204.0/255) alpha:1.0]
#define COLORBLUE [UIColor colorWithRed:(0.0/255.0) green:(220.0/255) blue:(238.0/255) alpha:1.0]
#define COLORRED [UIColor colorWithRed:(255.0/255.0) green:(102.0/255) blue:(0.0/255) alpha:1.0]

#define COLORAPP [UIColor colorWithRed:(75.0/255.0) green:(193.0/255) blue:(210.0/255) alpha:1.0]

//iPhone5 helper
#define isiPhone5 ([UIScreen mainScreen].bounds.size.height == 568.0)
#define ASSET_BY_SCREEN_HEIGHT(regular) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : [regular stringByAppendingString:@"-568h"])

#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_IPHONE_5 ( IS_IPHONE && IS_HEIGHT_GTE_568 )

//iPhone Or iPad
#define isiPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define SET_XIB(regular) (isiPhone ? regular : [regular stringByAppendingString:@"_iPad"])

//iOS7 Or less
#define ISIOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

//Log helper
#ifdef DEBUG
#   define DLog(fmt, ...) ////NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#pragma mark -
#pragma mark - APPLICATION NAME

extern NSString *const APPLICATION_NAME;

extern NSString * const StripePublishableKey;
extern NSString * const ParseApplicationId;
extern NSString * const ParseClientKey;

#pragma mark -
#pragma mark - Segue Identifier

extern NSString *const SEGUE_LOGIN;
extern NSString *const SEGUE_REGISTER;
extern NSString *const SEGUE_MYTHINGS;
extern NSString *const SEGUE_PAYMENT;
extern NSString *const SEGUE_PROFILE;
extern NSString *const SEGUE_ABOUT;
extern NSString *const SEGUE_PROMOTIONS;
extern NSString *const SEGUE_SHARE;
extern NSString *const SEGUE_SUPPORT;
extern NSString *const SEGUE_SUCCESS_LOGIN;
extern NSString *const SEGUE_ADD_PAYMENT;
extern NSString *const SEGUE_TO_ACCEPT;
extern NSString *const SEGUE_TO_DIRECT_LOGIN;
extern NSString *const SEGUE_TO_FEEDBACK;
extern NSString *const SEGUE_TO_HISTORY;
extern NSString *const SEGUE_TO_ADD_CARD;
extern NSString *const SEGUE_TO_REFERRAL_CODE;
extern NSString *const SEGUE_TO_APPLY_REFERRAL_CODE;
extern NSString *const SEGUE_TO_ADDRESS_SEARCH;
extern NSString *const SEGUE_TO_SHOW_FARE_ESTIMATOR;
extern NSString *const SEGUE_TO_CONTACT_US;

#pragma mark -
#pragma mark - Title

extern NSString *const TITLE_LOGIN;
extern NSString *const TITLE_REGISTER;
extern NSString *const TITLE_MYTHINGS;
extern NSString *const TITLE_PAYMENT;
extern NSString *const TITLE_PICKUP;
extern NSString *const TITLE_PROFILE;
extern NSString *const TITLE_ABOUT;
extern NSString *const TITLE_PROMOTIONS;
extern NSString *const TITLE_SHARE;
extern NSString *const TITLE_SUPPORT;

#pragma mark -
#pragma mark - WS METHODS

extern NSString *const FILE_REGISTER;
extern NSString *const FILE_LOGIN;
extern NSString *const FILE_THING;
extern NSString *const FILE_ADD_CARD;
extern NSString *const FILE_DELETE_CARD;
extern NSString *const FILE_CREATE_REQUEST;
extern NSString *const FILE_GET_REQUEST;
extern NSString *const FILE_GET_REQUEST_LOCATION;
extern NSString *const FILE_GET_REQUEST_PROGRESS;
extern NSString *const FILE_RATE_DRIVER;
extern NSString *const FILE_GET_PAYMENT_OPTIONS;
extern NSString *const FILE_PAGE;
extern NSString *const FILE_APPLICATION_TYPE;
extern NSString *const FILE_FORGET_PASSWORD;
extern NSString *const FILE_UPADTE;
extern NSString *const FILE_HISTORY;
extern NSString *const FILE_GET_CARDS;
extern NSString *const FILE_REQUEST_PATH;
extern NSString *const FILE_REFERRAL;
extern NSString *const FILE_CANCEL_REQUEST;
extern NSString *const FILE_APPLY_REFERRAL;
extern NSString *const FILE_APPLY_REFERRAL;
extern NSString *const FILE_PAY_BY_PAYPAL;
extern NSString *const FILE_FARE_CALCULATOR;
extern NSString *const FILE_GET_PROVIDERS_ALL;
extern NSString *const FILE_CHECK_PROMO;
extern NSString *const FILE_GET_NEARBY_PROVIDERS;
extern NSString *const FILE_SHARE_ETA;
extern NSString *const FILE_PAY_DEBT;
extern NSString *const FILE_GET_CREDITS;

#pragma mark -
#pragma mark - Prefences key

extern NSString *const PREF_DEVICE_TOKEN;
extern NSString *const PREF_USER_TOKEN;
extern NSString *const PREF_PAYMENT_METHOD;
extern NSString *const PREF_USER_ID;
extern NSString *const PREF_REQ_ID;
extern NSString *const PREF_IS_LOGIN;
extern NSString *const PREF_IS_LOGOUT;
extern NSString *const PREF_LOGIN_OBJECT;
extern NSString *const PREF_IS_WALK_STARTED;
extern NSString *const PREF_REFERRAL_CODE;
extern NSString *const PREF_IS_OPTIONS;
extern NSString *const PREF_CREDITS;
extern NSString *const PREF_ADDRESS_TYPE;
extern NSString *const PREF_FULL_ADDRESS;
extern NSString *const PREF_DEST_ADD;
extern NSString *const PREF_SOURCE_ADD;

#pragma mark -
#pragma mark - PARAMETER NAME

extern NSString *const PARAM_EMAIL;
extern NSString *const PARAM_PASSWORD;
extern NSString *const PARAM_FIRST_NAME;
extern NSString *const PARAM_LAST_NAME;
extern NSString *const PARAM_PHONE;
extern NSString *const PARAM_PICTURE;
extern NSString *const PARAM_DEVICE_TOKEN;
extern NSString *const PARAM_DEVICE_TYPE;
extern NSString *const PARAM_BIO;
extern NSString *const PARAM_ADDRESS;
extern NSString *const PARAM_KEY;
extern NSString *const PARAM_STATE;
extern NSString *const PARAM_COUNTRY;
extern NSString *const PARAM_ZIPCODE;
extern NSString *const PARAM_LOGIN_BY;
extern NSString *const PARAM_SOCIAL_UNIQUE_ID;
extern NSString *const PARAM_TIME_ZONE;

extern NSString *const PARAM_NAME;
extern NSString *const PARAM_AGE;
extern NSString *const PARAM_NOTES;
extern NSString *const PARAM_TYPE;
extern NSString *const PARAM_PAYMENT_TYPE;
extern NSString *const PARAM_ID;
extern NSString *const PARAM_TOKEN;
extern NSString *const PARAM_STRIPE_TOKEN;
extern NSString *const PARAM_LAST_FOUR;
extern NSString *const PARAM_PROMO;
extern NSString *const PARAM_CARD_ID;

extern NSString *const PARAM_LATITUDE;
extern NSString *const PARAM_LONGITUDE;
extern NSString *const PARAM_DEST_LATITUDE;
extern NSString *const PARAM_DEST_LONGITUDE;
extern NSString *const PARAM_DISTANCE;
extern NSString *const PARAM_TIME;
extern NSString *const PARAM_REQUEST_ID;
extern NSString *const PARAM_COMMENT;
extern NSString *const PARAM_RATING;
//extern NSString *const PARAM_REFERRAL_CODE;
extern NSString *const PARAM_ETA;
extern NSString *const PARAM_ADD_PROMO_REF;

extern NSDictionary *dictBillInfo;
extern int is_completed;
extern int is_dog_rated;
extern int is_walker_started;
extern int is_walker_arrived;
extern int is_started;
extern NSArray *arrPage;

extern NSString *strForCurLatitude;
extern NSString *strForCurLongitude;

