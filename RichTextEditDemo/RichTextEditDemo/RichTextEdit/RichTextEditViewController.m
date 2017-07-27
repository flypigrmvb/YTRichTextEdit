//
//  RichTextEditViewController.m
//  RichTextEditDemo
//
//  Created by aron on 2017/7/19.
//  Copyright © 2017年 aron. All rights reserved.
//

#import "RichTextEditViewController.h"
#import <Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UtilMacro.h"
#import "MMFileUploadUtil.h"
#import "MMRichContentUtil.h"

#import "MMRichTitleModel.h"
#import "MMRichTextModel.h"
#import "MMRichImageModel.h"

#import "MMRichTitleCell.h"
#import "MMRichTextCell.h"
#import "MMRichImageCell.h"
#import "MMRichEditAccessoryView.h"



@interface RichTextEditViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RichTextEditDelegate, MMRichEditAccessoryViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) MMRichEditAccessoryView *contentInputAccessoryView;
@property (nonatomic, strong) MMRichTitleModel* titleModel;
@property (nonatomic, strong) NSMutableArray* datas;
@property (nonatomic, strong) NSIndexPath* activeIndexPath;

@end

@implementation RichTextEditViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_(@"Upload") style:UIBarButtonItemStylePlain target:self action:@selector(onUpload)];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // register cell
    [self.tableView registerClass:MMRichTitleCell.class forCellReuseIdentifier:NSStringFromClass(MMRichTitleCell.class)];
    [self.tableView registerClass:MMRichTextCell.class forCellReuseIdentifier:NSStringFromClass(MMRichTextCell.class)];
    [self.tableView registerClass:MMRichImageCell.class forCellReuseIdentifier:NSStringFromClass(MMRichImageCell.class)];
    
    // Datas
    _titleModel = [MMRichTitleModel new];
    _datas = [NSMutableArray array];
    [_datas addObject:[MMRichTextModel new]];
    
    // AccessoryView
    [self contentInputAccessoryView];
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 40.f;
    self.contentInputAccessoryView.frame = rect;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView* tableView = [UITableView new];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.estimatedRowHeight = 200;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView = tableView;
    }
    return _tableView;
}

- (MMRichEditAccessoryView *)contentInputAccessoryView {
    if (!_contentInputAccessoryView) {
        _contentInputAccessoryView = [[MMRichEditAccessoryView alloc] init];
        _contentInputAccessoryView.delegate = self;
    }
    return _contentInputAccessoryView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    NSLog(@"===dealloc===");
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

- (void)handleInsertImage:(UIImage*)image {
    
    if (!_activeIndexPath) {
        _activeIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:_activeIndexPath];
    if ([cell isKindOfClass:[MMRichTextCell class]]) {
        // 处理文本节点
        // 根据光标拆分文本节点
        BOOL isPre = NO;
        BOOL isPost = NO;
        NSArray* splitedTexts = [((MMRichTextCell*)cell) splitedTextArrWithPreFlag:&isPre postFlag:&isPost];
        
        // 前面优先级更高，需要调整优先级，调整if语句的位置即可
        if (isPre) {
            // 前面添加图片，光标停留在当前位置
            [self addImageNodeAtIndexPath:_activeIndexPath image:image];
            
        } else if (isPost) {
            // 后面添加图片，光标移动到下一行
            NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:_activeIndexPath.row + 1 inSection:_activeIndexPath.section];
            [self addImageNodeAtIndexPath:nextIndexPath image:image];
            [self positionToNextItemAtIndexPath:_activeIndexPath];

        } else {
            // 替换当前节点，添加Text/image/Text，光标移动到图片节点上
            NSInteger tmpActiveIndexRow = _activeIndexPath.row;
            NSInteger tmpActiveIndexSection = _activeIndexPath.section;
            [self deleteItemAtIndexPath:_activeIndexPath shouldPositionPrevious:NO];
            if (splitedTexts.count == 2) {
                // 第一段文字
                [self addTextNodeAtIndexPath:_activeIndexPath textContent:splitedTexts.firstObject];
                // 图片
                [self addImageNodeAtIndexPath:[NSIndexPath indexPathForRow:tmpActiveIndexRow + 1 inSection:tmpActiveIndexSection] image:image];
                // 第二段文字
                [self addTextNodeAtIndexPath:[NSIndexPath indexPathForRow:tmpActiveIndexRow + 2 inSection:_activeIndexPath.section] textContent:splitedTexts.lastObject];
                // 光标移动到图片位置
                [self positionAtIndex:[NSIndexPath indexPathForRow:tmpActiveIndexRow + 1 inSection:tmpActiveIndexSection]];
            }
        }
        
    } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
        
        BOOL isPre = NO;
        BOOL isPost = NO;
        [((MMRichImageCell*)cell) getPreFlag:&isPre postFlag:&isPost];
        if (isPre) {
            [self addImageNodeAtIndexPath:_activeIndexPath image:image];
        } else if (isPost) {
            NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:_activeIndexPath.row + 1 inSection:_activeIndexPath.section];
            [self addImageNodeAtIndexPath:nextIndexPath image:image];
        } else {
            NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:_activeIndexPath.row + 1 inSection:_activeIndexPath.section];
            [self addImageNodeAtIndexPath:nextIndexPath image:image];
        }
        
    } else {
        MMRichImageModel* imageModel = [MMRichImageModel new];
        imageModel.image = image;
        [_datas addObject:imageModel];
        [self.tableView reloadData];
    }
}

