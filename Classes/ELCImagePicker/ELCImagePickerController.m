//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ELCConsole.h"

@implementation ELCImagePickerController

+(NSBundle *)bundle
{
    static NSBundle *bundle;
    static dispatch_once_t once;
    dispatch_once(&once, ^
    {
        bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ELCImagePickerController" ofType:@"bundle"]];
    });
    return bundle;
}

- (id)initImagePickerWithDelegate:(id<ELCImagePickerControllerDelegate>)delegate
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    self = [super initWithRootViewController:albumPicker];
    
    if (self) {
        self.imagePickerDelegate = delegate;
        
        self.returnsImage = YES;
        self.maximumImagesCount = 4;
        self.returnsOriginalImage = YES;
        
        self.onOrder = NO;
        self.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        
        [albumPicker setParent:self];
    }
    
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{

    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
        self.returnsImage = YES;
    }
    return self;
}

- (ELCAlbumPickerController *)albumPicker
{
    return self.viewControllers[0];
}

- (void)setMediaTypes:(NSArray *)mediaTypes
{
    self.albumPicker.mediaTypes = mediaTypes;
}

- (NSArray *)mediaTypes
{
    return self.albumPicker.mediaTypes;
}

- (void)cancelAssetSelection
{
    [_imagePickerDelegate elcImagePickerControllerDidCancel:self];
}

- (BOOL)isSingleSelection {
    return self.maximumImagesCount <= 1;
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    BOOL shouldSelect = previousCount < self.maximumImagesCount;
    if (!shouldSelect) {
        NSString *format = NSLocalizedStringWithDefaultValue(@"only_n_photos", nil, [ELCImagePickerController bundle], @"Only %ld photos please!", nil);
        NSString *title = [NSString stringWithFormat:format, (long)self.maximumImagesCount];
        format = NSLocalizedStringWithDefaultValue(@"only_n_at_a_time", nil, [ELCImagePickerController bundle], @"You can only select %ld photos at a time.", nil);
        NSString *message = [NSString stringWithFormat:format, (long)self.maximumImagesCount];
        NSString *ok = NSLocalizedStringWithDefaultValue(@"ok", nil, [ELCImagePickerController bundle], @"OK", nil);
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:ok, nil] show];
    }
    return shouldSelect;
}

- (BOOL)shouldDeselectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    return YES;
}

- (void)selectedAssets:(NSArray *)assets
{
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ELCAsset *elcasset in assets) {
        ALAsset *asset = elcasset.asset;
		id obj = [asset valueForProperty:ALAssetPropertyType];
		if (!obj) {
			continue;
		}
		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		
		CLLocation* wgs84Location = [asset valueForProperty:ALAssetPropertyLocation];
		if (wgs84Location) {
			[workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
		}
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];

        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];

        if(assetRep != nil) {
            if (_returnsImage) {
                CGImageRef imgRef = nil;
                //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
                //so use UIImageOrientationUp when creating our image below.
                UIImageOrientation orientation = UIImageOrientationUp;
            
                if (_returnsOriginalImage) {
                    imgRef = [assetRep fullResolutionImage];
                    orientation = (UIImageOrientation)[assetRep orientation];
                } else {
                    imgRef = [assetRep fullScreenImage];
                }
                UIImage *img = [UIImage imageWithCGImage:imgRef
                                                   scale:1.0f
                                             orientation:orientation];
                [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
            }

            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerMediaURL];
            
            [returnArray addObject:workingDictionary];
        }
		
	}
    
	[_imagePickerDelegate elcImagePickerController:self didFinishPickingMediaWithInfo:returnArray];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (BOOL)onOrder
{
    return [[ELCConsole mainConsole] onOrder];
}

- (void)setOnOrder:(BOOL)onOrder
{
    [[ELCConsole mainConsole] setOnOrder:onOrder];
}

@end
