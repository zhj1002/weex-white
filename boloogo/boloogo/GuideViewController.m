//
//  guideViewController.m
//  jiaorder
//
//  Created by zhj on 2017/3/1.
//  Copyright © 2017年 zhj. All rights reserved.
//

#import "GuideViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import <WeexSDK/WeexSDK.h>
#import <WeexSDK/WXSDKInstance.h>
#import <WeexSDK/WXBridgeManager.h>
#import "AppDefine.h"

@interface GuideViewController ()


@property(nonatomic, weak) NSTimer *timer;
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, assign) int timeNum;
@property(nonatomic, strong) UIButton *timeBtn;

//@property(nonatomic,strong) UIView *returnView;
//
//
@property(nonatomic, assign) int netNum;
//@property(nonatomic, strong) NSTimer *netTime;
//
//@property(nonatomic, strong) UIImageView *defaultImgView;


@property(nonatomic, strong) WXSDKInstance *instance;
@property(nonatomic, strong) WXBridgeManager * bridgeManager;
@property(nonatomic, strong) UIView *weexView;
@property(nonatomic, assign) CGFloat weexHeight;

@end

@implementation GuideViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.weexHeight = self.view.frame.size.height;
    self.navigationController.navigationBarHidden = YES;
    
    _netNum = 0;
    
    
    [self initImgView];
}

-(void)initImgView{
 
    //获取图片数据
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    _timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 20, 60, 20)];
    _timeBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0  blue:234/255.0  alpha:1.0];
    [_timeBtn setTitle:@"4S" forState:UIControlStateNormal];
    _timeBtn.layer.cornerRadius = 5.0;
    _timeBtn.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    _timeBtn.layer.borderWidth = 1.0f;
    _timeBtn.alpha = 0.8;
    [_timeBtn addTarget:self action:@selector(setUserDefault) forControlEvents:UIControlEventTouchUpInside];
    
    _timeNum = 4;

    _imgView.userInteractionEnabled = YES;
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:img]  placeholderImage:[UIImage imageNamed:@"order.png"] options:SDWebImageRefreshCached];
    [self render];
    
    [self.view addSubview:_imgView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self updateInstanceState:WeexInstanceAppear];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateInstanceState:WeexInstanceAppear];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];
}


-(void) setBtnTitle {
    if(_timeNum >= 0) {

        if(_timeNum > 0) {
           _timeNum --;
        }
        [_timeBtn setTitle:[NSString stringWithFormat:@"%ldS",(long)_timeNum] forState:UIControlStateNormal];
        if(_timeNum ==0) {
            [self setUserDefault];
        }
    }

}

-(void)setUserDefault {
  
    [_timer invalidate];
    [_imgView removeFromSuperview];
    _netNum = 1;
    
    self.weexView.hidden = NO;
    
}
- (void) render {
    self.instance = [[WXSDKInstance alloc] init];
    self.bridgeManager = [[WXBridgeManager alloc] init];
    
    self.instance.viewController = self;
    CGFloat width = self.view.frame.size.width;
    self.instance.frame = CGRectMake(self.view.frame.size.width - width,0 , width, self.weexHeight);
    
    __weak typeof (self) weakSelf = self;
    
    self.instance.onCreate = ^(UIView *view) {

        [ _imgView addSubview:_timeBtn];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setBtnTitle) userInfo:nil repeats:YES];
        
        [weakSelf.weexView removeFromSuperview];
     
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
        weakSelf.weexView.hidden = YES;
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, weakSelf.weexView);
    };
    
    self.instance.onFailed = ^(NSError *error) {
        if(_netNum != 0) {
        
          [_imgView addSubview:_timeBtn];
         _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setBtnTitle) userInfo:nil repeats:YES];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络不通畅,请允许网络访问" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self render];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [alert addAction:cancel];
        [alert addAction:ok];

        
        [self presentViewController:alert animated:NO completion:nil];
        
        
    };
    
    self.instance.renderFinish = ^(UIView *view) {
        NSLog(@"render finish");
         [weakSelf updateInstanceState:WeexInstanceAppear];
  
    };
    
    self.instance.updateFinish = ^(UIView *view) {
     
                NSLog(@"hgjgjgjh");
        
    };
    
    NSString *path = HOME_URL;
    [self.instance renderWithURL:[NSURL URLWithString:path] options:@{@"bundleUrl":path} data: nil];
}

- (void)dealloc{
    [self.instance destroyInstance];
}


- (void)updateInstanceState:(WXState)state
{
    if (_instance && _instance.state != state) {
        _instance.state = state;
        
        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}



@end
