//
//  AsynchronousImageView.h
//  GLOSS
//
//  Created by Слава on 22.10.09.
//  Copyright 2009 Slava Bushtruk. All rights reserved.
//  ---------------------------------------------------
//
//  Modified by Ben Baron for the iSub project.
//

#import <UIKit/UIKit.h>


@interface AsynchronousImageView : UIImageView 
{
    NSURLConnection *connection;
    NSMutableData *data;
}

- (void)loadImageFromURLString:(NSString *)theUrlString;

@end
