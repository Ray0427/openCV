//
//  ViewController.m
//  openCV
//
//  Created by iuimini5 on 2015/3/25.
//  Copyright (c) 2015年 iuimini5. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/opencv.hpp>
#define CIRCLE_COLOR CV_RGB(255,0,0)
#define CIRCLE_SIZE 1
using namespace cv;
//NSString* const faceCascadeFilename = @"haarcascade_frontalface_alt2"; //
//const int HaarOptions =CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH; //
@interface ViewController ()

@end

@implementation ViewController

@synthesize videoCamera;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.videoCamera =[[CvVideoCamera alloc]initWithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    self->slider.minimumValue = 0;
    self->slider.maximumValue = 180;
    slider.value = 13;
    self->HMaxSlider.minimumValue = 0;
    self->HMaxSlider.maximumValue = 180;
    HMaxSlider.value = 23;
    self->SMinSlider.minimumValue = 0;
    self->SMinSlider.maximumValue = 255;
    SMinSlider.value = 110;
    self->SMaxSlider.minimumValue = 0;
    self->SMaxSlider.maximumValue = 255;
    SMaxSlider.value = 255;
    self->VMinSlider.minimumValue = 0;
    self->VMinSlider.maximumValue = 255;
    VMinSlider.value = 160;
    self->VMaxSlider.minimumValue = 0;
    self->VMaxSlider.maximumValue = 255;
    VMaxSlider.value = 255;
//    NSString* faceCascadePath = [[NSBundle mainBundle] pathForResource:faceCascadeFilename ofType:@"xml"];//
//    faceCascade.load([faceCascadePath UTF8String]);//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    
    CvMat cvimage=image;
    Mat cvHSV=image;
    CvSize size = cvGetSize(&cvimage);
    CvScalar hsv_min = cvScalar(slider.value,SMinSlider.value,VMinSlider.value,0);//cvScalar(0~180,0~255,0~255) usng HSV
    CvScalar hsv_max = cvScalar(HMaxSlider.value,SMaxSlider.value,VMaxSlider.value,0);
//    CvScalar hsv_min = cvScalar(15,150,180,0);
//    CvScalar hsv_max =cvScalar(23,255,255,0);
//    CvScalar hsv_min2 = cvScalar(150, 200, 200);
//    CvScalar hsv_max2 = cvScalar(200, 255, 256);
    CvPoint center;
    IplImage *hsv_frame = cvCreateImage(size, IPL_DEPTH_8U, 3);;
    
    IplImage*  thresholded   = cvCreateImage(size, IPL_DEPTH_8U, 1);
    IplImage*  thresholded2   = cvCreateImage(size, IPL_DEPTH_8U, 1);
    CvMemStorage* storage=cvCreateMemStorage(0);
    
//    while (1) {
//        IplImage* frame =cvQueryFrame(capture);
//    }
    // Do some OpenCV stuff with the image
    
    //IplImage *frame= cvCreateImage(cvGetSize(cvimage), 8, 1);
    cvCvtColor(&cvimage, hsv_frame, CV_BGR2HSV);
//    thresholded = hsv_frame;
    //inRange(hsv_frame, hsv_min, hsv_max, thresholded);
    cvInRangeS(hsv_frame, hsv_min, hsv_max, thresholded);
//    cvInRangeS(hsv_frame, hsv_min2, hsv_max2, thresholded2);
//    cvOr(thresholded, thresholded2, thresholded);
//    image= Mat(thresholded);
    //equalizeHist(grayScaleFrame, grayScaleFrame);
    //IplImage tmp=IplImage(thresholded);
//    IplImage tmp2=IplImage(thresholded2);
//    cvHSV=Mat(thresholded);
    cvSmooth(thresholded, thresholded,CV_GAUSSIAN,9,9);
    CvSeq* circles= cvHoughCircles(thresholded, storage, CV_HOUGH_GRADIENT, 2, (thresholded->height)/4,100,40,8,120);
    float maxRadius=0;
    for (int i=0; i<circles->total; i++) {
        float* p = (float*)cvGetSeqElem(circles, i);
        printf("w=%d h=%d x=%f y=%f r=%f\n",size.width,size.height,p[0],p[1],p[2]);
        if (p[2]>maxRadius) {
            maxRadius=p[2];
            center.x=p[0];
            center.y=p[1];
//            cvCircle(&cvimage, center, 3, CIRCLE_COLOR);
//            cvCircle(&cvimage, center, p[2], CIRCLE_COLOR, CIRCLE_SIZE);
        }
    }
    cvCircle(&cvimage, center, 3, CIRCLE_COLOR);
    cvCircle(&cvimage, center, maxRadius, CIRCLE_COLOR, CIRCLE_SIZE);
//    Vec3f color= image.at<Vec3f>(0,0);
//    printf("R=%u G=%u B=%f\n",color.val[0],color.val[1],color.val[2]);
//    IplImage temp = *thresholded;
    if (RGBorHSV.selectedSegmentIndex==1) {
        
        image = Mat(thresholded);
    }
    else {
        image = Mat(&cvimage);
        cvReleaseImage(&thresholded);
    }
    cvReleaseImage(&hsv_frame);
    
    
    
    cvReleaseMemStorage(&storage);
    cvReleaseImage(&thresholded2);
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


- (IBAction)actionStart:(id)sender;
{
    [self.videoCamera start];
}

- (IBAction)actionStop:(id)sender {
    [self.videoCamera stop];
}

- (IBAction)slider:(UISlider *)sender {
    label.text=[NSString stringWithFormat:@"H%d",(int)sender.value];
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




@end
