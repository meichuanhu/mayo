//
//  MapViewController.m
//  JYTest
//
//  Created by mei on 16/5/24.
//  Copyright © 2016年 meichuanhu. All rights reserved.
//

#import "MapViewController.h"
#import "PointModel.h"

#import "SettingViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件


@interface MapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,UIAlertViewDelegate,SettingViewControllerDelegate>{
    BMKLocationService *_locService;
    BMKMapView* _mView;
    int _number;
    PointModel *_modelOne;  //农业航线第一个点
    PointModel *_modelTwo;  //农业航线第二个点
    double _X; //农业航线X方向
    double _Y; //农业航线Y方向
}

@property (weak, nonatomic) IBOutlet UIView *inBoxView;  //装载地图的视图层
@property (weak, nonatomic) IBOutlet UIButton *deleteAllBtn;  //全删btn
@property (weak, nonatomic) IBOutlet UIButton *routeBtn;  //农业航线btn
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;  //设置btn
@property (weak, nonatomic) IBOutlet UIButton *lineBtn; //划线模式btn
@property (weak, nonatomic) IBOutlet UIView *toolsView; //工具栏的视图层
@property(strong,nonatomic)NSMutableArray *pointArr;  //所有模式下所存的大头针的数组
@property(strong,nonatomic)NSMutableArray *linePointArr; //划线模式下横线的端点数组
@property(strong,nonatomic)NSMutableArray *mLayerArr;  //划线模式下横线数组
@property(strong,nonatomic)NSMutableArray *toolsBtnArr;  //工具栏的btn数组
@property (strong, nonatomic)UIAlertView *myAlertView;
@property(assign,nonatomic)BOOL isDelete; //删除
@property(assign,nonatomic)BOOL isLine;  //划线
@property(assign,nonatomic)BOOL isRoute;  //农业

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化参数
    [self resetComponents];
    
    
    //初始化BMKLocationService
    [self resetBMKLocationService];


    //创建百度地图的视图层
    [self createMapView];
    
}

- (void) viewDidAppear:(BOOL)animated {
    //将要显示界面时进行模式选择
    if (!_isLine && !_isRoute) {
     [self showAlertViewWithTitle:@"请选择模式" andMessage:nil andCBtnTit:@"农业模式" andOtherBtnTit:@"划线模式"];
    }
}

#pragma mark - 初始化参数
-(void)resetComponents{
    _number = 0;
    _X = 0;
    _Y = 0;
    _modelOne = [[PointModel alloc] init];
    _modelTwo = [[PointModel alloc] init];
    self.mLayerArr = [[NSMutableArray alloc] init];
    self.pointArr = [[NSMutableArray alloc] init];
    self.linePointArr = [[NSMutableArray alloc] init];
    self.toolsBtnArr = [[NSMutableArray alloc] init];
}


#pragma mark - 创建定位
-(void)resetBMKLocationService{
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate =self;
    //启动LocationService
    [_locService startUserLocationService];
}


#pragma mark - 创建地图视图层
-(void)createMapView{
    _mView = [BMKMapView new];
    _mView.delegate =self;
    _mView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inBoxView addSubview:_mView];
    _mView.tag = 99;
    //手写约束，让mView自适应xib中inBoxView的大小
    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(_mView);
    [self.inBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDic]];
    [self.inBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewsDic]];
    
    _mView.showsUserLocation = YES;
    _mView.userTrackingMode = BMKUserTrackingModeNone;
    //        [_mView setMapType:BMKMapTypeSatellite];
    _mView.rotateEnabled = NO;

}
//31.220381 121.483201
#pragma mark - 创建农业航线的矩形框
-(void)createAgricultureRoute{
    CLLocationCoordinate2D coords[4] = {0};
    //实现四点矩形框架
    coords[0].latitude = _modelOne.latitude;
    coords[0].longitude = _modelOne.longitude;
    coords[1].latitude = _modelOne.latitude;
    coords[1].longitude = _modelTwo.longitude;
    coords[2].latitude = _modelTwo.latitude;
    coords[2].longitude = _modelTwo.longitude;
    coords[3].latitude = _modelTwo.latitude;
    coords[3].longitude = _modelOne.longitude;
    
    BMKPolygon* polygon = [BMKPolygon polygonWithCoordinates:coords count:4];
    [_mView addOverlay:polygon];
}

