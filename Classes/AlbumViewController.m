//
//  AlbumViewController.m
//  iSub
//
//  Created by Ben Baron on 2/28/10.
//  Copyright 2010 Ben Baron. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  
//  * Redistributions of source code must retain the above copyright notice, this 
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the my name nor the names of my contributors may be used to endorse
//    or promote products derived from this software without specific prior written 
//    permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
//  DAMAGE.

#import "AlbumViewController.h"
#import "iSubAppDelegate.h"
#import "iPhoneStreamingPlayerViewController.h"
#import "AlbumUITableViewCell.h"
#import "SongUITableViewCell.h"
#import "AsynchronousImageViewCached.h"
#import "XMLParser.h"
#import "Artist.h"
#import "Album.h"
#import "Song.h"

@implementation AlbumViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.isTopLevel)
		self.title = [appDelegate.artistObject name];
	else
		self.title = [appDelegate.albumObject title];
}


-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if(appDelegate.streamer)
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingAction:)] autorelease];
	
	// Pull from appDelegate.viewHistory dictionary if there's an entry for the title and reload the table view with that albumId's data
	if ([appDelegate.viewHistory objectForKey:self.title])
	{
		appDelegate.currentId = [appDelegate.viewHistory objectForKey:self.title];
		if ([appDelegate.albumListCache objectForKey:[appDelegate.viewHistory objectForKey:self.title]] == nil)
		{
			NSString *urlString = [appDelegate getBaseUrl:@"getMusicDirectory.view"];
			urlString2 = [urlString stringByAppendingString:[appDelegate.viewHistory objectForKey:self.title]];
			url = [[NSURL alloc] initWithString:urlString2];
		
			// Parse the XML
			appDelegate.parseState = @"albums";
			NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
			XMLParser *parser = [[XMLParser alloc] initXMLParser];
			[xmlParser setDelegate:parser];
			if([xmlParser parse])
				NSLog(@"No Errors");
			else
				NSLog(@"Error Error Error!!!");	
		
			[xmlParser release];
			[parser release];
		}
		else
		{
			NSArray *cache = [NSKeyedUnarchiver unarchiveObjectWithData:[appDelegate.albumListCache objectForKey:appDelegate.currentId]];
			
			appDelegate.listOfAlbums = [[cache objectAtIndex:0] copy];
			appDelegate.dictOfAlbums = [[cache objectAtIndex:1] copy];
			appDelegate.listOfSongs = [[cache objectAtIndex:2] copy];
			appDelegate.dictOfSongs = [[cache objectAtIndex:3] copy];
		}
		[self.tableView reloadData];
	}
	else 
	{
		if (appDelegate.isTopLevel)
			[appDelegate.viewHistory setObject:[appDelegate.artistObject artistId] forKey:self.title];
		else
			[appDelegate.viewHistory setObject:[appDelegate.albumObject albumId] forKey:self.title];
	}
}


