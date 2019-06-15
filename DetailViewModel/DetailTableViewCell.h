//
//  DetailTableViewCell.h
//  FeedsAPP
//
//  Created by student11 on 2019/6/1.
//  Copyright © 2019 iosGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZanButton.h"
#import "DetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailTableViewCell : UITableViewCell

//用户名
@property(nonatomic,retain) UILabel *name;
//发布时间
@property(nonatomic,retain) UILabel *posttime;
//用户头像
@property(nonatomic,retain) UIImageView *userImage;
//文本内容
@property(nonatomic,retain) UILabel *content;
//点赞按钮
@property(nonatomic,strong) ZanButton *zangBtn;
//点赞特效
@property(nonatomic,strong) UIImageView *zangPlusImg;
//数据模型
@property(nonatomic,strong) DetailViewModel *model;

//给用户介绍赋值并且实现自动换行
-(void)setIntroductionText:(NSString*)text;
//初始化cell类
-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
