//
//  ELCConsole.h
//  ELCImagePickerDemo
//
//  Created by Seamus on 14-7-11.
//  Copyright (c) 2014年 ELC Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELCConsole : NSObject
{
    NSMutableArray *myIndex;
}

@property (nonatomic,assign) BOOL onOrder;

+ (ELCConsole *)mainConsole;

- (void)addIndex:(NSInteger)index;
- (void)removeIndex:(NSInteger)index;
- (void)removeAllIndex;

- (NSInteger)currIndex;
- (NSInteger)numOfSelectedElements;

@end
