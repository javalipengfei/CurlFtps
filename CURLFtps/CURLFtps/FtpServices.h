//
//  FtpServices.h
//  CURLFtps
//
//  Created by lee pengfei on 15/5/16.
//  Copyright (c) 2015年 WX. All rights reserved.
//




#import <Foundation/Foundation.h>
#include "curl.h"
#import "FtpBean.h"
#import "FtpUploading.h"
@protocol FtpServiceDelegate;

@interface FtpServices : NSObject<FtpUploadingDelegate>{
    
    NSMutableArray * ftpArray;
    
    CURL * curl;
    curl_off_t filesize;
    struct curl_slist *_headers;
    FtpUploading * upload;
    NSInteger index;
    BOOL isUploading;
}
@property(nonatomic,weak)id<FtpServiceDelegate> delegate;


+ (FtpServices *)shareInstance;


-(void)addFtpServiceWithURL:(NSString *)url andUserName:(NSString *)userName andPassWord:(NSString *)passWord andLocalPath:(NSString *)path;

//开始上传
-(void)startUpload;
//暂停
-(void)pause;
//相对于暂停 开始
-(void)start;
//重新上传
-(void)reStartUpload;

-(FtpUploadingState)nowUploadState;

-(FtpUploadingState)upLoadStateWithIndex:(NSInteger)_index;

-(float)nowUploadProgress;

-(float)upLoadProgressWithIndex:(NSInteger)_index;

@end

@protocol FtpServiceDelegate <NSObject>

-(void)uploadProcgress:(float)progress andIndex:(NSInteger)index;

-(void)uploadStart:(FtpServices *)ftpService andIndex:(NSInteger)index;

-(void)uploadPause:(FtpServices *)ftpService andIndex:(NSInteger)index;

-(void)uploadFinsh:(FtpServices *)ftpService andIndex:(NSInteger)index;

-(void)uploadError:(FtpServices *)ftpService andIndex:(NSInteger)index;

@end