//
//  ViewController.m
//  openCV
//
//  Created by iuimini5 on 2015/3/25.
//  Copyright (c) 2015年 iuimini5. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>
#define CIRCLE_COLOR CV_RGB(255,0,0)
#define CIRCLE_SIZE 1

using namespace cv;
@interface ViewController ()

@end

@implementation ViewController
//AVCaptureSession *session;
//AVCaptureStillImageOutput *stillImageOutput;
@synthesize videoCamera;
@synthesize photoCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera =[[CvVideoCamera alloc]initWithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
//    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    
    
    
    self->HMinSlider.minimumValue = 0;
    self->HMinSlider.maximumValue = 180;
    HMinSlider.value = 10;
    self->HMaxSlider.minimumValue = 0;
    self->HMaxSlider.maximumValue = 180;
    HMaxSlider.value = 23;
    self->SMinSlider.minimumValue = 0;
    self->SMinSlider.maximumValue = 255;
    SMinSlider.value = 140;
    self->SMaxSlider.minimumValue = 0;
    self->SMaxSlider.maximumValue = 255;
    SMaxSlider.value = 255;
    self->VMinSlider.minimumValue = 0;
    self->VMinSlider.maximumValue = 255;
    VMinSlider.value = 180;//190
    self->VMaxSlider.minimumValue = 0;
    self->VMaxSlider.maximumValue = 255;
    VMaxSlider.value = 255;
}
-(void)viewWillAppear:(BOOL)animated{
    inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if ([videoCamera.captureSession canAddInput:deviceInput]){
        [videoCamera.captureSession addInput:deviceInput];
    }
    //    if ([inputDevice lockForConfiguration:&error])
    //    {
    //        //        if ([inputDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    //        //        {
    //        printf("%f\n",inputDevice.lensPosition);
    //        [inputDevice setFocusModeLockedWithLensPosition:1.0 completionHandler:nil];
    //        [inputDevice setFocusMode:AVCaptureFocusModeLocked];
    //        //        }
    //        [inputDevice unlockForConfiguration];
    //    }
    //    else{
    //        NSLog(@"%@",error);
    //    }
    //    photoCamera->stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    //    NSDictionary *outputSetting = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //    [stillImageOutput setOutputSettings:outputSetting];
    //    [session addOutput:stillImageOutput];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // defining variable
    CvMat cvimage=image;
    CvSize size = cvGetSize(&cvimage);
    CvScalar hsv_min = cvScalar(HMinSlider.value,SMinSlider.value,VMinSlider.value,0);//cvScalar(0~180,0~255,0~255) usng HSV  //lower bound
    CvScalar hsv_max = cvScalar(HMaxSlider.value,SMaxSlider.value,VMaxSlider.value,0);//upper bound
    CvPoint center;
    IplImage *hsv_frame = cvCreateImage(size, IPL_DEPTH_8U, 3); //create image storage to store HSV image
    IplImage*  thresholded   = cvCreateImage(size, IPL_DEPTH_8U, 1); //create image storage to thresholded image
    CvMemStorage* storage=cvCreateMemStorage(0); //circle storage
    
    
    cvCvtColor(&cvimage, hsv_frame, CV_BGR2HSV); //convert frame to HSV
    cvInRangeS(hsv_frame, hsv_min, hsv_max, thresholded); //thresholding HSV image in range hsv_min and hsv_max
    cvSmooth(thresholded, thresholded,CV_GAUSSIAN,15,15); //using Gaussian smooth
    if (RGBorHSV.selectedSegmentIndex==1) {
        cvCvtColor(thresholded, &cvimage, CV_GRAY2BGR);
    }
    else {
        CvSeq* circles= cvHoughCircles(thresholded, storage, CV_HOUGH_GRADIENT, 1.6, (thresholded->height)/4,100,40,8,120); //find circle
        
        float maxRadius=0;
        center.x=0;
        center.y=0;
        //find largest circle
        for (int i=0; i<circles->total; i++) {
            float* p = (float*)cvGetSeqElem(circles, i);
            //        printf("w=%d h=%d x=%f y=%f r=%f\n",size.width,size.height,p[0],p[1],p[2]);
            if (p[2]>maxRadius) {
                maxRadius=p[2];
                center.x=p[0];
                center.y=p[1];
            }
        }
        printf("w=%d h=%d x=%d y=%d r=%f t=%d\n",size.width,size.height,center.x,center.y,maxRadius,circles->total);
        cvCircle(&cvimage, center, 3, CIRCLE_COLOR); //draw circle point
        cvCircle(&cvimage, center, maxRadius, CIRCLE_COLOR, CIRCLE_SIZE); //draw circle
    }
    image = Mat(&cvimage); //shoe final frame
    
    // release memory space
    cvReleaseImage(&thresholded);
    cvReleaseImage(&hsv_frame);
    cvReleaseMemStorage(&storage);
    
    printf("%f %f\n",inputDevice.lensPosition,inputDevice.exposureTargetOffset);
}
#endif
- (void)dealloc
{
    videoCamera.delegate = nil;
}

- (IBAction)lock:(id)sender {
    [videoCamera lockBalance];
    [videoCamera lockExposure];
    
}

- (IBAction)cameraPositionAction:(id)sender {
    [self.videoCamera switchCameras];
    //    if (cameraPosition.selectedSegmentIndex == 0) {
    //
    //        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    //    }
    //    else {
    //        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    //    }
    //    [self.videoCamera stop];
    //    [self.videoCamera start];
}


- (IBAction)actionStart:(id)sender;
{
    NSError *error;
    [self.videoCamera start];
    if ([inputDevice lockForConfiguration:&error])
    {
        [inputDevice setFocusModeLockedWithLensPosition:1.0 completionHandler:nil];
    }
    [videoCamera lockFocus];
    
}

- (IBAction)actionStop:(id)sender {
    [self.videoCamera stop];
}

- (IBAction)HMinSlider:(UISlider *)sender {
    HMinLabel.text=[NSString stringWithFormat:@"H%d",(int)sender.value];
}

- (IBAction)HMaxAction:(UISlider *)sender {
    HMaxLabel.text=[NSString stringWithFormat:@"H%d",(int)sender.value];
}

- (IBAction)SMinAction:(UISlider *)sender {
    SMinLabel.text=[NSString stringWithFormat:@"S%d",(int)sender.value];
}

- (IBAction)SMaxAction:(UISlider *)sender {
    SMaxLabel.text=[NSString stringWithFormat:@"S%d",(int)sender.value];
}

- (IBAction)VMinAction:(UISlider *)sender {
    VMinLabel.text=[NSString stringWithFormat:@"V%d",(int)sender.value];
}

- (IBAction)VMaxAction:(UISlider *)sender {
    VMaxLabel.text=[NSString stringWithFormat:@"V%d",(int)sender.value];
}

- (IBAction)takePicture:(id)sender {
    [photoCamera takePicture];
    //    AVCaptureConnection *videoConnect = nil;
    //    for (AVCaptureConnection *connection in stillImageOutput.connections){
    //        for(AVCaptureInputPort *port in [connection inputPorts]){
    //            if([[port mediaType] isEqual:AVMediaTypeVideo]){
    //                videoConnect = connection;
    //                break;
    //            }
    //        }
    //        if(videoConnect){
    //            break;
    //        }
    //    }
    //    [photoCamera->stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnect completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    //        if (imageDataSampleBuffer != NULL) {
    //            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    //            UIImage *image = [UIImage imageWithData:imageData];
    //            pictureView.image = image;
    //        }
    //    }];
    
}

@end