#pragma mark - 设置AlertView的内容
- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message andCBtnTit:(NSString *)cancel andOtherBtnTit:(NSString *)other
{
    self.myAlertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:other,nil];
    [self.myAlertView show];
}

#pragma mark - 点击tools的btn进行删除
-(void)toolsBtnClick:(UIButton *)btn{
    [_linePointArr removeObjectAtIndex:btn.tag];
    NSLog(@"删线条了");
    _number--;
    [_mView removeOverlay:[_mLayerArr objectAtIndex:btn.tag]];
    [_mLayerArr removeObjectAtIndex:btn.tag];
    if (_pointArr!=nil) {
        [_mView removeAnnotation:[_pointArr objectAtIndex:btn.tag]];
        [self.pointArr removeObjectAtIndex:btn.tag];
    }
    [self.toolsBtnArr removeObjectAtIndex:btn.tag];
    //打开上一个点的btn交互
    UIButton *subBtn = self.toolsBtnArr.lastObject;
    subBtn.enabled = YES;
    [btn removeFromSuperview];
}

#pragma mark - 点击全删按钮，清空所有数据
- (IBAction)deleteAllBtnClick:(id)sender {
    [self showAlertViewWithTitle:@"是否全部删除" andMessage:nil andCBtnTit:@"NO" andOtherBtnTit:@"YES"];

}

#pragma mark - 点击切换农业模式
- (IBAction)routeBtnClick:(id)sender {
    [self showAlertViewWithTitle:@"切换农业模式" andMessage:nil andCBtnTit:@"NO" andOtherBtnTit:@"YES"];
    
}

#pragma mark - 点击到设置界面，进行农业航线设置
- (IBAction)settingBtnClick:(id)sender {
    if (_isRoute) {
        SettingViewController *svc = [[SettingViewController alloc] init];
        svc.numberOneLatitude = _modelOne.latitude;
        svc.numberOneLongitude = _modelOne.longitude;
        svc.numberTwoLatitude = _modelTwo.latitude;
        svc.numberTwoLongitude = _modelTwo.longitude;
        svc.delegate = self;
        [self presentViewController:svc animated:NO completion:nil];
    }else{
        [self showAlertViewWithTitle:@"请切换到农业模式再进行设置" andMessage:nil andCBtnTit:@"OK" andOtherBtnTit:nil];
    }
}

#pragma mark - 点击切换划线模式
- (IBAction)lineBtnClick:(id)sender {
    [self showAlertViewWithTitle:@"切换划线模式" andMessage:nil andCBtnTit:@"NO" andOtherBtnTit:@"YES"];
}



