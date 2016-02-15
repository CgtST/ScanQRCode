//
//  ViewController.m
//  STScanQRCode
//
//  Created by Mac on 15/5/20.
//  Copyright © 2015年 st. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureSession * session; //AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureDeviceInput * deviceInput;  //输入流
@property (nonatomic,strong)AVCaptureMetadataOutput * dataOutput; //输出流
@property (nonatomic,strong) AVCaptureStillImageOutput * stillImageOutput; //照片输出流对象
@property (nonatomic, strong)AVCaptureVideoPreviewLayer * previewLayer;//预览图层，来显示照相机拍摄到的画面

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupCamera];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //设置灰色背景
    self.view.backgroundColor = [UIColor grayColor];
    UILabel * introudctionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 290, 70)];
    introudctionLabel.numberOfLines = 3;
    introudctionLabel.textColor = [UIColor whiteColor];
    introudctionLabel.text = @"将二维码，条形码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [self.view addSubview:introudctionLabel];
    
    //添加边框
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 300, 300)];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    UIButton * startBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH/2-50, HEIGHT-50, 100, 50)];
    startBtn.backgroundColor = [UIColor yellowColor];
    [startBtn setTitle:@"继续扫" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
  
}

- (void)click:(UIButton *)sender
{
    [self.session startRunning];
}


- (void)setupCamera{
    NSError * error;
    //获取AVCaptureDevice的实例
    AVCaptureDevice * caputreDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //初使化输入流
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:caputreDevice error:&error];
    if (!self.deviceInput) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    
    //创建会话
    self.session = [[AVCaptureSession alloc] init];
    //设置高质量采集率
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    //添加输入流
    [self.session addInput:self.deviceInput];
    //初使化输出流
    self.dataOutput = [[AVCaptureMetadataOutput alloc] init];
    //添加输出流
    [self.session addOutput:self.dataOutput];
    //设置代理在主线程里刷新
    [self.dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置扫码支持的编码格式（如下设置各种条形码和二维码兼容）
    self.dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeAztecCode,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode39Mod43Code];
    
    //显示图像
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = CGRectMake(20, 110, 280, 280);
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    //开始会话
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString * result = [[NSString alloc] init];
    if (metadataObjects != nil && [metadataObjects count]>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        result = metadataObject.stringValue;
    }
    [self.session stopRunning];
    
    NSLog(@"code is %@",result);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"二维码或条形码" message:[NSString stringWithFormat:@"扫到的内容是：%@",result] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
