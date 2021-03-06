//
//  UnfollowViewController.m
//  TwitterBoard
//
//  Created by GLB-254 on 4/18/15.
//  Copyright (c) 2015 globussoft. All rights reserved.
//

#import "FollowingViewControllerTboard.h"
#import "FHSTwitterEngine.h"
#import "SingletonTboard.h"
#import "TableCustomCell.h"
#import "UIImageView+WebCache.h"
#import "FollowingUserViewControllerTboard.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ProfileViewTboard.h"
@interface FollowingViewControllerTboard ()

@end

@implementation FollowingViewControllerTboard
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //-------------
    followersIdList=[[NSMutableArray alloc]init];
    followerScreenName=[[NSMutableArray alloc]init];
    currentSelection=-1;
    nextCursor=-1;
    //---------------
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(findFollowingList) name:@"ReloadTimeLine" object:nil];
    [self tableToShowFollowUser];
       // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeBackGroundColor:) name:@"ChangeBackground" object:nil];
    if([SingletonTboard networkCheck])
    {
        [self findFollowingList];
    }
    else
    {
        UIAlertView * noInternet=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Check your Connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noInternet show];
    }

    //    [self fetchTimeline];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ChangeBackground" object:nil];
}
-(void)findFollowingList
{
    [NSThread detachNewThreadSelector:@selector(showHUDLoadingView:) toTarget:self withObject:nil];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {

            [followersIdList removeAllObjects];
    if ([FHSTwitterEngine sharedEngine].isAuthorized)
    {
       
        NSString * cursor=@"-1";
        NSLog(@"Checking Current User Id %@",[SingletonTboard sharedSingleton].currectUserTwitterId);
        id returned=[[FHSTwitterEngine sharedEngine]listFriendsForUser:[SingletonTboard sharedSingleton].currectUserTwitterId isID:YES withCursor:cursor];
      
        if ([returned isKindOfClass:[NSError class]])
        {
            
        }
        else
        {
              nextCursor=[[returned objectForKey:@"next_cursor_str"] longLongValue];
            NSLog(@"friends list returned  %@ %@",[returned objectForKey:@"users"],returned);
            NSArray * array=[returned objectForKey:@"users"];
            
            NSMutableArray * tempArray=[[NSMutableArray alloc]init];
            for (int i=0;i<[array count];i++)
            {
                NSMutableDictionary * tempDict=[[NSMutableDictionary alloc]init];
                //--------------------
                NSDictionary * dict=[array objectAtIndex:i];
                NSLog(@"friends list  %@",[dict objectForKey:@"profile_image_url_https"]);
                [tempDict setObject:[dict objectForKey:@"profile_image_url_https"] forKey:@"ImageUrl"];
                [tempDict setObject:[dict objectForKey:@"name"] forKey:@"FollowerName"];
                [tempDict setObject:[dict objectForKey:@"description"] forKey:@"dataDesc"];
                [tempDict setObject:[dict objectForKey:@"followers_count"] forKey:@"FollowersCount"];
                [tempDict setObject:[dict objectForKey:@"friends_count"] forKey:@"FriendCount"];
                [tempDict setObject:[dict objectForKey:@"statuses_count"] forKey:@"TweetCount"];
                [followerScreenName addObject:[dict objectForKey:@"screen_name"]];
                [followersIdList addObject:[dict objectForKey:@"id_str"]];
                [tempArray addObject:tempDict];
               
            }
            
            NSLog(@"Whole data %@",tempArray);
            self.alldata=[NSArray arrayWithArray:tempArray];
            NSLog(@"Whole data %@ %lu",self.alldata,(unsigned long)[self.alldata count]);
        }
        
    }
    else
    {
        NSLog(@"Not Authorized");
    }
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    if(!(self.alldata.count>0))
                    {
                        [self noOneHerePopUp];
                    }
                    else
                    {
                        [nooneView removeFromSuperview];
                    }
                    [self.showFollowing reloadData];
                    [self hideHUDLoadingView];
                    // [av show];
                }
            });
        }
    });


}


