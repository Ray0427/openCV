//
//  ViewController.m
//  openCV
//
//  Created by iuimini5 on 2015/3/25.
//  Copyright (c) 2015年 iuimini5. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define CIRCLE_COLOR CV_RGB(255,0,0)
#define CIRCLE_SIZE 1
static void *FocusModeContext = &FocusModeContext;
using namespace cv;
@interface ViewController ()

@end

@implementation ViewController

@synthesize videoCamera;
- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    NSError *error = nil;
    AVCaptureDevice *videoDevice = [ViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];    // Do any additional setup after loading the view, typically from a nib.
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    [[self session] beginConfiguration];
    
    if ([session canAddInput:videoDeviceInput])
    {
        [session addInput:videoDeviceInput];
        
        [self setVideoDevice:videoDeviceInput.device];
        
            }

    self.videoDevice.focusMode = (AVCaptureFocusMode) 1;
    self.videoCamera =[[CvVideoCamera alloc]initWithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
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
    VMinSlider.value = 190;
    self->VMaxSlider.minimumValue = 0;
    self->VMaxSlider.maximumValue = 255;
    VMaxSlider.value = 255;
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
    cvSmooth(thresholded, thresholded,CV_GAUSSIAN,9,9); //using Gaussian smooth
    CvSeq* circles= cvHoughCircles(thresholded, storage, CV_HOUGH_GRADIENT, 2, (thresholded->height)/4,100,40,8,120); //find circle
    
    float maxRadius=0;
    //find largest circle
    for (int i=0; i<circles->total; i++) {
        float* p = (float*)cvGetSeqElem(circles, i);
        printf("w=%d h=%d x=%f y=%f r=%f\n",size.width,size.height,p[0],p[1],p[2]);
        if (p[2]>maxRadius) {
            maxRadius=p[2];
            center.x=p[0];
            center.y=p[1];
        }
    }
    cvCircle(&cvimage, center, 3, CIRCLE_COLOR); //draw circle point
    cvCircle(&cvimage, center, maxRadius, CIRCLE_COLOR, CIRCLE_SIZE); //draw circle
    
    if (RGBorHSV.selectedSegmentIndex==1) {
        image = Mat(thresholded); //show HSV frame
    }
    else {
        image = Mat(&cvimage); //shoe final frame
        cvReleaseImage(&thresholded);
    }
    // release memory space
    cvReleaseImage(&hsv_frame);
    cvReleaseMemStorage(&storage);
}
#endif



- (IBAction)cameraPositionAction:(id)sender {
    if (cameraPosition.selectedSegmentIndex == 0) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    }
    [self.videoCamera stop];
    [self.videoCamera start];
}

- (IBAction)changeFocusMode:(id)sender {
    UISegmentedControl *control = sender;
    AVCaptureFocusMode mode = (AVCaptureFocusMode)[self.focusModes[control.selectedSegmentIndex] intValue];
    NSError *error = nil;
    
    if ([self.videoDevice lockForConfiguration:&error])
    {
        if ([self.videoDevice isFocusModeSupported:mode])
        {
            self.videoDevice.focusMode = mode;
        }
        else
        {
            NSLog(@"Focus mode %@ is not supported. Focus mode is %@.", [self stringFromFocusMode:mode], [self stringFromFocusMode:self.videoDevice.focusMode]);
            self->focusModeControl.selectedSegmentIndex = [self.focusModes indexOfObject:@(self.videoDevice.focusMode)];
        }
        [self.videoDevice unlockForConfiguration];
    }
    else
    {
        NSLog(@"%@", error);
    }}


- (IBAction)actionStart:(id)sender;
{
    [self.videoCamera start];
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
#pragma mark Utilities

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}
- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            [self setDeviceAuthorized:YES];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCamManual"
                                            message:@"AVCamManual doesn't have permission to use the Camera"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}
- (NSString *)stringFromFocusMode:(AVCaptureFocusMode) focusMode
{
    NSString *string = @"INVALID FOCUS MODE";
    
    if (focusMode == AVCaptureFocusModeLocked)
    {
        string = @"Locked";
    }
    else if (focusMode == AVCaptureFocusModeAutoFocus)
    {
        string = @"Auto";
    }
    else if (focusMode == AVCaptureFocusModeContinuousAutoFocus)
    {
        string = @"ContinuousAuto";
    }
    
    return string;
}

@end
