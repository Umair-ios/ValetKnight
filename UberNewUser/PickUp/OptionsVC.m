//
//  OptionsVC.m
//  TaxiNow
//
//  Created by Dev on 27/03/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "OptionsVC.h"
#import "SearchViewController.h"

@interface OptionsVC ()
{
    NSString *strForSourceLat, *strForSourceLong, *strForDestLat, *strForDestLong, *strForUserToken, *strForUserId, *strForEstDist, *strForEstTime, *strForETAtime;
}

@property (weak, nonatomic) IBOutlet UITextField *destLocationTxt;
@property (weak, nonatomic) IBOutlet UILabel *estimatedFareLbl;
@property (weak, nonatomic) IBOutlet UILabel *carTypeLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loader;

@end

@implementation OptionsVC
@synthesize strForSourceAdd,strForCarType,strForDestAdd;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"FARE ESTIMATE";
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIFont fontWithName:@"Open Sans" size:18],
                                                                     NSFontAttributeName, nil]];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_FULL_ADDRESS];
    
    [self.estimatedFareLbl setHidden:YES];
    [self.carTypeLbl setText:strForCarType];
    
    if (![strForSourceAdd isEqualToString:@""]) {
        [self.sourceLocationTxt setText:strForSourceAdd];
        [self getLocationFromString:strForSourceAdd forTextField:self.sourceLocationTxt];
        strForDestLat = @"";
    }

    if (![strForDestAdd isEqualToString:@""]) {
        [self.loader startAnimating];
        [self.estimatedFareLbl setHidden:YES];

        [self.destLocationTxt setText:strForDestAdd];
        [self getLocationFromString:strForDestAdd forTextField:self.destLocationTxt];
    }
    else {
        [self.destLocationTxt becomeFirstResponder];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictAdd = [[NSMutableDictionary alloc]init];
    dictAdd = [pref objectForKey:PREF_FULL_ADDRESS];
    
    if ([[dictAdd valueForKey:PREF_ADDRESS_TYPE] isEqualToString:PREF_DEST_ADD]) {
        [self.loader startAnimating];
        [self.estimatedFareLbl setHidden:YES];

        [self.destLocationTxt setText:[dictAdd valueForKey:@"address"]];
        [self getLocationFromString:self.destLocationTxt.text forTextField:self.destLocationTxt];
    }
    else if ([[dictAdd valueForKey:PREF_ADDRESS_TYPE] isEqualToString:PREF_SOURCE_ADD]){
        [self.sourceLocationTxt setText:[dictAdd valueForKey:@"address"]];
        [self getLocationFromString:self.sourceLocationTxt.text forTextField:self.sourceLocationTxt];
    }
    
//    if (![self.sourceLocationTxt.text isEqualToString:@""] && ![self.destLocationTxt.text isEqualToString:@""]) {
//        [self getLocationFromString:strForSourceAdd forTextField:self.sourceLocationTxt];
//        [self getLocationFromString:strForDestAdd forTextField:self.destLocationTxt];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:@"segueForSearchAdd"]) {
        SearchViewController *searchObj = [segue destinationViewController];
        NSString *txtFieldName;
        UITextField *txtField = sender;
        if ([txtField isEqual:self.sourceLocationTxt]) {
            txtFieldName = PREF_SOURCE_ADD;
        }
        else if ([txtField isEqual:self.destLocationTxt]) {
            txtFieldName = PREF_DEST_ADD;
        }
        
        searchObj.fromTextField = txtFieldName;
    }
}