-(void)findFollowingListPaging
{
    [NSThread detachNewThreadSelector:@selector(showHUDLoadingView:) toTarget:self withObject:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            
            if ([FHSTwitterEngine sharedEngine].isAuthorized)
            {
                
                NSString * cursor=[NSString stringWithFormat:@"%lld",nextCursor];
                id returned=[[FHSTwitterEngine sharedEngine]listFriendsForUser:[SingletonTboard sharedSingleton].currectUserTwitterId isID:YES withCursor:cursor];
                
                if ([returned isKindOfClass:[NSError class]])
                {
                    
                }
                else
                {
                    nextCursor=[[returned objectForKey:@"next_cursor_str"] longLongValue];
                    NSLog(@"friends list returned  %@ %@",[returned objectForKey:@"users"],returned);
                    NSArray * array=[returned objectForKey:@"users"];
                    
                    NSMutableArray * tempArray=[[NSMutableArray alloc]init];
                    for (int i=0;i<[array count];i++)
                    {
                        NSMutableDictionary * tempDict=[[NSMutableDictionary alloc]init];
                        //--------------------
                        NSDictionary * dict=[array objectAtIndex:i];
                        NSLog(@"friends list  %@",[dict objectForKey:@"profile_image_url_https"]);
                        [tempDict setObject:[dict objectForKey:@"profile_image_url_https"] forKey:@"ImageUrl"];
                        [tempDict setObject:[dict objectForKey:@"name"] forKey:@"FollowerName"];
                        [tempDict setObject:[dict objectForKey:@"description"] forKey:@"dataDesc"];
                        [tempDict setObject:[dict objectForKey:@"followers_count"] forKey:@"FollowersCount"];
                        [tempDict setObject:[dict objectForKey:@"friends_count"] forKey:@"FriendCount"];
                        [tempDict setObject:[dict objectForKey:@"statuses_count"] forKey:@"TweetCount"];
                        [followerScreenName addObject:[dict objectForKey:@"screen_name"]];
                        [followersIdList addObject:[dict objectForKey:@"id_str"]];
                        [tempArray addObject:tempDict];
                    }
                    
                    NSLog(@"Whole data %@",tempArray);
                    if(self.alldata.count==0)
                    {
                        
                        self.alldata=[NSArray arrayWithArray:tempArray];
                    }
                    else
                    {
                        refresh=false;
                        self.alldata=[self.alldata arrayByAddingObjectsFromArray:tempArray];
                    }
                    NSLog(@"Whole data %@ %lu",self.alldata,(unsigned long)[self.alldata count]);
                }
                
            }
            else
            {
                NSLog(@"Not Authorized");
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    [self.showFollowing reloadData];
                    [self hideHUDLoadingView];
                    // [av show];
                }
            });
        }
    });
    
    
}

