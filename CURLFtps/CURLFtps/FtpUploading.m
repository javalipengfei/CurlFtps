//
//  FtpUploading.m
//  CURLFtps
//
//  Created by lee pengfei on 15/5/18.
//  Copyright (c) 2015年 WX. All rights reserved.
//

#import "FtpUploading.h"


int ftpSerciceDebugCallback(CURL *curl, curl_infotype infotype, char *info, size_t infoLen, void *contextInfo)
{
    FtpUploading *vc = (__bridge FtpUploading *)contextInfo;
    NSData *infoData = [NSData dataWithBytes:info length:infoLen];
    NSString *infoStr = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    
    if (infoStr)
    {
        infoStr = [infoStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];	// convert Windows CR/LF to just LF
        infoStr = [infoStr stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];	// convert remaining CRs to LFs
        switch (infotype)
        {
            case CURLINFO_DATA_IN:
                //NSLog(@"%@",infoStr);
                [vc logWithNSString:infoStr];
                break;
            case CURLINFO_DATA_OUT:
                //NSLog(@"%@",infoStr);
                [vc logWithNSString:[infoStr stringByAppendingString:@"\n"]];
                break;
            case CURLINFO_HEADER_IN:
                //NSLog(@"%@",infoStr);
                [vc logWithNSString:[@"< " stringByAppendingString:infoStr]];
                break;
            case CURLINFO_HEADER_OUT:
                infoStr = [infoStr stringByReplacingOccurrencesOfString:@"\n" withString:@"\n> "];	// start each line with a /
                //NSLog(@"%@",infoStr);
                [vc logWithNSString:[NSString stringWithFormat:@"> %@\n", infoStr]];
                break;
            case CURLINFO_TEXT:
                [vc logWithNSString:[@"* " stringByAppendingString:infoStr]];
                //NSLog(@"%@",infoStr);
                break;
            default:	// ignore the other CURLINFOs
                break;
        }
    }
    return 0;
}

static size_t ftpServiceRead_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
    curl_off_t nread;
    /* in real-world cases, this would probably get this data differently
     as this fread() stuff is exactly what the library already would do
     by default internally */
    size_t retcode = fread(ptr, size, nmemb, stream);
    
    nread = (curl_off_t)retcode;
    //fprintf(stderr, "*** We read %" CURL_FORMAT_CURL_OFF_T
    //      " bytes from file\n", nread);
    
    return retcode;
}


int ftpServiceProcress(void* ptr, double TotalToDownload, double NowDownloaded,
                       double TotalToUpload, double NowUploaded)
{
    /*  printf("%d / %d (%g %%)\n", d, t, d*100.0/t);*/
    // NSLog(@"%f and %f ",TotalToUpload,NowUploaded);
    // NSLog(@"%f",NowUploaded/TotalToUpload);
    FtpUploading * ftp=(__bridge FtpUploading *)ptr;
    
    [ftp setProgress:NowUploaded/TotalToUpload];
    return 0;
}


@implementation FtpUploading

-(id)initUploadingWithBean:(FtpBean *)_bean{
    
    self=[super init];
    if (self) {
        bean=_bean;
         curl_global_init(CURL_GLOBAL_ALL);
    }
    return self;
    
}

-(void)logWithNSString:(NSString *)str{
    
    NSLog(@"%@",str);
}


