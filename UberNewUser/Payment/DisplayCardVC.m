//
//  DisplayCardVC.m
//  UberforXOwner
//
//  Created by Deep Gami on 17/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "DisplayCardVC.h"
#import "DispalyCardCell.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "Helper.h"

@interface DisplayCardVC ()
{
    NSMutableArray *arrForCards;
}

@property (weak, nonatomic) IBOutlet UIButton *addCardBtn;

@end

@implementation DisplayCardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrForCards=[[NSMutableArray alloc]init];
    [super setBackBarItem];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.tableHeaderView=self.headerView;
    self.tableView.hidden=NO;
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.headerView.hidden=NO;
    self.lblNoCards.hidden=YES;
    self.imgNoItems.hidden=YES;
    [self getAllMyCards];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)addCardBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_TO_ADD_CARD sender:self];
}
#pragma mark -
#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrForCards.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reuseIdentifier = @"cardcell";
    MGSwipeTableCell * cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cardcell"];
    }
    
    if(arrForCards.count>0)
    {
        NSMutableDictionary *dict=[arrForCards objectAtIndex:indexPath.row];
        cell.textLabel.text=[NSString stringWithFormat:@"***%@",[dict valueForKey:@"last_four"]];
        cell.tag = (int)[dict valueForKey:@"id"];
        cell.imageView.image = [UIImage imageNamed:@"ub__creditcard_mastercard.png"];
    }
    
    //configure left buttons
    cell.leftButtons = nil;
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        [self deleteCardForKey:[[arrForCards objectAtIndex:path.row] valueForKey:@"id"] ofCell:cell];
        return NO; //Don't autohide to improve delete expansion animation
    }]];
    
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
 -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return 50;
 }
 */

-(void)getAllMyCards
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString * strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString * strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        [APPDELEGATE showLoadingWithTitle:@"Getting your Cards"];
        
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_CARDS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             ////NSLog(@"History Data = %@",response);
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     [APPDELEGATE hideLoadingView];
                     [arrForCards removeAllObjects];
                     [arrForCards addObjectsFromArray:[response valueForKey:@"payments"]];
                     
                     if (arrForCards.count==0) {
                         [self.addCardBtn setBackgroundImage:[UIImage imageNamed:@"addCard"] forState:UIControlStateNormal];
                         self.tableView.hidden=YES;
                         self.headerView.hidden=YES;
                         self.lblNoCards.hidden=NO;
                         self.imgNoItems.hidden=NO;
                     }
                     else
                     {
                         [self.addCardBtn setBackgroundImage:[UIImage imageNamed:@"addAnotherCard"] forState:UIControlStateNormal];
                         self.tableView.hidden=NO;
                         self.headerView.hidden=NO;
                         self.lblNoCards.hidden=YES;
                         self.imgNoItems.hidden=YES;
                         [self.tableView reloadData];
                     }
                 }
                 else {
                     [APPDELEGATE hideLoadingView];
                     self.tableView.hidden=YES;
                     self.headerView.hidden=YES;
                     self.lblNoCards.hidden=NO;
                     self.imgNoItems.hidden=NO;
                 }
             }
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectZero];
    
    return headerView;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [footerView setBackgroundColor:[Helper getColorFromHexString:@"#fb9d3e" :1.0f]];
    
    return footerView;
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteCardForKey:(NSString *)idVal ofCell:(MGSwipeTableCell *)cell {
    
    if([[AppDelegate sharedAppDelegate]connected]) {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString * strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString * strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
        [dictParam setValue:strForUserId forKey:PARAM_ID];
        [dictParam setValue:idVal forKey:PARAM_CARD_ID];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_DELETE_CARD withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if(response)
             {
                 if([[response valueForKey:@"success"] boolValue]) {
                     NSIndexPath * path = [self.tableView indexPathForCell:cell];
                     [arrForCards removeObjectAtIndex:path.row];
                     [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
                     
                     [self.addCardBtn setBackgroundImage:[UIImage imageNamed:@"addCard"] forState:UIControlStateNormal];
                     [APPDELEGATE showToastMessage:@"Removed Card"];
                     [self getAllMyCards];
                 }
                 else {
                     [APPDELEGATE showToastMessage:@"OOPS!! Something went wrong. Try deleting Again"];
                     [self getAllMyCards];
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

@end