- (IBAction)closeView:(id)sender {
    //    [self dismissViewControllerAnimated:YES completion:nil];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:@"1" forKey:PREF_IS_OPTIONS];
    [pref setObject:self.destLocationTxt.text forKey:@"destLocationText"];
    [pref removeObjectForKey:PREF_FULL_ADDRESS];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text=@"";
    [self performSegueWithIdentifier:@"segueForSearchAdd" sender:textField];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //    if (![textField.text isEqualToString:@""]) {
    //        [self getLocationFromString:textField.text forTextField:textField];
    //    }
    //    else {
    //        return;
    //    }
    
    if ([textField isEqual:self.destLocationTxt] && ![self.sourceLocationTxt.text isEqualToString:@""] && ![self.destLocationTxt.text isEqualToString:@""]) {
        [self.loader startAnimating];
        //        [self getDistanceAndTimeFromLat:strForSourceLat andLong:strForSourceLong toLat:strForDestLat andLong:strForDestLong];
        //        [self estimatefare];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        [self getLocationFromString:textField.text forTextField:textField];
    }
    
    if ([textField isEqual:self.sourceLocationTxt] && [self.destLocationTxt.text isEqualToString:@""]) {
        [self.destLocationTxt becomeFirstResponder];
    }
    else if ([textField isEqual:self.destLocationTxt]) {
        [textField resignFirstResponder];
    }
    else if (![self.sourceLocationTxt.text isEqualToString:@""] && ![self.destLocationTxt.text isEqualToString:@""]) {
        [textField resignFirstResponder];
        [self.loader startAnimating];
        //        [self getDistanceAndTimeFromLat:strForSourceLat andLong:strForSourceLong toLat:strForDestLat andLong:strForDestLong];
    }
    
    return YES;
}

-(void)getLocationFromString:(NSString *)str forTextField:(UITextField *)textField
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if(response)
             {
                 NSArray *arrAddress=[response valueForKey:@"results"];
                 if ([arrAddress count] > 0)
                 {
                     textField.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     if ([textField isEqual:self.sourceLocationTxt]) {
                         strForSourceLat = [dictLocation valueForKey:@"lat"];
                         strForSourceLong = [dictLocation valueForKey:@"lng"];
                     }
                     else if ([textField isEqual:self.destLocationTxt]) {
                         strForDestLat = [dictLocation valueForKey:@"lat"];
                         strForDestLong = [dictLocation valueForKey:@"lng"];
                     }
                     
                     if (![self.sourceLocationTxt.text isEqualToString:@""] && ![self.destLocationTxt.text isEqualToString:@""]) {
                         if ([textField isEqual:self.destLocationTxt]) {
                             [self getDistanceAndTimeFromLat:strForSourceLat andLong:strForSourceLong toLat:strForDestLat andLong:strForDestLong];
                         }
                     }
                 }
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

-(void)getDistanceAndTimeFromLat:(NSString *)soucelat andLong:(NSString *)sourceLong toLat:(NSString *)destLat andLong:(NSString *)destLong {
    NSString *distUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f",[soucelat floatValue],[sourceLong floatValue],[destLat floatValue],[destLong floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:distUrl] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    NSArray *getDetails = [JSON objectForKey:@"rows"];
    NSArray *getRows = [[getDetails objectAtIndex:0] valueForKey:@"elements"];
    strForEstTime = [[[getRows objectAtIndex:0] valueForKey:@"duration"] objectForKey:@"value"];
    strForEstDist = [[[getRows objectAtIndex:0] valueForKey:@"distance"] objectForKey:@"value"];
    strForETAtime = [[[getRows objectAtIndex:0] valueForKey:@"duration"] objectForKey:@"text"];

    [self estimatefare];
}

-(void)estimatefare {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    strForUserToken = [pref objectForKey:PREF_USER_TOKEN];
    strForUserId = [pref objectForKey:PREF_USER_ID];
    
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForEstDist forKey:PARAM_DISTANCE];
    [dictParam setValue:strForEstTime forKey:PARAM_TIME];
    
    if ([[AppDelegate sharedAppDelegate]connected]) {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_FARE_CALCULATOR withParamData:dictParam withBlock:^(id response, NSError *error) {
            if ([[response valueForKey:@"success"] boolValue] == TRUE) {
                ////NSLog(@"FARE CALCULATOR -> %@",response);
                NSString *fareStr = [NSString stringWithFormat:@"%@ %.2f",[response valueForKey:@"currency"],[[response objectForKey:@"estimated_fare"] floatValue]];
                [self.loader stopAnimating];
                self.estimatedFareLbl.text = fareStr;
                [self.estimatedFareLbl setHidden:NO];
            }
            else {
                [APPDELEGATE showToastMessage:@"OOPS!! Something went wrong. Try Again"];
                [self performSelector:@selector(closeView:) withObject:self];
            }
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

@end
