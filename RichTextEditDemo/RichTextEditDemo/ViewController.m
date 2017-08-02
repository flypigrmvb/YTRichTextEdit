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
#import "MMRichTitleModel.h"
#import "MMRichTextModel.h"
#import "MMDraftUtil.h"
#import "MMDraftModel.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 获取数据
    [MMDraftUtil retriveDraftWithCompletion:^(NSArray *aDrafts, NSError *aError) {
        // 模型转换
        _datas = aDrafts;
        [self.tableView reloadData];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onRichTextEditClick:(id)sender {
    RichTextEditViewController* controller = [RichTextEditViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - ......::::::: UITableViewDelegate :::::::......

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDraftModel *item = _datas[indexPath.row];
    static NSString* cellId = @"cellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSString* title = ((MMRichTitleModel*)item.titleModel).textContent;
    if (title.length > 0) {
        cell.textLabel.text = title;
    } else {
        cell.textLabel.text = @"NO TITLE";
    }
    
    NSMutableString* textString = [NSMutableString string];
    NSInteger imageCount = 0;
    for (id content in item.contentModels) {
        if ([content isKindOfClass:[MMRichTextModel class]]) {
            NSString* text = ((MMRichTextModel*)item.titleModel).textContent;
            if (text) {
                [textString appendString:text];
            }
        } else if ([content isKindOfClass:[MMRichImageModel class]]) {
            imageCount ++;
        }
    }
    NSString* showText = textString.length > 20 ? [textString substringToIndex:20] : textString;
    showText = [NSString stringWithFormat:@"%@  (%@ images) - %@", showText, @(imageCount), item.modifyTimeString];
    cell.detailTextLabel.text = showText;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _datas.count) {
        MMDraftModel *item = _datas[indexPath.row];
        RichTextEditViewController* viewController = [[RichTextEditViewController alloc] initWithDraft:item];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
