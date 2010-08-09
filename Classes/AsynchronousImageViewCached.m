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

#import "AsynchronousImageViewCached.h"
#import "iSubAppDelegate.h"

@implementation AsynchronousImageViewCached

- (void)loadImageFromURLString:(NSString *)theUrlString coverArtId:(NSString *)artId
{
	coverArtId = [artId retain];
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
	[data release], data = nil;
	[connection release], connection = nil;
}	

	
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	iSubAppDelegate *appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Check to see if the data is a valid image. If so, use it; if not, use the default image.
	if([UIImage imageWithData:data])
	{
		[appDelegate.coverArtCache setObject:[UIImage imageWithData:data] forKey:coverArtId];
		self.image = [UIImage imageWithData:data];
	}
	else 
	{
		[appDelegate.coverArtCache setObject:[UIImage imageNamed:@"default-album-art-small.png"] forKey:coverArtId];
		self.image = [UIImage imageNamed:@"default-album-art-small.png"];
	}
	
	[coverArtId release];
	[data release], data = nil;
	[connection release], connection = nil;
}


- (void)dealloc {
	[data release];
	[connection release];
    [super dealloc];
}

@end
