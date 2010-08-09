//
//  AsynchronousImageView.m
//  GLOSS
//
//  Created by Слава on 22.10.09.
//  Copyright 2009 Slava Bushtruk. All rights reserved.
//  ---------------------------------------------------
//
//  Modified by Ben Baron for the iSub project.
//

#import "AsynchronousImageView.h"
#import "iSubAppDelegate.h"

@implementation AsynchronousImageView

- (void)loadImageFromURLString:(NSString *)theUrlString
{
	[self.image release], self.image = nil;
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:theUrlString] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{
    if (data == nil)
        data = [[NSMutableData alloc] initWithCapacity:2048];
	
    [data appendData:incrementalData];
}


- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	NSLog(@"Connection to album art failed");
	iSubAppDelegate *appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.currentCoverArt = [UIImage imageNamed:@"default-album-art.png"];
	self.image = appDelegate.currentCoverArt;
	[data release], data = nil;
	[connection release], connection = nil;
}	

	
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	iSubAppDelegate *appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	/*
	//Resize image to fit in frame
	CGSize frameSize = CGSizeMake(320, 320);
	UIGraphicsBeginImageContext(frameSize);// a CGSize that has the size you want
	[[UIImage imageWithData:data] drawInRect:CGRectMake(0,0,frameSize.width,frameSize.height)];
	appDelegate.currentCoverArt = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();*/
	
	
	// Check to see if the data is a valid image. If so, use it; if not, use the default image.
	if([UIImage imageWithData:data])
	{
		appDelegate.currentCoverArt = [UIImage imageWithData:data];
		self.image = appDelegate.currentCoverArt;
	}
	else 
	{
		appDelegate.currentCoverArt = [UIImage imageNamed:@"default-album-art.png"];
		self.image = appDelegate.currentCoverArt;
	}
    [data release], data = nil;
	[connection release], connection = nil;
}


- (void)dealloc {
	[data release];
	[connection release];
    [super dealloc];
}

@end
