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
    self->slider.maximumValue = 255;
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
    CvSize size = cvGetSize(&cvimage);
    CvScalar hsv_min = cvScalar(0,170,210,0);//cvScalar(0,100,220,0);
    CvScalar hsv_max = cvScalar(20,210,255,0);//cvScalar(40,170,255,0);
    CvScalar hsv_min2 = cvScalar(150, 200, 200);
    CvScalar hsv_max2 = cvScalar(200, 255, 256);
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
    cvInRangeS(hsv_frame, hsv_min2, hsv_max2, thresholded2);
//    cvOr(thresholded, thresholded2, thresholded);
//    image= Mat(thresholded);
    //equalizeHist(grayScaleFrame, grayScaleFrame);
    //IplImage tmp=IplImage(thresholded);
//    IplImage tmp2=IplImage(thresholded2);
    cvSmooth(thresholded, thresholded,CV_GAUSSIAN, 9, 9);
    CvSeq* circles= cvHoughCircles(thresholded, storage, CV_HOUGH_GRADIENT, 2, (thresholded->height)/4,100,40,8,100);
    float maxRadius=0;
    for (int i=0; i<circles->total; i++) {
        float* p = (float*)cvGetSeqElem(circles, i);
        printf("w=%d h=%d x=%f y=%f r=%f\n",size.width,size.height,p[0],p[1],p[2]);
        if (p[2]>maxRadius) {
            maxRadius=p[2];
            center.x=p[0];
            center.y=p[1];
            cvCircle(&cvimage, center, 3, CIRCLE_COLOR);
            cvCircle(&cvimage, center, p[2], CIRCLE_COLOR, CIRCLE_SIZE);
        }
        
        
//        cvCircle(thresholded, center, 3, CV_RGB(0, 255, 0));
//        cvCircle(thresholded, center, p[2], CV_RGB(255, 255, 0));
        
    }
    
//    Vec3f color= image.at<Vec3f>(0,0);
//    printf("R=%u G=%u B=%f\n",color.val[0],color.val[1],color.val[2]);
    
    image = Mat(&cvimage);
    
    cvReleaseMemStorage(&storage);
    cvReleaseImage(&hsv_frame);
    cvReleaseImage(&thresholded);
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
    label.text=[NSString stringWithFormat:@"%d",(int)sender.value];
}


@end
