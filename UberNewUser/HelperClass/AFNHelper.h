//
//  AFNHelper.h
//  Tinder
//
//  Created by Elluminati - macbook on 04/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define POST_METHOD @"POST"
#define GET_METHOD  @"GET"

typedef void (^RequestCompletionBlock)(id response, NSError *error);

@interface AFNHelper : NSObject
{
    //blocks
    RequestCompletionBlock dataBlock;
}
@property(nonatomic,copy)NSString *strReqMethod;

-(id)initWithRequestMethod:(NSString *)method;
-(void)getDataFromPath:(NSString *)path withParamData:(NSMutableDictionary *)dictParam withBlock:(RequestCompletionBlock)block;
-(void)getDataFromPath:(NSString *)path withParamDataImage:(NSMutableDictionary *)dictParam andImage:(UIImage *)image withBlock:(RequestCompletionBlock)block;
-(void)getAddressFromGooglewithParamData:(NSMutableDictionary *)dictParam withBlock:(RequestCompletionBlock)block;

@end