#pragma mark - BMKMapViewDelegate
//获取用户点击的地图上的点的经纬度
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"onClickedMapBlank-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    
    NSString* showmeg = [NSString stringWithFormat:@"您点击了地图空白处(blank click).\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", coordinate.longitude,coordinate.latitude,
                         
                         (int)_mView.zoomLevel,_mView.rotation,_mView.overlooking];
    NSLog(@"%@",showmeg);
    //核心代码
    // 在点击时，添加PointAnnotation将他的坐标定为点击点的坐标
    if (_isLine) {  //划线模式
        if (_number + 1 < self.view.frame.size.width/50) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10 + _number*50, 5, 40, 30);
        [btn setBackgroundImage:[UIImage imageNamed:@"Text_Btn"] forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"%d",_number+1] forState:UIControlStateNormal];
        btn.tag = _number;
        btn.titleLabel.textColor = [UIColor whiteColor];
        [self.toolsBtnArr addObject:btn];
        [btn addTarget:self action:@selector(toolsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //关闭上一个点的btn交互
        for (UIButton *subBtn in self.toolsBtnArr) {
            if (subBtn.tag == btn.tag -1) {
                subBtn.enabled = NO;
            }
        }
        [_toolsView addSubview:btn];
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = coordinate;
        annotation.title = @"";
        [self.pointArr addObject:annotation];
        [_mView addAnnotation:annotation];
        _number++;
        // 画折线
        PointModel * model =[[PointModel alloc] init];
        model.latitude=coordinate.latitude;
        model.longitude=coordinate.longitude;
        [self.linePointArr addObject:model];
        CLLocationCoordinate2D coors[100] = {0};
        for (int i=0; i<_number; i++) {
            PointModel * model =[self.linePointArr objectAtIndex:i];
            coors[i].latitude=model.latitude;
            coors[i].longitude=model.longitude;
            NSLog(@"%f,%f,%d",coors[i].latitude,coors[i].longitude,_number-1);
        }
            BMKPolyline* polyline = [[BMKPolyline alloc] init];
            polyline = [BMKPolyline polylineWithCoordinates:coors count:_number];
//            BMKPolylineView *pView = [[BMKPolylineView alloc] initWithPolyline:polyline];
            [_mLayerArr addObject:polyline];
            [_mView addOverlay:polyline];
        NSLog(@"onClickedMapBlank-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
        }else{
            [self showAlertViewWithTitle:@"达到创建上线" andMessage:nil andCBtnTit:@"OK" andOtherBtnTit:nil];
        }
    }else if(_isRoute){ //农业航线模式
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = coordinate;
        [self.pointArr addObject:annotation];
        if (self.pointArr.count <= 2) {
            if (self.pointArr.count == 1) {
                annotation.title = @"这是起始点";
                _modelOne.latitude = coordinate.latitude;
                _modelOne.longitude = coordinate.longitude;
            }else if (self.pointArr.count == 2){
                annotation.title = @"这是终点";
                _modelTwo.longitude = coordinate.longitude;
                _modelTwo.latitude = coordinate.latitude;
                
                [self createAgricultureRoute];
            }
            [_mView addAnnotation:annotation];
        }
        if (self.pointArr.count >2) {
            [self showAlertViewWithTitle:@"请删除并画出新的执行区域" andMessage:nil andCBtnTit:@"OK" andOtherBtnTit:nil];
        }
    }
}


//大头针动画
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示

        return newAnnotationView;
    }
    
    return nil;
}

//横线和矩形
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
            polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:1];
            polylineView.lineWidth = 3.0;

        return polylineView;
    }
    if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth = 5.0;
        return polygonView;
    }
    return nil;
}




#pragma mark - BMKLocationServiceDelegate
//在进入界面时进行定位
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //获取当前的位置，将当前位置作为地图中心点
    //由于可能重复获取，只在第一次获取位置时，更新地图中心点
    static int i = 0;
    if (!i) {
        BMKCoordinateRegion region;
        region.span.latitudeDelta=0.007;
        region.span.longitudeDelta=0.007;
        region.center = userLocation.location.coordinate;
        i = 1;
        [_mView setRegion:region];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.myAlertView.title isEqualToString:@"请选择模式"]) {
        if (buttonIndex == 0) {
            _isLine = NO;
            _isRoute = YES;
        }
        
        if (buttonIndex == 1) {
            _isLine = YES;
            _isRoute = NO;
        }
    }
    
    if ([self.myAlertView.title isEqualToString:@"切换农业模式"]) {
        if (buttonIndex == 0) {
            
        }
        if (buttonIndex == 1) {
            [_mView removeOverlays:_mView.overlays];
            [_mView removeAnnotations:_mView.annotations];
            [self.pointArr removeAllObjects];
            [self.linePointArr removeAllObjects];
            _isLine = NO;
            _isRoute = YES;
            _number = 0;
            for (UIButton *btn in self.toolsBtnArr) {
                [btn removeFromSuperview];
            }
            [self.toolsBtnArr removeAllObjects];
            [self.mLayerArr removeAllObjects];
            _X = 0;
            _Y = 0;
        }
    }
    
    if ([self.myAlertView.title isEqualToString:@"切换划线模式"]) {
        if (buttonIndex == 0) {
            
        }
        if (buttonIndex == 1) {
            [_mView removeOverlays:_mView.overlays];
            [_mView removeAnnotations:_mView.annotations];
            [self.pointArr removeAllObjects];
            [self.linePointArr removeAllObjects];
            _isLine = YES;
            _isRoute = NO;
            _number = 0;
            _number = 0;
            for (UIButton *btn in self.toolsBtnArr) {
                [btn removeFromSuperview];
            }
            [self.toolsBtnArr removeAllObjects];
            [self.mLayerArr removeAllObjects];
            _X = 0;
            _Y = 0;
        }
    }
    
    if ([self.myAlertView.title isEqualToString:@"是否全部删除"]) {
        if (buttonIndex == 0) {
            
        }
        if (buttonIndex == 1) {
            [_mView removeOverlays:_mView.overlays];
            [_mView removeAnnotations:_mView.annotations];
            [self.pointArr removeAllObjects];
            [self.linePointArr removeAllObjects];
            _number = 0;
            for (UIButton *btn in self.toolsBtnArr) {
                [btn removeFromSuperview];
            }
            [self.toolsBtnArr removeAllObjects];
            [self.mLayerArr removeAllObjects];
            _X = 0;
            _Y = 0;
        }
    }
    
    if ([self.myAlertView.title isEqualToString:@"达到创建上线"]) {

    }
    
    if ([self.myAlertView.title isEqualToString:@"请切换到农业模式再进行设置"]) {
        
    }
    
}


