//
//  ViewController.m
//  SystemCamera
//
//  Created by 郭健 on 2016/11/9.
//  Copyright © 2016年 海城. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ViewController.h"

#define IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? YES : NO)
@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    UIImageView *_imageView;
    UIImageView *_imageViewR;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化UIImageView用于显示获取的图片
    _imageViewR = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 30, 100, 100)];
    _imageViewR.backgroundColor = [UIColor grayColor];
    _imageViewR.layer.cornerRadius = 50;
    _imageViewR.layer.masksToBounds = YES;
    [self.view addSubview:_imageViewR];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 140, self.view.frame.size.width - 32, self.view.frame.size.width - 32)];
    _imageView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(16, CGRectGetMaxY(_imageView.frame) + 20, self.view.frame.size.width - 32, 35);
    button.backgroundColor = [UIColor orangeColor];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    [button setTitle:@"获取图片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark -- 按钮回调
-(void)btnClick:(UIButton *)sender{
    
    if (IOS9) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"获取图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            //判断是否支持相机
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //相机
                UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
                imagePickerVc.delegate = self;
                // set appearance / 改变相册选择页的导航栏外观
                imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
                imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
                
                
                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                    imagePickerVc.sourceType = sourceType;
                    imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    [self presentViewController:imagePickerVc animated:YES completion:nil];
                } else {
                    NSLog(@"模拟器中无法打开照相机,请在真机中使用");
                }
            }];
            
            [alertController addAction:defaultAction];
        }
        UIAlertAction *defaultAction_1 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //相册
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:defaultAction_1];
        
        //弹出视图 使用UIViewController的方法
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        
        UIActionSheet *sheet;
        
        //判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            sheet = [[UIActionSheet alloc] initWithTitle:@"获取图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选取", nil];
        }else{
            
            sheet = [[UIActionSheet alloc] initWithTitle:@"获取图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选取", nil];
        }
        [sheet showInView:self.view];
    }
}

#pragma mark -- 调用UIActionSheet
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUInteger sourceType = 0;
    
    //判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 1: //相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
                
            case 2: //相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
    }else{
        
        if (buttonIndex == 1) {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    //跳转到相机或者相册
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -- 保存图片到沙盒
-(void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1); //1为不能缩放保存
    //获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    //将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

#pragma mark -- 调用完方法 ，选择完成后调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //保存图片至本地 , 上传图片到服务器需要使用
    [self saveImage:image withName:@"avatar.png"];
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"avatar.png"];
    
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    //设置图片显示
    [_imageView setImage:savedImage];
    [_imageViewR setImage:savedImage];
}

#pragma mark -- 按取消按钮调用该方法
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}













- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

