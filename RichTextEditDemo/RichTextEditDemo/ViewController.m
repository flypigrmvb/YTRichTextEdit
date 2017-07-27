//
//  ViewController.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "ViewController.h"
#import "RichTextEditViewController.h"
#import "UtilMacro.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MMFileUploadUtil.h"
#import "MMRichImageModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onRichTextEditClick:(id)sender {
    RichTextEditViewController* controller = [RichTextEditViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onPIckerPicture:(id)sender {
    [self handleSelectPics];
}

- (IBAction)onupload:(id)sender {
//    NSData* imageData = UIImageJPEGRepresentation(self.imageView.image, 0.8);
//    [[FileUploadUtil sharedInstance] uploadFileWithData:imageData];
    
    MMRichImageModel* imageModel = [MMRichImageModel new];
    imageModel.image = self.imageView.image;
    
    [[MMFileUploadUtil sharedInstance] addUploadItem:imageModel];
}


#pragma mark - ......::::::: private :::::::......

- (void)handleSelectPics {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction * takePhotoAction = [UIAlertAction actionWithTitle:_(@"Take a photo") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [self takePhoto];
    }];
    
    UIAlertAction * choosePhotoAction = [UIAlertAction actionWithTitle:_(@"Choose from library") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [self selectPhoto];
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:_(@"Cancel") style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:takePhotoAction];
    [alertController addAction:choosePhotoAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)takePhoto {
    // 拍照
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing = NO;
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)selectPhoto {
    // 手机相册选择
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}



#pragma mark - ......::::::: UIImagePickerController :::::::......

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^ {
        self.imageView.image = image;
    }];
}


@end