// 处理重新加载
- (void)handleReloadItemAdIndexPath:(NSIndexPath*)indexPath {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:_(@"Delete") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        if (indexPath.row == 0 && _datas.count == 1) {
            // 第一行，并且只有一个元素：添加Text
            [self deleteItemAtIndexPath:indexPath shouldPositionPrevious:NO];
            [self addTextNodeAtIndexPath:indexPath textContent:nil];
        } else {
            [self deleteItemAtIndexPath:indexPath shouldPositionPrevious:YES];
        }
    }];
    
    UIAlertAction * uploadAgainAction = [UIAlertAction actionWithTitle:_(@"Upload again") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        if (indexPath.row < _datas.count) {
            MMRichImageModel* imageModel = _datas[indexPath.row];
            // 添加到上传队列中
            [[MMFileUploadUtil sharedInstance] addUploadItem:imageModel];
        }
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:_(@"Cancel") style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:uploadAgainAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - ......::::::: ui actoin :::::::......

- (void)onUpload {
    
    // 验证输入
    // 1、验证title
    
    // 2、验证内容
    
    
    if ([MMRichContentUtil validateRichContents:self.datas]) {
        NSString* html = [MMRichContentUtil htmlContentFromRichContents:self.datas];
        NSLog(@"html: %@", html);
        
    } else {
        // 还有图片没上传或者图片失败的情况
    }
}


#pragma mark - Node Handler

- (void)addImageNodeAtIndexPath:(NSIndexPath*)indexPath image:(UIImage*)image {
    
    UIImage* scaledImage = [MMRichContentUtil scaleImage:image];
    NSString* scaledImageStorePath = [MMRichContentUtil saveImageToLocal:scaledImage];
    MMRichImageModel* imageModel = [MMRichImageModel new];
    imageModel.image = scaledImage;
    imageModel.localImagePath = scaledImageStorePath;

    // 添加到上传队列中
    [[MMFileUploadUtil sharedInstance] addUploadItem:imageModel];
    
    [self.tableView beginUpdates];
    [_datas insertObject:imageModel atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}


- (void)addTextNodeAtIndexPath:(NSIndexPath*)indexPath textContent:(NSString*)textContent {
    MMRichTextModel* textModel = [MMRichTextModel new];
    textModel.textContent = textContent;
    
    [self.tableView beginUpdates];
    [_datas insertObject:textModel atIndex:indexPath.row];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    // 定位到新增的元素
    [self positionAtIndex:indexPath];
}

- (void)deleteItemAtIndexPathes:(NSArray<NSIndexPath*>*)actionIndexPathes shouldPositionPrevious:(BOOL)shouldPositionPrevious {
    if (actionIndexPathes.count > 0) {
        //  定位动到上一行
        if (shouldPositionPrevious) {
            [self positionToPreItemAtIndexPath:actionIndexPathes.firstObject];
        }
        
        // 处理删除
        for (NSInteger i = actionIndexPathes.count - 1; i >= 0; i--) {
            NSIndexPath* actionIndexPath = actionIndexPathes[i];
            [_datas removeObjectAtIndex:actionIndexPath.row];
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:actionIndexPathes withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath*)actionIndexPath shouldPositionPrevious:(BOOL)shouldPositionPrevious {
    //  定位动到上一行
    if (shouldPositionPrevious) {
        [self positionToPreItemAtIndexPath:actionIndexPath];
    }
    
    // 处理删除
    [_datas removeObjectAtIndex:actionIndexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:actionIndexPath.row inSection:actionIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
}

/**
 定位到指定的元素
 */
- (void)positionAtIndex:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MMRichTextCell class]]) {
        [((MMRichTextCell*)cell) beginEditing];
    } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
        [((MMRichImageCell*)cell) beginEditing];
    }
}