- (IBAction)nowPlayingAction:(id)sender
{
	if(appDelegate.streamer)
	{
		appDelegate.isNewSong = NO;
		iPhoneStreamingPlayerViewController *streamingPlayerViewController = [[iPhoneStreamingPlayerViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:nil];
		[self.navigationController pushViewController:streamingPlayerViewController animated:YES];
		[streamingPlayerViewController release];
	}
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return ([appDelegate.listOfAlbums count] + [appDelegate.listOfSongs count]);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	static NSString *CellIdentifier = @"Cell";
	
	// Set up the cell...
	if (indexPath.row < [appDelegate.listOfAlbums count])
	{
		AlbumUITableViewCell *cell = [[[AlbumUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//if (cell == nil) {
		//	cell = [[AlbumUITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
		//}
		NSString *cellValue = [appDelegate.listOfAlbums objectAtIndex:indexPath.row];
		
		if ([[appDelegate.dictOfAlbums objectForKey:cellValue] coverArtId])
		{
			if ([appDelegate.coverArtCache objectForKey:[[appDelegate.dictOfAlbums objectForKey:cellValue] coverArtId]])
			{
				// If the image is already in the cache dictionary, load it
				cell.coverArtView.image = [appDelegate.coverArtCache objectForKey:[[appDelegate.dictOfAlbums objectForKey:cellValue] coverArtId]];
			}
			else 
			{			
				// If not, grab it from the url and cache it
				NSString *imgUrlString = [appDelegate getBaseUrl:@"getCoverArt.view"];
				NSString *imgUrlString2 = [NSString stringWithFormat:@"%@%@&size=60", imgUrlString, [[appDelegate.dictOfAlbums objectForKey:cellValue] coverArtId]];
				[cell.coverArtView loadImageFromURLString:imgUrlString2 coverArtId:[[appDelegate.dictOfAlbums objectForKey:cellValue] coverArtId]];
			}
		}
		else
		{
			cell.coverArtView.image = [UIImage imageNamed:@"default-album-art-small.png"];
		}
		
		[cell.albumNameLabel setText:cellValue];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	else
	{
		SongUITableViewCell *cell = [[[SongUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//if (cell == nil) {
		//	cell = [[SongUITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
		//}
		
		NSUInteger a = indexPath.row - [appDelegate.listOfAlbums count];
		NSString *cellValue = [appDelegate.listOfSongs objectAtIndex:a];
		[cell.songNameLabel setText:cellValue];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		return cell;
	}
}


// Customize the height of individual rows to make the album rows taller to accomidate the album art.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < [appDelegate.listOfAlbums count])
		return 60.0;
	else
		return 43.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if (indexPath.row < [appDelegate.listOfAlbums count])
	{
		NSString *cellValue = [appDelegate.listOfAlbums objectAtIndex:indexPath.row];
		if (appDelegate.albumObject == nil)
			appDelegate.albumObject = [[Album alloc] init];
		[appDelegate.albumObject setTitle:[appDelegate.listOfAlbums objectAtIndex:indexPath.row]];
		[appDelegate.albumObject setAlbumId:[[appDelegate.dictOfAlbums objectForKey:cellValue] albumId]];
		appDelegate.currentId = [appDelegate.albumObject albumId];
		
		appDelegate.isTopLevel = NO;
		appDelegate.subItemId = [[appDelegate.dictOfAlbums objectForKey:cellValue] albumId];
		
		if ([appDelegate.albumListCache objectForKey:[appDelegate.albumObject albumId]] == nil)
		{
			NSString *urlString = [appDelegate getBaseUrl:@"getMusicDirectory.view"];
			urlString2 = [urlString stringByAppendingString:appDelegate.subItemId];
			url = [[NSURL alloc] initWithString:urlString2];
			appDelegate.subItemId = nil;
		
			// Parse the XML
			appDelegate.parseState = @"albums";
			NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
			XMLParser *parser = [[XMLParser alloc] initXMLParser];
			[xmlParser setDelegate:parser];
			if([xmlParser parse])
				NSLog(@"No Errors");
			else
				NSLog(@"Error Error Error!!!");	
		
			[url release];
			[xmlParser release];
			[parser release];
		}
		else 
		{
			NSArray *cache = [NSKeyedUnarchiver unarchiveObjectWithData:[appDelegate.albumListCache objectForKey:appDelegate.currentId]];
			
			appDelegate.listOfAlbums = [[cache objectAtIndex:0] copy];
			appDelegate.dictOfAlbums = [[cache objectAtIndex:1] copy];
			appDelegate.listOfSongs = [[cache objectAtIndex:2] copy];
			appDelegate.dictOfSongs = [[cache objectAtIndex:3] copy];
		}
		
		AlbumViewController *albumViewController = [[AlbumViewController alloc] initWithNibName:@"AlbumViewController" bundle:nil];
		[self.navigationController pushViewController:albumViewController animated:YES];
		[albumViewController release];
	}
	else
	{
		NSUInteger a = indexPath.row - [appDelegate.listOfAlbums count];
		NSString *cellValue = [appDelegate.listOfSongs objectAtIndex:a];
		if (appDelegate.currentSongObject == nil)
			appDelegate.currentSongObject = [[Song alloc] init];
		appDelegate.currentSongObject = [appDelegate.dictOfSongs objectForKey:cellValue];
			
		appDelegate.isNewSong = YES;
		appDelegate.isShuffle = NO;
		iPhoneStreamingPlayerViewController *streamingPlayerViewController = [[iPhoneStreamingPlayerViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:nil];
		[self.navigationController pushViewController:streamingPlayerViewController animated:YES];
		if(appDelegate.streamer)
			[appDelegate.streamer stop];
		[appDelegate playPauseSong];
		[streamingPlayerViewController release];
	}
}


@end

