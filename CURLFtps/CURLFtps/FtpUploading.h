//
//  FtpUploading.h
//  CURLFtps
//
//  Created by lee pengfei on 15/5/18.
//  Copyright (c) 2015年 WX. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "curl.h"
#import "FtpBean.h"

@protocol FtpUploadingDelegate;

typedef NS_ENUM(NSInteger, FtpUploadingState) {
    FtpUploadingStateIdle,
    FtpUploadingStateStart,
    FtpUploadingStateUploading,
    FtpUploadingStatePause,
    FtpUploadingStateFinsh,
    FtpUploadingStateError
};

@interface FtpUploading : NSObject{
    
    CURL * curl;
    curl_off_t filesize;
    struct curl_slist *_headers;
    FtpBean * bean;
    
}
@property(nonatomic,assign)float progress;
@property(nonatomic,weak)id<FtpUploadingDelegate> delegate;
@property(nonatomic,assign)FtpUploadingState state;
-(id)initUploadingWithBean:(FtpBean *)bean;

-(void)logWithNSString:(NSString *)str;

-(void)setProgress:(float)progress;


-(void)startUpload;

-(void)pause;

-(void)start;

-(void)reStartUpload;

@end

@protocol FtpUploadingDelegate <NSObject>

-(void)uploadProcgress:(float)progress;

-(void)uploadStart:(FtpUploading *)ftpUploading;

-(void)uploadPause:(FtpUploading *)ftpUploading;

-(void)uploadFinsh:(FtpUploading *)ftpUploading;

-(void)uploadError:(FtpUploading *)ftpUploading;

@end

