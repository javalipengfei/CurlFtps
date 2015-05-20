//
//  ViewController.m
//  CURLFtps
//
//  Created by lee pengfei on 15/5/16.
//  Copyright (c) 2015年 WX. All rights reserved.
//

#import "ViewController.h"
#define Host @""
#define USERNAME @""
#define PASSWORD @""
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    service=[FtpServices shareInstance];
    service.delegate=self;
    [self.progress setProgress:0];
    NSString * path=[[NSBundle mainBundle] pathForResource:@"iosTest" ofType:@"flv"];
    NSLog(@"%@",path);
    [service addFtpServiceWithURL:Host andUserName:USERNAME andPassWord:PASSWORD andLocalPath:path];
   
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)startAction:(id)sender {
    
    [service startUpload];
}
- (IBAction)pauseAction:(id)sender {
    
    [service pause];
}
- (IBAction)restartAction:(id)sender {
    
    [service start];
    
}

-(void)uploadProcgress:(float)loadProgress andIndex:(NSInteger)index{
    
    
    [self.progress setProgress:loadProgress];

}
- (IBAction)newStartAction:(id)sender {
    
    [service reStartUpload];
}

-(void)uploadStart:(FtpServices *)ftpService andIndex:(NSInteger)index{
    
    NSLog(@"上传开始");
    
}

-(void)uploadFinsh:(FtpServices *)ftpService  andIndex:(NSInteger)index{
    
    NSLog(@"上传完成");
}

-(void)uploadError:(FtpServices *)ftpService  andIndex:(NSInteger)index{
    
    NSLog(@"上传错误");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
