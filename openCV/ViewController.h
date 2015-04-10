//
//  ViewController.h
//  openCV
//
//  Created by iuimini5 on 2015/3/25.
//  Copyright (c) 2015年 iuimini5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import "openCV-Prefix.pch"
//#import <opencv2/core/core_c.h>
//#include <opencv2/highgui/highgui.hpp>
//#import <opencv2/opencv.hpp>
using namespace cv;
@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIButton *button;
    CvVideoCamera* videoCamera;
    CascadeClassifier faceCascade;
    __weak IBOutlet UISegmentedControl *cameraPosition;
    __weak IBOutlet UISlider *slider;
    __weak IBOutlet UILabel *label;
    
}

@property (nonatomic,retain) CvVideoCamera* videoCamera;
- (IBAction)cameraPositionAction:(id)sender;

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStop:(id)sender;
- (IBAction)slider:(UISlider *)sender;

@end

