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

@implementation ViewController{
    int iLastX ;
    int iLastY ;
    vector<cv::Vec4i> lines;
    vector<cv::Point2f> corners;
}
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
    HMinSlider.value = 0;
    self->HMaxSlider.minimumValue = 0;
    self->HMaxSlider.maximumValue = 180;
    HMaxSlider.value = 10;
    self->SMinSlider.minimumValue = 0;
    self->SMinSlider.maximumValue = 255;
    SMinSlider.value = 124;
    self->SMaxSlider.minimumValue = 0;
    self->SMaxSlider.maximumValue = 255;
    SMaxSlider.value = 255;
    self->VMinSlider.minimumValue = 0;
    self->VMinSlider.maximumValue = 255;
    VMinSlider.value = 210;//190
    self->VMaxSlider.minimumValue = 0;
    self->VMaxSlider.maximumValue = 255;
    VMaxSlider.value = 255;
    
    iLastX = -1;
    iLastY = -1;
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
    
    CvMoments oMoments;
    Size2i sizeErode = Size2i(5,5);
    // defining variable
    CvMat cvimage=image;
    CvSize size = cvGetSize(&cvimage);
    CvScalar hsv_min = cvScalar(HMinSlider.value,SMinSlider.value,VMinSlider.value,0);//cvScalar(0~180,0~255,0~255) usng HSV  //lower bound
    CvScalar hsv_max = cvScalar(HMaxSlider.value,SMaxSlider.value,VMaxSlider.value,0);//upper bound
    CvScalar hsv_min2 = cvScalar(88,47,74,0);
    CvScalar hsv_max2 = cvScalar(102,255,255,0);
    CvPoint center;
    IplImage *hsv_frame = cvCreateImage(size, IPL_DEPTH_8U, 3); //create image storage to store HSV image
    IplImage*  thresholded   = cvCreateImage(size, IPL_DEPTH_8U, 1); //create image storage to thresholded image
    IplImage* thresholded2 = cvCreateImage(size, IPL_DEPTH_8U, 1);
    CvMemStorage* storage=cvCreateMemStorage(0); //circle storage
    
    cvSmooth(&cvimage, &cvimage,CV_GAUSSIAN,5,5);
    cvCvtColor(&cvimage, hsv_frame, CV_BGR2HSV); //convert frame to HSV
    cvInRangeS(hsv_frame, hsv_min, hsv_max, thresholded); //thresholding HSV image in range hsv_min and hsv_max
//    cvInRangeS(hsv_frame, hsv_min2, hsv_max2, thresholded2);
//    cvOr(thresholded, thresholded2, thresholded);
    cvSmooth(thresholded, thresholded,CV_GAUSSIAN,15,15); //using Gaussian smooth
    // >>>>> Improving the result
    cvErode(thresholded,thresholded);
    cvDilate(thresholded, thresholded);
    // <<<<< Improving the result
    if (RGBorHSV.selectedSegmentIndex==1) {
        cvCvtColor(thresholded, &cvimage, CV_GRAY2BGR);
    }
    else {
        
        cvMoments(thresholded, &oMoments);
        double dM01 = oMoments.m01;
        double dM10 = oMoments.m10;
        double dArea = oMoments.m00;
        // if the area <= 10000, I consider that the there are no object in the image and it's because of the noise, the area is not zero
        if (dArea > 10000)
        {
            //calculate the position of the ball
            int posX = dM10 / dArea;
            int posY = dM01 / dArea;
            
            if (iLastX >= 0 && iLastY >= 0 && posX >= 0 && posY >= 0)
            {
                //Draw a red line from the previous point to the current point
                cvLine(&cvimage, cvPoint(posX, posY), cvPoint(iLastX, iLastY), Scalar(0,0,255), 2);
            }
            
            iLastX = posX;
            iLastY = posY;
        }
        
        CvSeq* rectangles = cvHoughLines2(thresholded, &(lines), 1, CV_PI/180, 70, 30);
        for (int i = 0; i < lines.size(); i++)
        {
            cv::Vec4i v = lines[i];
            lines[i][0] = 0;
            lines[i][1] = ((float)v[1] - v[3]) / (v[0] - v[2]) * -v[0] + v[1];
            lines[i][2] = cvimage.cols;
            lines[i][3] = ((float)v[1] - v[3]) / (v[0] - v[2]) * (cvimage.cols - v[2]) + v[3];
        }
        
        for (int i = 0; i < lines.size(); i++)
        {
            for (int j = i+1; j < lines.size(); j++)
            {
                cv::Point2f pt = computeIntersect(lines[i], lines[j]);
                if (pt.x >= 0 && pt.y >= 0)
                    corners.push_back(pt);
            }
        }
        //        CvSeq* circles= cvHoughCircles(thresholded, storage, CV_HOUGH_GRADIENT, 1.6, (thresholded->height)/4,100,40,8,120); //find circle
//        
//        float maxRadius=0;
//        center.x=0;
//        center.y=0;
//        //find largest circle
//        for (int i=0; i<circles->total; i++) {
//            float* p = (float*)cvGetSeqElem(circles, i);
//            //        printf("w=%d h=%d x=%f y=%f r=%f\n",size.width,size.height,p[0],p[1],p[2]);
//            if (p[2]>maxRadius) {
//                maxRadius=p[2];
//                center.x=p[0];
//                center.y=p[1];
//            }
//        }
//        printf("w=%d h=%d x=%d y=%d r=%f t=%d\n",size.width,size.height,center.x,center.y,maxRadius,circles->total);
//        cvCircle(&cvimage, center, 3, CIRCLE_COLOR); //draw circle point
//        cvCircle(&cvimage, center, maxRadius, CIRCLE_COLOR, CIRCLE_SIZE); //draw circle
    }
    image = Mat(&cvimage); //show final frame
    
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
//- (Point2f)computeIntersect:(cv::Vec4i) a withParam:(cv::Vec4i) b
Point2f computeIntersect(cv::Vec4i a,cv::Vec4i b){
    int x1 = a[0], y1 = a[1], x2 = a[2], y2 = a[3], x3 = b[0], y3 = b[1], x4 = b[2], y4 = b[3];
    float denom;
    
    if (float d = ((float)(x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4)))
    {
        cv::Point2f pt;
        pt.x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d;
        pt.y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / d;
        return pt;
    }
    else
        return cv::Point2f(-1, -1);
}
@end
