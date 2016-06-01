//
//  SettingViewController.h
//  JYTest
//
//  Created by mei on 16/5/26.
//  Copyright © 2016年 meichuanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewControllerDelegate <NSObject>

-(void)sendXYFromSettingViewC:(NSString *)X andY:(NSString *)Y;

@end

@interface SettingViewController : UIViewController

@property(nonatomic,assign)double numberOneLatitude;
@property(nonatomic,assign)double numberOneLongitude;
@property(nonatomic,assign)double numberTwoLatitude;
@property(nonatomic,assign)double numberTwoLongitude;
@property(nonatomic,assign)id<SettingViewControllerDelegate>delegate;
@end
