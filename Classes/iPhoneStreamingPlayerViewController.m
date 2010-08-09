//
//  iPhoneStreamingPlayerViewController.m
//  iSub
//
//  Created by Ben Baron on 2/27/10.
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

#import "iSubAppDelegate.h"
#import "iPhoneStreamingPlayerViewController.h"
#import "SongInfoViewController.h"
#import "AudioStreamer.h"
#import "AsynchronousImageView.h"
#import "Song.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation iPhoneStreamingPlayerViewController


- (void)setPlayButtonImage
{		
	//[playButton setImage:[UIImage imageNamed:@"controller-play.png"] forState:0];
	[playButton setTitle:@"play" forState:UIControlStateNormal];
}


- (void)setPauseButtonImage
{
	//[playButton setImage:[UIImage imageNamed:@"controller-pause.png"] forState:0];
	[playButton setTitle:@"pause" forState:UIControlStateNormal];
}
 

- (void)setSongTitle
{
	self.title = [appDelegate.currentSongObject title];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlayButtonImage) name:@"setPlayButtonImage" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPauseButtonImage) name:@"setPauseButtonImage" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSongTitle) name:@"setSongTitle" object:nil];
	
	if (appDelegate.isNewSong)
	{
		appDelegate.currentPlaylist = [appDelegate.listOfSongs copy];
		appDelegate.currentPlaylistDict = [appDelegate.dictOfSongs copy];
	}
	
	self.title = [appDelegate.currentSongObject title];
		
	NSString *urlString = [appDelegate getBaseUrl:@"stream.view"];
	NSString *urlString2 = [urlString stringByAppendingString:[appDelegate.currentSongObject songId]];
	if (appDelegate.songUrl)
		[appDelegate.songUrl release];
	appDelegate.songUrl = [[NSURL alloc] initWithString:urlString2];
	
	if([appDelegate.currentSongObject coverArtId])
	{
		if(appDelegate.isNewSong)
		{
			urlString = [appDelegate getBaseUrl:@"getCoverArt.view"];
			//urlString2 = [urlString stringByAppendingString:[appDelegate.currentSongObject coverArtId]];
			urlString2 = [NSString stringWithFormat:@"%@%@&size=320", urlString, [appDelegate.currentSongObject coverArtId]];
			if (appDelegate.coverArtUrl)
				[appDelegate.coverArtUrl release];
			appDelegate.coverArtUrl = [[NSURL alloc] initWithString:urlString2];
			[coverArtImageView loadImageFromURLString:urlString2];
		}
		else
		{
			coverArtImageView.image = appDelegate.currentCoverArt;
		}
	}
	else 
	{
		appDelegate.currentCoverArt = [UIImage imageNamed:@"default-album-art.png"];
		coverArtImageView.image = appDelegate.currentCoverArt;
	}
	
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
	
	if(appDelegate.isNewSong)
	{
		[self setPlayButtonImage];
	}
	else
	{
		if([appDelegate.streamer isPlaying])
			[self setPauseButtonImage];
		else
			[self setPlayButtonImage];
	}
}


- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"hideSongInfoFast" object:nil];
}


- (IBAction)songInfoToggle:(id)sender
{
	SongInfoViewController *sInfoViewController = [[SongInfoViewController alloc] initWithNibName:@"SongInfoViewController" bundle:nil];
	[self.view addSubview:sInfoViewController.view];
	[sInfoViewController showSongInfo];
}


- (IBAction)playButtonPressed:(id)sender
{
	[appDelegate playPauseSong];
}

- (IBAction)prevButtonPressed:(id)sender
{
	[appDelegate prevSong];
}

- (IBAction)nextButtonPressed:(id)sender
{
	[appDelegate nextSong];
}


//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	//[self destroyStreamer];
	/*if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}*/
	[SongInfoViewController release];
	[super dealloc];
}

@end
