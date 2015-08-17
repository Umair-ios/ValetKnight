
#import "Constants.h"

NSString * const StripePublishableKey = @"pk_test_rlFsNbe90O9o7ge0dxfPkg9R"; // TODO: replace nil with your own value Publishable - pk_test_rlFsNbe90O9o7ge0dxfPkg9R

// These can be found at https://www.parse.com/apps/stripe-test/edit#app_keys
NSString * const ParseApplicationId = nil; // TODO: replace nil with your own value
NSString * const ParseClientKey = nil; // TODO: replace nil with your own value

#pragma mark -
#pragma mark - APPLICATION NAME

NSString *const APPLICATION_NAME=@"ValetKnight";

#pragma mark -
#pragma mark - Segue Identifier

NSString *const SEGUE_LOGIN=@"segueToLogin";
NSString *const SEGUE_SUCCESS_LOGIN=@"segueSuccessLogin";

NSString *const SEGUE_REGISTER=@"segueToRegister";
NSString *const SEGUE_MYTHINGS=@"segueToMyThings";
NSString *const SEGUE_PAYMENT=@"segueToPayment";
NSString *const SEGUE_PROFILE=@"segueToProfile";
NSString *const SEGUE_ABOUT=@"segueToAboutUs";
NSString *const SEGUE_PROMOTIONS=@"segueToPromotions";
NSString *const SEGUE_SHARE=@"segueToShare";
NSString *const SEGUE_SUPPORT=@"segueToSupport";
NSString *const SEGUE_ADD_PAYMENT=@"segueToAddPayment";
NSString *const SEGUE_TO_ACCEPT=@"segueToaccept";
NSString *const SEGUE_TO_DIRECT_LOGIN=@"segueToMapDirectLogin";
NSString *const SEGUE_TO_FEEDBACK=@"segueToFeedBack";
NSString *const SEGUE_TO_HISTORY=@"segueToHistory";
NSString *const SEGUE_TO_ADD_CARD=@"segueToAddCard";
NSString *const SEGUE_TO_REFERRAL_CODE=@"segueToReferralCode";
NSString *const SEGUE_TO_APPLY_REFERRAL_CODE=@"segueToApplyReferral";
NSString *const SEGUE_TO_ADDRESS_SEARCH=@"segueForAddressSearch";
NSString *const SEGUE_TO_SHOW_FARE_ESTIMATOR=@"showFareEstimator";
NSString *const SEGUE_TO_CONTACT_US=@"contactus";

#pragma mark -
#pragma mark - Title

NSString *const TITLE_LOGIN=@"SIGN IN";
NSString *const TITLE_REGISTER=@"REGISTER";
NSString *const TITLE_MYTHINGS=@"MY THINGS";
NSString *const TITLE_PAYMENT=@"ADD PAYMENT";
NSString *const TITLE_PICKUP=@"PICK UP";
NSString *const TITLE_PROFILE=@"PROFILE";
NSString *const TITLE_ABOUT=@"ABOUT";
NSString *const TITLE_PROMOTIONS=@"PROMOTIONS";
NSString *const TITLE_SHARE=@"SHARE";
NSString *const TITLE_SUPPORT=@"SUPPORT";

#pragma mark -
#pragma mark - Prefences key

NSString *const PREF_DEVICE_TOKEN=@"deviceToken";
NSString *const PREF_USER_TOKEN=@"usertoken";
NSString *const PREF_PAYMENT_METHOD=@"paymentMethod";
NSString *const PREF_USER_ID=@"userid";
NSString *const PREF_REQ_ID=@"requestid";
NSString *const PREF_IS_LOGIN=@"islogin";
NSString *const PREF_IS_LOGOUT=@"islogout";
NSString *const PREF_LOGIN_OBJECT=@"loginobject";
NSString *const PREF_IS_WALK_STARTED=@"iswalkstarted";
NSString *const PREF_REFERRAL_CODE=@"referral_code";
NSString *const PREF_IS_OPTIONS=@"isFromOptions";
NSString *const PREF_CREDITS=@"credits";
NSString *const PREF_ADDRESS_TYPE=@"addressType";
NSString *const PREF_FULL_ADDRESS=@"wholeAddress";
NSString *const PREF_DEST_ADD=@"destinationAdd";
NSString *const PREF_SOURCE_ADD=@"sourceAdd";

#pragma mark -
#pragma mark - WS METHODS

