//
//  RootViewController.m
//  YYClipImage
//
//  Created by yunyunzhang on 2018/7/31.
//  Copyright © 2018年 yunyunzhang. All rights reserved.
//

#import "RootViewController.h"
#import "Utility.h"
#import "YYCropImageViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface RootViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(50, 100, 100, 50);
    selectBtn.layer.borderColor = [UIColor blackColor].CGColor;
    selectBtn.layer.borderWidth = 1.0;
    selectBtn.layer.cornerRadius = 25;
    [selectBtn setTitle:@"选择照片" forState:UIControlStateNormal];
    [selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBtn];
}

- (void)selectBtnAction
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController * imagePickerVC = [[UIImagePickerController alloc]init];
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerVC.delegate = self;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage * theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        YYCropImageViewController * imageVc = [[YYCropImageViewController alloc]initWithPhoto:theImage];
        [self presentViewController:imageVc animated:YES completion:nil];
    }
}

// 取消图片选择调用此方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