// 定位动到上一行
- (void)positionToPreItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    NSIndexPath* preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row - 1 inSection:actionIndexPath.section];
    [self positionAtIndex:preIndexPath];
}

// 定位动到上一行
- (void)positionToNextItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    NSIndexPath* preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row + 1 inSection:actionIndexPath.section];
    [self positionAtIndex:preIndexPath];
}



#pragma mark - ......::::::: UIImagePickerController :::::::......

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self handleInsertImage:image];
    }];
}


#pragma mark - ......::::::: RichTextEditDelegate :::::::......

- (void)mm_preInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString*)textContent {
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:actionIndexPath];
    if ([cell isKindOfClass:[MMRichTextCell class]]) {
        // 不处理
    } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
        NSIndexPath* preIndexPath = nil;
        if (actionIndexPath.row > 0) {
            preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row - 1 inSection:actionIndexPath.section];
            
            id preData = _datas[preIndexPath.row];
            if ([preData isKindOfClass:[MMRichTextModel class]]) {
                // Image节点-前面：上面是text，光标移动到上面一行，并且在最后添加一个换行，定位光标在最后将
                [self.tableView scrollToRowAtIndexPath:preIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
                // 设置为编辑模式
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:preIndexPath];
                if ([cell isKindOfClass:[MMRichTextCell class]]) {
                    [((MMRichTextCell*)cell) beginEditing];
                } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
                    [((MMRichImageCell*)cell) beginEditing];
                }
            } else if ([preData isKindOfClass:[MMRichImageModel class]]) {
                // Image节点-前面：上面是图片或者空，在上面添加一个Text节点，光标移动到上面一行，
                [self addTextNodeAtIndexPath:actionIndexPath textContent:textContent];
            }
            
        } else {
            // 上面为空，添加一个新的单元格
            [self addTextNodeAtIndexPath:actionIndexPath textContent:textContent];
        }
    }
}

- (void)mm_postInsertTextLineAtIndexPath:(NSIndexPath*)actionIndexPath textContent:(NSString *)textContent {
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:actionIndexPath];
    if ([cell isKindOfClass:[MMRichTextCell class]]) {
        // 不处理
    } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
        NSIndexPath* nextIndexPath = nil;
        nextIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row + 1 inSection:actionIndexPath.section];
        if (actionIndexPath.row < _datas.count-1) {
            
            id nextData = _datas[nextIndexPath.row];
            if ([nextData isKindOfClass:[MMRichTextModel class]]) {
                // Image节点-后面：下面是text，光标移动到下面一行，并且在最前面添加一个换行，定位光标在最前面
                [self.tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
                // 添加文字到下一行
                MMRichTextModel* textModel = ((MMRichTextModel*)nextData);
                textModel.textContent = [NSString stringWithFormat:@"%@%@", textContent, textModel.textContent];
                textModel.selectedRange = NSMakeRange(textContent.length, 0);
                textModel.shouldUpdateSelectedRange = YES;
                
                // 设置为编辑模式
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
                if ([cell isKindOfClass:[MMRichTextCell class]]) {
                    [((MMRichTextCell*)cell) beginEditing];
                } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
                    [((MMRichImageCell*)cell) beginEditing];
                }
            } else if ([nextData isKindOfClass:[MMRichImageModel class]]) {
                // Image节点-后面：下面是图片或者空，在下面添加一个Text节点，光标移动到下面一行
                [self addTextNodeAtIndexPath:nextIndexPath textContent:textContent];
            }
            
        } else {
            // Image节点-后面：下面是图片或者空，在下面添加一个Text节点，光标移动到下面一行
            [self addTextNodeAtIndexPath:nextIndexPath textContent:textContent];
        }
    }
}