-(void)startUploadWithThread{
    
    if (bean==nil) {
        return;
    }
    NSString * urlStr=bean.urlStr;
    NSString * userName=bean.userName;
    NSString * passWord=bean.passWord;
    NSString * localPath=bean.localPath;
    if (urlStr && ![urlStr isEqualToString:@""]){
        
        //        CURLcode res;
        FILE *hd_src;
        curl_off_t fsize;
        
        
        static const char * buf_1 = "RNFR " ;//UPLOAD_FILE_AS;
        static const char * buf_2 = "RNTO " ;//RENAME_FILE_TO;
        
        NSData * data=[NSData dataWithContentsOfFile:localPath];
        fsize = (curl_off_t)data.length;
        filesize=fsize;
        hd_src = fopen([localPath UTF8String], "rb");
        /* get a curl handle */
        
        CURLcode theResult;
        NSURL *url = [NSURL URLWithString:urlStr];
        if (_headers)
        {
            curl_slist_free_all(_headers);
            _headers = NULL;
        }
        
        curl = curl_easy_init();
        
        if(curl) {
            /* build a list of commands to pass to libcurl */
            _headers = curl_slist_append(_headers, buf_1);
            _headers = curl_slist_append(_headers, buf_2);
            
            
            /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
            // Some settings I recommend you always set:
            // set a default user agent
            
            // Things specific to this app:
            curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);	// turn on verbose logging; your app doesn't need to do this except when debugging a connection
            curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_ALL);
            curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, ftpSerciceDebugCallback);
            curl_easy_setopt(curl, CURLOPT_DEBUGDATA, self);
            
            /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
            
            curl_easy_setopt(curl, CURLOPT_URL, url.absoluteString.UTF8String);
            
            // little warning: curl_easy_setopt() doesn't retain the memory passed into it, so if the memory used by calling url.absoluteString.UTF8String is freed before curl_easy_perform() is called, then it will crash. IOW, don't drain the autorelease pool before making the call
            curl_easy_setopt(curl, CURLOPT_USERNAME, userName ? userName.UTF8String : "");
            curl_easy_setopt(curl, CURLOPT_PASSWORD, passWord ?passWord.UTF8String : "");
            
            curl_easy_setopt(curl, CURLOPT_READFUNCTION, ftpServiceRead_callback);
            curl_easy_setopt(curl, CURLOPT_READDATA, self);
            
            //设置短点续传
            //curl_easy_setopt(curl, CURLOPT_RESUME_FROM_LARGE, fsize);
            
            /* enable uploading */
            curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
            
            curl_easy_setopt(curl, CURLOPT_NOPROGRESS, FALSE);
            
            curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, ftpServiceProcress);
            
            curl_easy_setopt(curl, CURLOPT_PROGRESSDATA,self);
            
            //curl_easy_setopt(_curl,CURLOPT_URL, [@"test.png" UTF8String]);
            
            /* specify target */
            // curl_easy_setopt(_curl,CURLOPT_URL, [@"test.png" UTF8String] );
            
            
            /* pass in that last of FTP commands to run after the transfer */
            //curl_easy_setopt(curl, CURLOPT_POSTQUOTE, _headers);
            
            /* now specify which file to upload */
            curl_easy_setopt(curl, CURLOPT_READDATA, hd_src);
            
            /* Set the size of the file to upload (optional).  If you give a *_LARGE
             option you MUST make sure that the type of the passed-in argument is a
             curl_off_t. If you use CURLOPT_INFILESIZE (without _LARGE) you must
             make sure that to pass in a type 'long' argument. */
            curl_easy_setopt(curl, CURLOPT_INFILESIZE_LARGE,
                             (curl_off_t)fsize);
            
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER,0L );
            
            self.state=FtpUploadingStateStart;
            //_resultTxt.text = @"";
            theResult = curl_easy_perform(curl);
            
            
            
            
            if (theResult == CURLE_OK){
                
                self.state=FtpUploadingStateFinsh;
                NSLog(@"操作完成 上传成功");
            }
            
            else{
                self.state=FtpUploadingStateError;
                NSLog(@"操作完成 上传失败");
            }
            
        }
        fclose(hd_src); /* close the local file */
        //        NSLog(@"<<<<<<<<<>>>>>>>>>%@",curl);
        curl_easy_cleanup(curl);
        
        curl_global_cleanup();
        
    }
}

-(void)startUpload{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // something
        [self startUploadWithThread];
    });
    
    
    
    
}

-(void)start{
    if (curl!=nil) {
        self.state=FtpUploadingStateUploading;
        curl_easy_pause(curl, CURLPAUSE_SEND_CONT);
    }
    
}

-(void)pause{
    
    if (curl!=nil) {
        self.state=FtpUploadingStatePause;
        curl_easy_pause(curl, CURLPAUSE_SEND);
    }
    
    
}



-(void)reStartUpload{
    
    if (self.state!=FtpUploadingStateIdle||
        self.state!=FtpUploadingStateError) {
        
        
        [self pause];
        //        curl_easy_cleanup(curl);
        curl_easy_reset(curl);
    }
    [self startUpload];
}
-(void)setProgress:(float)progress{
    
    _progress=progress;
    __weak FtpUploading * weakSelf=self;
    NSLog(@"progress %f",progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([weakSelf.delegate respondsToSelector:@selector(uploadProcgress:)]) {
            if (!isnan(progress)) {
                
                [weakSelf.delegate uploadProcgress:progress];
            }
            
        }
    });
    
    
}


-(void)setState:(FtpUploadingState)state{
    
    _state=state;
    
    switch (state) {
        case FtpUploadingStateStart:
            if ([self.delegate respondsToSelector:@selector(uploadStart:)]) {
                
                [self.delegate uploadStart:self];
            }
            break;
            
        case FtpUploadingStatePause:
            
            if ([self.delegate respondsToSelector:@selector(uploadPause:)]) {
                
                [self.delegate uploadPause:self];
            }
            
            break;
        case FtpUploadingStateFinsh:
            
            if ([self.delegate respondsToSelector:@selector(uploadFinsh:)]) {
                
                [self.delegate uploadFinsh:self];
            }
            
            break;
            
        case FtpUploadingStateError:
            
            if ([self.delegate respondsToSelector:@selector(uploadError:)]) {
                
                [self.delegate uploadError:self];
            }
            
            break;
            
        default:
            break;
    }
    
    
}



@end
