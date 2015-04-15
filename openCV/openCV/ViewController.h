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
    __weak IBOutlet UISegmentedControl *RGBorHSV;
    __weak IBOutlet UISlider *slider;
    __weak IBOutlet UILabel *label;
    __weak IBOutlet UISlider *HMaxSlider;
    __weak IBOutlet UILabel *HMaxLabel;
    __weak IBOutlet UISlider *SMinSlider;
    __weak IBOutlet UILabel *SMinLabel;
    __weak IBOutlet UISlider *SMaxSlider;
    __weak IBOutlet UILabel *SMaxLabel;
    __weak IBOutlet UISlider *VMinSlider;
    __weak IBOutlet UILabel *VMinLabel;
    __weak IBOutlet UISlider *VMaxSlider;
    __weak IBOutlet UILabel *VMaxLabel;
    
}

@property (nonatomic,retain) CvVideoCamera* videoCamera;

- (IBAction)cameraPositionAction:(id)sender;

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStop:(id)sender;
- (IBAction)slider:(UISlider *)sender;
- (IBAction)HMaxAction:(UISlider *)sender;
- (IBAction)SMinAction:(UISlider *)sender;
- (IBAction)SMaxAction:(UISlider *)sender;
- (IBAction)VMinAction:(UISlider *)sender;
- (IBAction)VMaxAction:(UISlider *)sender;


@end