- (void)mm_preDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:actionIndexPath];
    if ([cell isKindOfClass:[MMRichTextCell class]]) {
        // 处理Text节点
        if (actionIndexPath.row < _datas.count) {
            
            if (actionIndexPath.row <= 0) {
                MMRichTextModel* textModel = (MMRichTextModel*)_datas[actionIndexPath.row];
                if (_datas.count == 1) {
                    // Text节点-当前的Text为空-前面-没有其他元素-：不处理
                    // Text节点-当前的Text不为空-前面-没有其他元素-：不处理
                } else {
                    if (textModel.textContent.length == 0) {
                        // Text节点-当前的Text为空-前面-有其他元素-：删除这一行，定位光标到下面图片的最后
                        [self positionToNextItemAtIndexPath:actionIndexPath];
                        [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:NO];
                    } else {
                        // Text节点-当前的Text不为空-前面-有其他元素-：不处理
                    }
                }
            } else {
                MMRichTextModel* textModel = (MMRichTextModel*)_datas[actionIndexPath.row];
                if (textModel.textContent.length == 0) {
                    // Text节点-当前的Text为空-前面-有其他元素-：删除这一行，定位光标到上面图片的最后
                    [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:YES];
                    
                } else {
                    // 当前节点不为空
                    // Text节点-当前的Text不为空-前面-：上面是图片，定位光标到上面图片的最后
                    // Text节点不存在相邻的情况，所以直接定位上上一个元素即可
                    [self positionToPreItemAtIndexPath:actionIndexPath];
                }
            }
        }
    } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
        // 处理Image节点
        if (actionIndexPath.row < _datas.count) {
            if (actionIndexPath.row <= 0) {
                // Image节点-前面-上面为空：不处理
                // 第一行不处理
            } else {
                NSIndexPath* preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row - 1 inSection:actionIndexPath.section];
                if (preIndexPath.row < _datas.count) {
                    id preData = _datas[preIndexPath.row];
                    if ([preData isKindOfClass:[MMRichTextModel class]]) {
                        if (((MMRichTextModel*)preData).textContent.length == 0) {
                            // mage节点-前面-上面为Text（为空）：删除上面Text节点
                            [self deleteItemAtIndexPath:preIndexPath shouldPositionPrevious:NO];
                        } else {
                            [self positionToPreItemAtIndexPath:actionIndexPath];
                        }
                    } else if ([preData isKindOfClass:[MMRichImageModel class]]) {
                        [self positionToPreItemAtIndexPath:actionIndexPath];
                    }
                }
            }
        }
    }
}

