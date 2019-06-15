//
//  PicOnRightModel.h
//  FeedsAPP
//
//  Created by Yueyue on 2019/5/22.
//  Copyright © 2019 iosGroup. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewModel : NSObject

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,assign) int likeNum;
@property (nonatomic,copy) NSString *mainText;
@property (nonatomic,copy) NSString *time;

//自定义构造方法
-(id) initWithDict:(NSDictionary *)dict;
-(id) initWithStr:(NSString *)mytitle;

//类方法（规范）
+(id) newsWithDict:(NSDictionary *)dict;
+(id) newsWithStr:(NSString *)mytitle;

@end

NS_ASSUME_NONNULL_END
