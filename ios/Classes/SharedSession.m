//
//  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "SharedSession.h"

@implementation SharedSession

+ (instancetype)sharedInstance
{
    static SharedSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SharedSession alloc] init];
    });
    return sharedInstance;
}

- (void)newPageController:(nonnull PSPDFNewPageViewController *)controller didFinishSelectingConfiguration:(nullable PSPDFNewPageConfiguration *)configuration pageCount:(PSPDFPageCount)pageCount {
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PSPDFProcessorConfiguration *processorConfig = [[PSPDFProcessorConfiguration alloc] init];
        
        for (int i = 0; i < pageCount; i++) {
            [processorConfig addNewPageAtIndex:i configuration:configuration];
        }
        
        PSPDFProcessor *pdfProcessor = [[PSPDFProcessor alloc] initWithConfiguration:processorConfig securityOptions:nil];
        
        if (weakSelf.filePath != nil) {
            BOOL result = [pdfProcessor writeToFileURL:weakSelf.filePath error:nil];
            if (result) {
                weakSelf.pdfViewController.document = [[PSPDFDocument alloc] initWithURL:weakSelf.filePath];
            }
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