- (void)mm_PostDeleteItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:actionIndexPath];
    if ([cell isKindOfClass:[MMRichTextCell class]]) {
        // 不处理
        // Text节点-当前的Text不为空-后面-：正常删除
        // Text节点-当前的Text为空-后面-：正常删除，和第三种情况：为空的情况处理一样
    } else if ([cell isKindOfClass:[MMRichImageCell class]]) {
        // 处理Image节点
        if (actionIndexPath.row < _datas.count) {
            // 处理第一个节点
            if (actionIndexPath.row <= 0) {
                if (_datas.count > 1) {
                    // Image节点-后面-上面为空-列表多于一个元素：删除当前节点，光标放在后面元素之前
                    [self positionToNextItemAtIndexPath:actionIndexPath];
                    [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:NO];
                } else {
                    // Image节点-后面-上面为空-列表只有一个元素：添加一个Text节点，删除当前Image节点，光标放在添加的Text节点上
                    [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:NO];
                    [self addTextNodeAtIndexPath:actionIndexPath textContent:nil];
                }
            } else {
                // 处理非第一个节点
                NSIndexPath* preIndexPath = nil;
                if (actionIndexPath.row > 0) {
                    preIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row - 1 inSection:actionIndexPath.section];
                    id preData = _datas[preIndexPath.row];
                    if ([preData isKindOfClass:[MMRichTextModel class]]) {
                        NSIndexPath* nextIndexPath = nil;
                        if (actionIndexPath.row < _datas.count - 1) {
                            nextIndexPath = [NSIndexPath indexPathForRow:actionIndexPath.row + 1 inSection:actionIndexPath.section];
                        }
                        if (nextIndexPath) {
                            id nextData = _datas[nextIndexPath.row];
                            if ([nextData isKindOfClass:[MMRichTextModel class]]) {
                                // Image节点-后面-上面为Text-下面为Text：删除Image节点，合并下面的Text到上面，删除下面Text节点，定位到上面元素的后面
                                ((MMRichTextModel*)preData).textContent = [NSString stringWithFormat:@"%@\n%@", ((MMRichTextModel*)preData).textContent, ((MMRichTextModel*)nextData).textContent];
                                [self deleteItemAtIndexPathes:@[actionIndexPath, nextIndexPath] shouldPositionPrevious:YES];
                            } else {
                                // Image节点-后面-上面为Text-下面为图片或者空：删除Image节点，定位到上面元素的后面
                                [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:YES];
                            }
                        } else {
                            // Image节点-后面-上面为Text-下面为图片或者空：删除Image节点，定位到上面元素的后面
                            [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:YES];
                        }
                        
                    } else if ([preData isKindOfClass:[MMRichImageModel class]]) {
                        // Image节点-后面-上面为图片：删除Image节点，定位到上面元素的后面
                        [self deleteItemAtIndexPath:actionIndexPath shouldPositionPrevious:YES];
                    }
                }
            }
        }
    }
}

// 更新ActionIndexpath
- (void)mm_updateActiveIndexPath:(NSIndexPath*)activeIndexPath {
    _activeIndexPath = activeIndexPath;
}

// 重新加载
- (void)mm_reloadItemAtIndexPath:(NSIndexPath*)actionIndexPath {
    [self handleReloadItemAdIndexPath:actionIndexPath];
}

- (MMRichEditAccessoryView *)mm_inputAccessoryView {
    return [self contentInputAccessoryView];
}


#pragma mark - ......::::::: MMRichEditAccessoryViewDelegate :::::::......

- (void)mm_didKeyboardTapInaccessoryView:(MMRichEditAccessoryView *)accessoryView {
    [self.view endEditing:YES];
}

- (void)mm_didImageTapInaccessoryView:(MMRichEditAccessoryView *)accessoryView {
    [self handleSelectPics];
}


#pragma mark - ......::::::: Notification :::::::......

- (void)keyboardWillChangeFrame:(NSNotification*)noti {
    
    CGRect keyboardFrame =  [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    NSTimeInterval keyboardAnimTime = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGFloat keyboardH = kScreenHeight - keyboardFrame.origin.y;
    [UIView animateWithDuration:keyboardAnimTime animations:^{
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-keyboardH);
        }];
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - ......::::::: UITableView Handler :::::::......

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Title
    if (section == 0) {
        return 1;
    }
    // Content
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Title
    if (indexPath.section == 0) {
        MMRichTitleCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MMRichTitleCell.class)];
        cell.delegate = self;
        [cell updateWithData:_titleModel indexPath:indexPath];
        return cell;
    }
    // Content
    id obj = _datas[indexPath.row];
    if ([obj isKindOfClass:[MMRichTextModel class]]) {
        MMRichTextCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MMRichTextCell.class)];
        cell.delegate = self;
        [cell updateWithData:obj indexPath:indexPath];
        return cell;
    }
    if ([obj isKindOfClass:[MMRichImageModel class]]) {
        MMRichImageCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(MMRichImageCell.class)];
        cell.delegate = self;
        [cell updateWithData:obj];
        return cell;
    }
    
    static NSString* cellID = @"cellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
