//
//  VideoObject.m
//  TestTask
//
//  Created by apple on 20.04.16.
//  Copyright © 2016 OlegKasarin. All rights reserved.
//

#import "VideoObject.h"

@implementation VideoObject


- (NSString*) titleString {
    
    return [NSString stringWithFormat:@"%@ (%@)", self.name, [self formattedSize:self.size]];
}

- (NSString*) subtitleString {
    
    NSString* string = (self.status == 0) ? @"" : [NSString stringWithFormat:@"%@  %@ of %@ (%@)",
                                                   [self stateString:self.status],
                                                   [self formattedSize:self.downloaded],
                                                   [self formattedSize:self.size],
                                                   [self percentDownloaded:self.size of:self.downloaded]];

    
    return string;
}

- (NSString*) formattedSize: (double) size {
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB"};
    static int unitsCount = 4;
    
    int index = 0;
    
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        fileSize /=1024;
        index++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}

- (NSString*) percentDownloaded: (double) size of: (double) downloaded {
    
    double percent = downloaded / size * 100;
    
    return [NSString stringWithFormat:@"%.f%%", percent];
}

- (NSString*) stateString: (double) status {
    
    NSString* result;
    if (status == 1) {
        result = @"Downloading";
    } else if (status == 2) {
        result = @"Paused";
    } else {
        result = @"Downloaded";
    }
    
    return result;
}

@end