NSString *const FILE_REGISTER=@"register";
NSString *const FILE_LOGIN=@"login";
NSString *const FILE_THING=@"thing";
NSString *const FILE_ADD_CARD=@"addcardtoken";
NSString *const FILE_DELETE_CARD=@"deletecardtoken";
NSString *const FILE_CREATE_REQUEST=@"createrequest";
NSString *const FILE_GET_REQUEST=@"getrequest";
NSString *const FILE_GET_REQUEST_LOCATION=@"getrequestlocation";
NSString *const FILE_GET_REQUEST_PROGRESS=@"requestinprogress";
NSString *const FILE_RATE_DRIVER=@"rating";
NSString *const FILE_GET_PAYMENT_OPTIONS=@"payment_options";
NSString *const FILE_PAGE=@"application/pages";
NSString *const FILE_APPLICATION_TYPE=@"application/types";
NSString *const FILE_FORGET_PASSWORD=@"application/forgot-password";
NSString *const FILE_UPADTE=@"update";
NSString *const FILE_HISTORY=@"history";
NSString *const FILE_GET_CARDS=@"cards";
NSString *const FILE_REQUEST_PATH=@"requestpath";
NSString *const FILE_REFERRAL=@"referral";
NSString *const FILE_CANCEL_REQUEST=@"cancelrequest";
NSString *const FILE_APPLY_REFERRAL=@"apply-referral";
NSString *const FILE_PAY_BY_PAYPAL=@"paybypaypal";
NSString *const FILE_FARE_CALCULATOR=@"fare";
NSString *const FILE_GET_PROVIDERS_ALL=@"getprovidersall";
NSString *const FILE_CHECK_PROMO=@"check_promo_code";
NSString *const FILE_GET_NEARBY_PROVIDERS=@"getnearbyproviders";
NSString *const FILE_SHARE_ETA=@"send_eta";
NSString *const FILE_PAY_DEBT=@"paydebt";
NSString *const FILE_GET_CREDITS=@"credits";

#pragma mark -
#pragma mark - PARAMETER NAME

NSString *const PARAM_EMAIL=@"email";
NSString *const PARAM_PASSWORD=@"password";
NSString *const PARAM_FIRST_NAME=@"first_name";
NSString *const PARAM_LAST_NAME=@"last_name";
NSString *const PARAM_PHONE=@"phone";
NSString *const PARAM_PICTURE=@"picture";
NSString *const PARAM_DEVICE_TOKEN=@"device_token";
NSString *const PARAM_DEVICE_TYPE=@"device_type";
NSString *const PARAM_BIO=@"bio";
NSString *const PARAM_ADDRESS=@"address";
NSString *const PARAM_KEY=@"key";
NSString *const PARAM_STATE=@"state";
NSString *const PARAM_COUNTRY=@"country";
NSString *const PARAM_ZIPCODE=@"zipcode";
NSString *const PARAM_LOGIN_BY=@"login_by";
NSString *const PARAM_SOCIAL_UNIQUE_ID=@"social_unique_id";
NSString *const PARAM_TIME_ZONE=@"timezone";

NSString *const PARAM_NAME=@"name";
NSString *const PARAM_AGE=@"age";
NSString *const PARAM_NOTES=@"notes";
NSString *const PARAM_TYPE=@"type";
NSString *const PARAM_PAYMENT_TYPE=@"payment_mode";
NSString *const PARAM_ID=@"id";
NSString *const PARAM_TOKEN=@"token";
NSString *const PARAM_STRIPE_TOKEN=@"payment_token";
NSString *const PARAM_LAST_FOUR=@"last_four";
NSString *const PARAM_PROMO=@"promo_code";
NSString *const PARAM_CARD_ID=@"card_id";

NSString *const PARAM_LATITUDE=@"latitude";
NSString *const PARAM_LONGITUDE=@"longitude";
NSString *const PARAM_DEST_LATITUDE=@"d_latitude";
NSString *const PARAM_DEST_LONGITUDE=@"d_longitude";
NSString *const PARAM_DISTANCE=@"distance";
NSString *const PARAM_TIME=@"time";
NSString *const PARAM_REQUEST_ID=@"request_id";

NSString *const PARAM_COMMENT=@"comment";
NSString *const PARAM_RATING=@"rating";
//NSString *const PARAM_REFERRAL_CODE=@"code";
NSString *const PARAM_ADD_PROMO_REF = @"referral_code";
NSString *const PARAM_ETA=@"eta";

NSDictionary *dictBillInfo;
int is_completed;
int is_dog_rated;
int is_walker_started;
int is_walker_arrived;
int is_started;
NSArray *arrPage;


NSString *strForCurLatitude;
NSString *strForCurLongitude;