#pragma mark Table View Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"All Follower";
    
    TableCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[TableCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.contentView.layer.borderWidth=1;
    cell.contentView.layer.borderColor=[UIColor grayColor].CGColor;
    cell.contentView.layer.shadowOffset = CGSizeMake(0,0);
    cell.contentView.layer.shadowRadius = 0;
    cell.contentView.layer.shadowOpacity = 0.5;
    
    
    UITapGestureRecognizer * tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnImage:)];
   // [cell.userImage addGestureRecognizer:tapGesture];
    cell.userImage.tag=indexPath.section;
    cell.userImage.userInteractionEnabled=YES;
    
    NSDictionary * dataDict=[self.alldata objectAtIndex:indexPath.section];
    
    cell.userNameDesc.text=[dataDict objectForKey:@"FollowerName"];
    [cell.userImage sd_setImageWithURL:[NSURL URLWithString:[dataDict objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"place_holder.png"]];
   
    
//    cell.myView.text=[dataDict objectForKey:@"dataDesc"];
    //---
    NSString * followercount=[NSString stringWithFormat:@"%d",[[dataDict objectForKey:@"FollowersCount"] intValue]];
    NSString * followingCount=[NSString stringWithFormat:@"%d",[[dataDict objectForKey:@"FriendCount"] intValue]];

    NSString * tweetCount=[NSString stringWithFormat:@"%d",[[dataDict objectForKey:@"TweetCount"] intValue]];

    //---
    cell.followerCount.text=[self adjustText:followercount];
    cell.followingCount.text=[self adjustText:followingCount];
    cell.tweetCount.text=[self adjustText:tweetCount];
    //---------
    cell.add_minusButton.tag=indexPath.section;
    [cell.add_minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.add_minusButton.titleLabel.font=[UIFont systemFontOfSize:10];
    [cell.add_minusButton setBackgroundImage:[UIImage imageNamed:@"btn_blue.png"] forState:UIControlStateNormal];
    [cell.add_minusButton setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
    cell.add_minusButton.titleLabel.font=[UIFont boldSystemFontOfSize:8];
    [cell.add_minusButton addTarget:self action:@selector(follow_unfollowButton:) forControlEvents:UIControlEventTouchUpInside];
    

    [cell.tweetButton addTarget:self action:@selector(tweetAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.tweetButton.tag=indexPath.section;
    if(currentSelection==indexPath.section)
    {
        cell.cellFooterView.hidden=false;
        cell.cellFooterView.frame=CGRectMake(0,120, cell.contentView.frame.size.width,40);
        [UIView animateWithDuration:1 animations:^{
            cell.contentView.layer.opacity = 1.0f;
        }];

    }
    else
    {
        [UIView animateWithDuration:1 animations:^{
            cell.contentView.layer.opacity = 1.0f;
        }];

        cell.cellFooterView.hidden=true;
 
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (currentSelection == indexPath.section)
//    {
//        currentSelection = -1;
//        [tableView reloadData];
//        return;
//    }
    //NSDictionary * dataDict=[self.alldata objectAtIndex:indexPath.section];
//tweetScreenName=[followerScreenName objectAtIndex:indexPath.section];
//    NSLog(@"Follower Id %@",[dataDict objectForKey:@""]);
//    NSInteger row = [indexPath section];
//    currentSelection = (int)row;
//    [self.showFollowing reloadData];
    
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.alldata count];
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(currentSelection==indexPath.section)
    {
        return 160;

    }
    else
    {
        return 80;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return 0;
    }
    return 10;
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 1;
    if(y > h + reload_distance)
    {
        if(!refresh)
        {
            refresh=true;
            if([self.alldata count]<180)
            {   if(nextCursor!=0)
            {
                [self findFollowingListPaging];
            }
            }
        }
    }
}
#pragma mark Show Profile
-(void)tappedOnName:(UIGestureRecognizer *)recognizer
{
    NSLog(@"tag on the label %ld",(long)recognizer.view.tag);
    NSDictionary * dataDict=[self.alldata objectAtIndex:recognizer.view.tag];
    NSLog(@"tapped name data %@",dataDict);
    NSString * userName=[dataDict objectForKey:@"FollowerName"];
    ProfileViewTboard * profileView=[[ProfileViewTboard alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    profileView.userScreenName=userName;
    [profileView fetchUserClickedTimeline];
    [self.view addSubview:profileView];
}

#pragma mark Tweet User Timeline-------
-(void)tweetAction:(UIButton *)btn
{
    NSLog(@"button.tag %ld",(long)btn.tag);
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Tweet"
                                                                       message:@"Enter the text up to 140 characters only" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [myAlertView show];

    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Tweet Text%@", [alertView textFieldAtIndex:0].text);
//    NSData * data=UIImagePNGRepresentation([UIImage imageNamed:@"follow.png"]);
//    [[FHSTwitterEngine sharedEngine]postTweet:@"Hello" withImageData:data];
//
    NSString * strReply=[NSString stringWithFormat:@"@%@ %@",tweetScreenName,[alertView textFieldAtIndex:0].text];
    [[FHSTwitterEngine sharedEngine]postTweet:strReply inReplyTo:nil];
}
-(void)tableToShowFollowUser
{
    self.showFollowing=[[UITableView alloc]initWithFrame:CGRectMake(5,10,SCREEN_WIDTH-10, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.showFollowing.delegate=self;
    self.showFollowing.dataSource=self;
    UIView * footerView=[[UIView alloc]init];
    footerView.frame=CGRectMake(0, 0,SCREEN_WIDTH, 80);
    self.showFollowing.tableFooterView=footerView;
    [self.view addSubview:self.showFollowing];
    
}
-(void)follow_unfollowButton:(UIButton *)btn
{
    NSLog(@"Follwer list id %@",[followersIdList objectAtIndex:btn.tag]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            
            
            if ([FHSTwitterEngine sharedEngine].isAuthorized)
            {
                id returned=[[FHSTwitterEngine sharedEngine]unfollowUser:[followersIdList  objectAtIndex:btn.tag] isID:YES];
                if ([returned isKindOfClass:[NSError class]])
                {
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        @autoreleasepool {
                            NSMutableArray * tempArray=[[NSMutableArray alloc]initWithArray:self.alldata];
                            [tempArray removeObjectAtIndex:btn.tag];
                            self.alldata=tempArray;
                             [SingletonTboard updateFollowingArray:[followersIdList  objectAtIndex:btn.tag]];
                            [followersIdList removeObjectAtIndex:btn.tag];
                            [self.showFollowing reloadData];                        }
                    });
                   
                  
                    NSLog(@"unfollowed");
                }
        
                
            }
            else
            {
                NSLog(@"Not Authorized");
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    // [av show];
                }
            });
        }
    });
  
}
#pragma mark
-(void)tapOnImage:(UITapGestureRecognizer*)recognizer
{
    NSDictionary * dict=[self.alldata objectAtIndex:recognizer.view.tag];
    [self fetchUser:[followersIdList objectAtIndex:recognizer.view.tag] nameOfUser:[dict objectForKey:@"FollowerName"]];
}
-(void)fetchUser:(NSString *)timeLineId nameOfUser:(NSString*)userName
{
        NSMutableArray * tempArray=[[NSMutableArray alloc]init];

    if ([FHSTwitterEngine sharedEngine].isAuthorized)
    {
        id returned=[[FHSTwitterEngine sharedEngine]getTimelineForUser:timeLineId isID:YES count:20];
        NSString * title;
        NSString * message;
        if ([returned isKindOfClass:[NSError class]])
        {
            NSError *error = (NSError *)returned;
            title = [NSString stringWithFormat:@"Error %ld",(long)error.code];
            message = error.localizedDescription;
            NSLog(@"Error in finding home timeline %@ %@",message,title);
        }
        else
        {
            NSLog(@"Home timeline%@",returned);
            for (int i=0;i<[returned count]; i++)
            {
                NSMutableDictionary * tempForEachRow=[[NSMutableDictionary alloc]init];
                //----------------------------
                NSDictionary * dictTimelineRow=[returned objectAtIndex:i];
                NSLog(@"text desc  %@",[dictTimelineRow objectForKey:@"text"]);
                id dictOfdict=[dictTimelineRow objectForKey:@"user"];
                //NSLog(@"profile url  %@",[dictOfdict objectForKey:@"profile_image_url"]);
                [tempForEachRow setObject:[dictTimelineRow objectForKey:@"text"] forKey:@"Description"];
                [tempForEachRow setObject:[dictOfdict objectForKey:@"profile_image_url"] forKey:@"Userimage"];
                [tempForEachRow setObject:[dictTimelineRow objectForKey:@"id_str"] forKey:@"FollowerId"];
                [tempForEachRow setObject:[dictOfdict objectForKey:@"screen_name"] forKey:@"FollowerUserName"];
                [tempArray addObject:tempForEachRow];
                //----------------------------
            }
            //Copy the data in whole data
        }
    }
    FollowingUserViewControllerTboard * fllObj=[[FollowingUserViewControllerTboard alloc]init];
    fllObj.allData=tempArray;
    fllObj.nameUser=userName;
    [self.navigationController pushViewController:fllObj animated:YES];
    
}
-(NSString *)adjustText:(NSString *)dataToCheck
{
    
    float  i=[dataToCheck floatValue];
    if (i>=10000000)
    {
        i=i/10000000;
        return [NSString stringWithFormat:@"%.2fCr",i];
    }
    else if (i>=100000)
    {
            i=i/100000;
            return [NSString stringWithFormat:@"%.2fM",i];
    }
    else if(i>=10000)
    {
        i=i/10000;
        return [NSString stringWithFormat:@"%.2fK",i];
    }


    return dataToCheck;
}
#pragma mark -
#pragma mark - Loading View mbprogresshud

-(void) showHUDLoadingView:(NSString *)strTitle
{
    [self performSelectorOnMainThread:@selector(loadOnMainThread:) withObject:nil waitUntilDone:YES];
}
-(void)loadOnMainThread:(NSString *)strTitle
{
    HUD = [[MBProgressHUD alloc] init];
    [self.view addSubview:HUD];
    //HUD.delegate = self;
    //HUD.labelText = [strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    HUD.detailsLabelText=[strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    [HUD show:YES];
    
}
#pragma mark -
#pragma mark - Loading View mbprogresshud


-(void) hideHUDLoadingView
{
    [HUD removeFromSuperview];
    HUD=nil;
}
-(void)changeBackGroundColor:(NSNotification*)notify
{
    NSString * notifyObj=notify.object;
    if([notifyObj isEqualToString:@"Slide"])
    {
        if(!backView)
        {
            backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            backView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:.6];
        }
        [self.view addSubview:backView];
        
    }
    else
    {
        [backView removeFromSuperview];
        self.view.backgroundColor=[UIColor clearColor];
        
    }
}

-(void)checkUserFriend
{
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            
            if([SingletonTboard networkCheck])
            {
                id getFollowerId=[[FHSTwitterEngine sharedEngine]getFriendsIDs];
                NSLog(@"followers id %@",getFollowerId);
                if([getFollowerId isKindOfClass:[NSError class]])
                {
                    
                }
                else
                {
                    friendsId=[getFollowerId objectForKey:@"ids"];
                }
            }
            else
            {
                
            }
        }
    });
    
}
-(void)noOneHerePopUp
{
    
    if(!nooneView)
    {
    nooneView=[[UIView alloc]initWithFrame:CGRectMake(40, SCREEN_HEIGHT/2-180,SCREEN_WIDTH-80,360)];
        [self.view addSubview:nooneView];
    }
    nooneView.backgroundColor=[UIColor whiteColor];
    nooneView.layer.shadowColor=[UIColor blackColor].CGColor;
    nooneView.layer.shadowOffset=CGSizeMake(0, 0);
    nooneView.layer.shadowOpacity=.5;
    //-------------Animate Pop Up
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.8;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.9];
    
    [nooneView.layer addAnimation:scaleAnimation forKey:@"scale"];

    //--------------
    UIImageView * noUser=[[UIImageView alloc]initWithFrame:nooneView.bounds];
    noUser.image=[UIImage imageNamed:@"notfound_320x480"];
    [nooneView addSubview:noUser];
    //---------------
    UILabel * noFollowingUser=[[UILabel alloc]init];
    noFollowingUser.frame=CGRectMake(0, noUser.frame.size.height-180, noUser.frame.size.width, 20);
    noFollowingUser.textAlignment=NSTextAlignmentCenter;
    noFollowingUser.text=@"You are Not Following anyone!";
    [nooneView addSubview:noFollowingUser];
}

- (void)didReceiveMemoryWarning {
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

@end
