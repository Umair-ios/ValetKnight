//
//  MyThingsVC.h
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface MyThingsVC : BaseVC<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    
}

///////// Property

@property (nonatomic,strong) NSString *strForID;
@property (nonatomic,strong) NSString *strForToken;

//// Outlets

@property (weak, nonatomic) IBOutlet UIImageView *imgMyThing;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtType;

@property (weak, nonatomic) IBOutlet UITextField *txtAge;

@property (weak, nonatomic) IBOutlet UITextField *txtComment;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

///// Actions

- (IBAction)nextBtnPressed:(id)sender;
- (IBAction)imageBtnPressed:(id)sender;

@end