#pragma mark - SettingViewControllerDelegate
-(void)sendXYFromSettingViewC:(NSString *)X andY:(NSString *)Y{
    //这里必须要将原航线删除不然，重复设置会出现航线的叠加
    [_mView removeOverlays:_mLayerArr];
    [_mLayerArr removeAllObjects];
    _X = [X doubleValue];
    _Y = [Y doubleValue];
    //核心代码（默认从用户所画范围的左下角开始）
    CLLocationCoordinate2D cooStart;
    _modelOne.latitude > _modelTwo.latitude ? (cooStart.latitude = _modelTwo.latitude) : (cooStart.latitude = _modelOne.latitude);
    _modelOne.longitude > _modelTwo.longitude ? (cooStart.longitude = _modelTwo.longitude) : (cooStart.longitude = _modelOne.longitude);
    CLLocationCoordinate2D cooEnd;
    _modelOne.latitude < _modelTwo.latitude ? (cooEnd.latitude = _modelTwo.latitude) : (cooEnd.latitude = _modelOne.latitude);
    _modelOne.longitude < _modelTwo.longitude ? (cooEnd.longitude = _modelTwo.longitude) : (cooEnd.longitude = _modelOne.longitude);
    //进行判断当根据传进来的Y值来画横线（也就是无人机的航线）
    //水平方向的航线
    for (double j=cooStart.latitude; j<cooEnd.latitude; j+=_Y) {
        CLLocationCoordinate2D coors[100] = {0};
        for (int i = 0; i<2; i++) {
            if (i == 0) {
                coors[i].latitude=j;
                coors[i].longitude=cooStart.longitude;
            }else{
                coors[i].latitude = j;
                coors[i].longitude = cooEnd.longitude;
            }
        }
        BMKPolyline* polyline = [[BMKPolyline alloc] init];
        polyline = [BMKPolyline polylineWithCoordinates:coors count:2];

        [_mLayerArr addObject:polyline];
        [_mView addOverlay:polyline];
    }
    //竖直左方向的航线
    for (double j = cooStart.latitude + _Y; j + _Y < cooEnd.latitude; j += 2*_Y) {
        CLLocationCoordinate2D coors[100] = {0};
        for (int i = 0; i<2; i++) {
            if (i == 0) {
                coors[i].latitude = j;
                coors[i].longitude = cooStart.longitude;
            }else{
                coors[i].latitude = j + _Y;
                coors[i].longitude = cooStart.longitude;
            }
        }
        BMKPolyline* polyline = [[BMKPolyline alloc] init];
        polyline = [BMKPolyline polylineWithCoordinates:coors count:2];

        [_mLayerArr addObject:polyline];
        [_mView addOverlay:polyline];
    }
    //竖直右方向的航线
    for (double j = cooStart.latitude ; j + _Y< cooEnd.latitude; j += 2*_Y) {
        CLLocationCoordinate2D coors[100] = {0};
        for (int i = 0; i<2; i++) {
            if (i == 0) {
                coors[i].latitude = j;
                coors[i].longitude = cooEnd.longitude;
            }else{
                coors[i].latitude = j + _Y;
                coors[i].longitude = cooEnd.longitude;
            }
        }
        BMKPolyline* polyline = [[BMKPolyline alloc] init];
        polyline = [BMKPolyline polylineWithCoordinates:coors count:2];

        [_mLayerArr addObject:polyline];
        [_mView addOverlay:polyline];
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
