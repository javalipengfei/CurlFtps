//
//  FtpBean.h
//  CURLFtps
//
//  Created by lee pengfei on 15/5/16.
//  Copyright (c) 2015年 WX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FtpBean : NSObject
@property(nonatomic,strong)NSString * urlStr;
@property(nonatomic,strong)NSString * userName;
@property(nonatomic,strong)NSString * passWord;
@property(nonatomic,assign)float progress;
@property(nonatomic,strong)NSString * localPath;
@end
