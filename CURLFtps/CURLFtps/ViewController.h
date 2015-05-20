//
//  ViewController.h
//  CURLFtps
//
//  Created by lee pengfei on 15/5/16.
//  Copyright (c) 2015年 WX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FtpServices.h"
@interface ViewController : UIViewController<FtpServiceDelegate>{
    
    FtpServices * service;
    UIProgressView * progressView;
}


@end

