//
//  VideoObject.h
//  TestTask
//
//  Created by apple on 20.04.16.
//  Copyright © 2016 OlegKasarin. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    defaultState,
    downloadingState,
    pausedState,
    downloadedState,
    deletedState
} VideoStatuses;

@interface VideoObject : NSObject

@property (nonatomic) NSString* name;
@property (nonatomic) NSString* link;
@property (assign, nonatomic) VideoStatuses status;
@property (assign, nonatomic) double size;
@property (assign, nonatomic) double downloaded;

@property (nonatomic) NSString* titleString;
@property (nonatomic) NSString* subtitleString;


@end
