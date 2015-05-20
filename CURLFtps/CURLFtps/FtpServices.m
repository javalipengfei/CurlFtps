//
//  FtpServices.m
//  CURLFtps
//
//  Created by lee pengfei on 15/5/16.
//  Copyright (c) 2015年 WX. All rights reserved.
//





#import "FtpServices.h"


@implementation FtpServices


+ (FtpServices *)shareInstance
{
    static FtpServices * service;
    static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^{
        
        service = [[FtpServices alloc]init];
        
    });
    return service;
}

-(id)init{
    
    self=[super init];
    if (self) {
        
        ftpArray=[[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}



-(void)addFtpServiceWithURL:(NSString *)_url andUserName:(NSString *)_userName andPassWord:(NSString *)_passWord andLocalPath:(NSString *)path{
    
    FtpBean * bean=[[FtpBean alloc] init];
    bean.urlStr=_url;
    bean.userName=_userName;
    bean.passWord=_passWord;
    bean.localPath=path;
    FtpUploading * ftp=[[FtpUploading alloc] initUploadingWithBean:bean];
    ftp.delegate=self;
    [ftpArray addObject:ftp];
}




-(void)startUpload{
    
    if (ftpArray.count==0) {
        return;
    }
    upload=[ftpArray objectAtIndex:index];
    if (upload.state==FtpUploadingStateIdle||
        upload.state==FtpUploadingStateError) {
        
        [upload startUpload];
    }
}

-(void)startUploadWithIndex:(NSInteger)_index{
    
    if (_index>=ftpArray.count) {
        return;
    }
    index=_index;
    upload=[ftpArray objectAtIndex:index];
    if (upload.state==FtpUploadingStateIdle||
        upload.state==FtpUploadingStateError) {
        
        [upload startUpload];
    }
}

-(void)start{
    
    [upload start];
    
}

-(void)pause{
    
    
    [upload pause];
    
    
}



-(void)reStartUpload{
    
    [upload reStartUpload];
}

-(FtpUploadingState)upLoadStateWithIndex:(NSInteger)_index{
    
    if (_index>=ftpArray.count) {
        return 0;
    }
    
    FtpUploading * obj=[ftpArray objectAtIndex:_index];
    
    return obj.state;
}

-(FtpUploadingState)nowUploadState{
    
    
    if (ftpArray.count==0) {
        return 0;
    }
    
    FtpUploading * obj=[ftpArray objectAtIndex:index];
    
    return obj.state;
    
}


-(float)nowUploadProgress{
    
    if (index<ftpArray.count) {
    
        FtpUploading * obj=[ftpArray objectAtIndex:index];
        
        return obj.progress;
    }
    
    return 0.0;
    
}

-(float)upLoadProgressWithIndex:(NSInteger)_index{
    
    
    if (_index<ftpArray.count) {
        
        FtpUploading * obj=[ftpArray objectAtIndex:_index];
        
        return obj.progress;
    }
    
    return 0.0;
}

-(void)uploadProcgress:(float)progress{
    
    if ([self.delegate respondsToSelector:@selector(uploadProcgress:andIndex:)]) {
        
        [self.delegate uploadProcgress:progress andIndex:index];
    }
}

-(void)uploadStart:(FtpUploading *)ftpUploading{
    
    if ([self.delegate respondsToSelector:@selector(uploadStart: andIndex:)]) {
        
        [self.delegate uploadStart:self andIndex:index];
    }
}

-(void)uploadPause:(FtpUploading *)ftpUploading{
    
    if ([self.delegate respondsToSelector:@selector(uploadPause:andIndex:)]) {
        
        [self.delegate uploadPause:self andIndex:index];
    }
}

-(void)uploadFinsh:(FtpUploading *)ftpUploading{
    
    if ([self.delegate respondsToSelector:@selector(uploadFinsh:andIndex:)]) {
        
        [self.delegate uploadFinsh:self andIndex:index];
    }
    [ftpArray removeObjectAtIndex:index];
    if (ftpArray.count==0) {
        
        return;
    }
    if (index+1<=ftpArray.count) {
        ++index;
    }else{
        index=0;
    }
    [self startUploadWithIndex:index];
}

-(void)uploadError:(FtpUploading *)ftpUploading{
    
    if ([self.delegate respondsToSelector:@selector(uploadError:andIndex:)]) {
        
        [self.delegate uploadError:self andIndex:index];
    }
    
}


@end
