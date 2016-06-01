//
//  SettingViewController.m
//  JYTest
//
//  Created by mei on 16/5/26.
//  Copyright © 2016年 meichuanhu. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    BOOL isHaveDian;
}
@property (weak, nonatomic) IBOutlet UILabel *coorOneLatitudeLb;
@property (weak, nonatomic) IBOutlet UILabel *coorOneLongitudeLb;
@property (weak, nonatomic) IBOutlet UILabel *coorTwoLatitudeLb;
@property (weak, nonatomic) IBOutlet UILabel *coorTwoLongitudeLb;
@property (weak, nonatomic) IBOutlet UITextField *XTextF;
@property (weak, nonatomic) IBOutlet UITextField *YTextF;
@property (strong, nonatomic)UIAlertView *myAlertView;

@end

@implementation SettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetUIComponents];
}

//加载UI数据
-(void)resetUIComponents{
    self.coorOneLatitudeLb.text = [NSString stringWithFormat:@"%f",self.numberOneLatitude];
    self.coorOneLongitudeLb.text = [NSString stringWithFormat:@"%f",self.numberOneLongitude];
    self.coorTwoLatitudeLb.text = [NSString stringWithFormat:@"%f",self.numberTwoLatitude];
    self.coorTwoLongitudeLb.text = [NSString stringWithFormat:@"%f",self.numberTwoLongitude];
    NSLog(@"%f",[self distanceBetweenOrderBy:self.numberOneLatitude :self.numberTwoLatitude :self.numberOneLongitude :self.numberTwoLongitude]);
}

//返回按钮点击事件
- (IBAction)BackBtnClick:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

//确定按钮点击事件
- (IBAction)CertainBtnClick:(id)sender {
    double X = [self.XTextF.text doubleValue];
    double Y = [self.XTextF.text doubleValue];
    double differX = self.numberOneLatitude - self.numberTwoLongitude;
    double differY = self.numberOneLongitude - self.numberTwoLongitude;
    if (X < fabs(differX) && Y < fabs(differY)){
        [self showAlertViewWithTitle:@"确认用此输入值" andMessage:nil andCBtnTit:@"NO" andOtherBtnTit:@"YES"];
    }else{
        [self showAlertViewWithTitle:@"输入的值超过范围" andMessage:@"请重新输入" andCBtnTit:@"OK" andOtherBtnTit:nil];
    }
    
}

//计算两个经纬度间的距离
-(double)distanceBetweenOrderBy:(double)lat1 :(double)lat2 :(double)lng1 :(double)lng2{
    double dd = M_PI/180;
    double x1=lat1*dd,x2=lat2*dd;
    double y1=lng1*dd,y2=lng2*dd;
    double R = 6371004;
    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));
    //km  返回
    //     return  distance*1000;
    
    //返回 m
    return   distance;
    
}


//创建AlertView
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message andCBtnTit:(NSString *)cancel andOtherBtnTit:(NSString *)other
{
    self.myAlertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:other,nil];
    [self.myAlertView show];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.myAlertView.title isEqualToString:@"确认用此输入值"]) {
        if (buttonIndex == 0) {
      
        }
        
        if (buttonIndex == 1) {
            [self.delegate sendXYFromSettingViewC:self.XTextF.text andY:self.YTextF.text];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
    
    if ([self.myAlertView.title isEqualToString:@"输入的值超过范围"]) {
        
    }

}

#pragma mark - UITextFieldDelegate
//textField.text 输入之前的值 string 输入的字符
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text rangeOfString:@"."].location==NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length]>0)
    {
        unichar single=[string characterAtIndex:0];//当前输入的字符
        if ((single >='0' && single<='9') || single=='.')//数据格式正确
        {
            //首字母不能为0和小数点
            if([textField.text length]==0){
                if(single == '.'){
                    [self showAlertViewWithTitle:@"第一个数字不能为小数点!" andMessage:nil andCBtnTit:@"OK" andOtherBtnTit:nil];

                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            if (single=='.')
            {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian=YES;
                    return YES;
                }else
                {
                    [self showAlertViewWithTitle:@"您已经输入过小数点了!" andMessage:nil andCBtnTit:@"OK" andOtherBtnTit:nil];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            else
            {
                if (isHaveDian)//存在小数点
                {

                    return YES;
                }
                else
                {
                    return YES;
                }
            }
        }else{//输入的数据格式不正确
             [self showAlertViewWithTitle:@"您输入的格式不正确!" andMessage:nil andCBtnTit:@"OK" andOtherBtnTit:nil];
       
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    else
    {
        return YES;
    }
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
