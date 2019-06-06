//
//  RMCaptureViewController.m
//  realMatch-OC
//
//  Created by yxl on 2019/6/3.
//  Copyright © 2019 qingting. All rights reserved.
//

#import "RMCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+RealMatch.h"
#import "UIDevice+RealMatch.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautyFilter.h"

@interface RMCaptureViewController ()<RouterController,AVCaptureFileOutputRecordingDelegate>

//@property (nonatomic,strong) AVCaptureSession* captureSession;
//@property (nonatomic,strong) AVCaptureDeviceInput * captureDeviceInput;
//@property (nonatomic,strong) AVCaptureMovieFileOutput * caputureMovieFileOutput;
//@property (nonatomic,strong) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;
//@property (nonatomic,strong) UIView* captureView;

@property (nonatomic,strong) GPUImageVideoCamera* videoCamera;
@property (nonatomic,strong) GPUImageView* filterView;
@property (nonatomic,strong) GPUImageBeautyFilter* filter;
@property (nonatomic,strong) GPUImageMovieWriter* movieWriter;

@end

@implementation RMCaptureViewController

-(instancetype)initWithRouterParams:(NSDictionary *)params{
    if(self = [super init]){
        
    }
    return self;
}

-(DisplayStyle)displayStyle{
    return DisplayStylePush;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _filter = [[GPUImageBeautyFilter alloc]init];
    [_filter setBeautyLevel:1];
    [_filter setBrightLevel:0.5];
    [_filter setToneLevel:1];
    self.filterView = [[GPUImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.filterView];
//    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [_filter addTarget:self.filterView];
    [_videoCamera addTarget:_filter];
    [self.videoCamera startCameraCapture];
    
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(16, 16+[UIDevice safeTopHeight], 24,24)];
    [backButton setImage:[UIImage imageNamed:@"captureBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton* cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width-40-16, 16+[UIDevice safeTopHeight], 40,24)];
    [cameraButton setImage:[UIImage imageNamed:@"captureCamera"] forState:UIControlStateNormal];
    cameraButton.tag = 1000;
    [self.view addSubview:cameraButton];
    [cameraButton addTarget:self action:@selector(cameraChange:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* recordButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width/2.0-50, self.view.height - 100 - [UIDevice safeBottomHeight], 100, 100)];
    recordButton.tag = 1000;
    [recordButton addTarget:self action:@selector(recordButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    recordButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:recordButton];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    
    
//    _captureSession = [[AVCaptureSession alloc]init];
//    if([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]){
//        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
//    }
//
//    AVCaptureDevice * captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
//    if(!captureDevice){
//        return;
//    }
//
//    AVCaptureDevice * audioCaputureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
//
//    NSError * error = nil;
//
//    _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
//    if(error){
//        return;
//    }
//
//    AVCaptureDeviceInput* audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaputureDevice error:&error];
//    if(error){
//        return;
//    }
//
//    _caputureMovieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
//
//    AVCaptureConnection* captureConnection = [_caputureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
//    if([captureConnection isVideoStabilizationSupported]){
//        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
//    }
//
//    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
//    captureConnection.videoScaleAndCropFactor = 1.0;
//
//    if([_captureSession canAddInput:_captureDeviceInput]){
//        [_captureSession addInput:_captureDeviceInput];
//        [_captureSession addInput:audioCaptureDeviceInput];
//    }
//
//    if([_captureSession canAddOutput:_caputureMovieFileOutput]){
//        [_captureSession addOutput:_caputureMovieFileOutput];
//    }
//
//    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
//    CALayer * layer = self.captureView.layer;
//    layer.masksToBounds = YES;
//    _captureVideoPreviewLayer.frame = layer.bounds;
//    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//
//    [layer addSublayer:_captureVideoPreviewLayer];
    
    
}

-(void)recordButtonClick:(UIButton*)sender{
    if(sender.tag ==1000){
        [self startVideoRecords];
        sender.tag = 2000;
    }else if(sender.tag == 2000){
        [self stopVideoRecords];
        sender.tag =1000;
    }
}

-(void)cameraChange:(UIButton*)sender{
    [self.videoCamera rotateCamera];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray* cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice * camera in cameras){
        if([camera position]==position){
            return camera;
        }
    }
    
    return nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.videoCamera startCameraCapture];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.videoCamera stopCameraCapture];
}

-(void)startVideoRecords{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Movie.mov"];
    unlink([filePath UTF8String]);
    self.movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:[NSURL fileURLWithPath:filePath] size:CGSizeMake(self.filterView.width, self.filterView.height)];
    self.movieWriter.encodingLiveVideo = YES;
    [_filter addTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = _movieWriter;
    [_movieWriter startRecording];
}

-(void)stopVideoRecords{
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecording];
}

-(void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

-(void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    
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
