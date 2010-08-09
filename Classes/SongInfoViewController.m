//
//  SongInfoViewController.m
//  iSub
//
//  Created by Ben Baron on 3/2/10.
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

#import "SongInfoViewController.h"
#import "iSubAppDelegate.h"
#import "AudioStreamer.h"
#import "math.h"
#import "Song.h"

@implementation SongInfoViewController
@synthesize progressSlider, elapsedTimeLabel, remainingTimeLabel, artistLabel, albumLabel, titleLabel, trackLabel, yearLabel, genreLabel, bitRateLabel, lengthLabel, repeatButton, shuffleButton;

- (NSString*) formatTime:(float)seconds
{
	int mins = (int) seconds / 60;
	int secs = (int) seconds % 60;
	if (secs < 10)
		return [NSString stringWithFormat:@"%i:0%i", mins, secs];
	else
		return [NSString stringWithFormat:@"%i:%i", mins, secs];
}


- (void) initInfo
{
	progressSlider.minimumValue = 0.0;
	
	if ([appDelegate.currentSongObject duration])
	{
		progressSlider.maximumValue = [[appDelegate.currentSongObject duration] floatValue];
		progressSlider.enabled = YES;
	}
	else
	{
		progressSlider.maximumValue = 100.0;
		progressSlider.enabled = NO;
	}
		
	artistLabel.text = [appDelegate.currentSongObject artist];
	titleLabel.text = [appDelegate.currentSongObject title];
	
	if ([appDelegate.currentSongObject bitRate])
		bitRateLabel.text = [NSString stringWithFormat:@"Bit Rate: %@ kbps", [[appDelegate.currentSongObject bitRate] stringValue]];
	else
		bitRateLabel.text = @"";
	
	if ([appDelegate.currentSongObject duration])
		lengthLabel.text = [NSString stringWithFormat:@"Length: %@", [self formatTime:[[appDelegate.currentSongObject duration] floatValue]]];
	else
		lengthLabel.text = @"";
	
	if ([appDelegate.currentSongObject album])
		albumLabel.text = [appDelegate.currentSongObject album];
	else
		albumLabel.text = @"";
		
	if ([appDelegate.currentSongObject track])
		trackLabel.text = [NSString stringWithFormat:@"Track: %@", [[appDelegate.currentSongObject track] stringValue]];
	else
		trackLabel.text = @"Track:";
		
	if ([appDelegate.currentSongObject year])
		yearLabel.text = [NSString stringWithFormat:@"Year: %@", [[appDelegate.currentSongObject year] stringValue]];
	else
		yearLabel.text = @"Year:";
		
	if ([appDelegate.currentSongObject genre])
		genreLabel.text = [NSString stringWithFormat:@"Genre: %@", [appDelegate.currentSongObject genre]];
	else
		genreLabel.text = @"";
	
	if(appDelegate.repeatMode == 1)
		[repeatButton setTitle:@"Repeat One" forState:UIControlStateNormal];
	else if(appDelegate.repeatMode == 2)
		[repeatButton setTitle:@"Repeat All" forState:UIControlStateNormal];
	
	if(appDelegate.isShuffle)
		[shuffleButton setTitle:@"Shuffle On" forState:UIControlStateNormal];
}


- (void) updateSlider
{
	if([appDelegate.currentSongObject duration])
	{
		CGRect frame = self.view.frame;
		if (frame.origin.x == 0)
		{
			[appDelegate.streamer progress];
			progressSlider.value = (appDelegate.streamerProgress + appDelegate.seekTime);
			elapsedTimeLabel.text = [self formatTime:(appDelegate.streamerProgress + appDelegate.seekTime)];
			remainingTimeLabel.text = [NSString stringWithFormat:@"-%@",[self formatTime:([[appDelegate.currentSongObject duration] floatValue] - (appDelegate.streamerProgress + appDelegate.seekTime))]];
		}
	}
	else 
	{
		[appDelegate.streamer progress];
		elapsedTimeLabel.text = [self formatTime:(appDelegate.streamerProgress + appDelegate.seekTime)];
		remainingTimeLabel.text = [self formatTime:0];
	}

}


- (IBAction) touchedSlider
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateProgress" object:nil];
}


- (IBAction) movingSlider
{
	progressLabel.hidden = NO;
	progressLabelBackground.hidden = NO;
	
	CGFloat percent = progressSlider.value / progressSlider.maximumValue;
	CGFloat x = 20 + (percent * progressSlider.frame.size.width);
	progressLabel.center = CGPointMake(x, 15);
	progressLabelBackground.center = CGPointMake(x - 0.5, 15.5);
	
	[progressLabel setText:[self formatTime:progressSlider.value]];
}


- (IBAction) movedSlider
{
	progressLabel.hidden = YES;
	progressLabelBackground.hidden = YES;
	appDelegate.seekTime = progressSlider.value;
	[appDelegate.streamer startWithOffsetInSecs:(UInt32)progressSlider.value];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlider) name:@"updateProgress" object:nil];
}


- (void) showSongInfo
{
	CGRect frame = self.view.frame;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	frame.origin.x = 0;
	self.view.frame = frame;
	
	[UIView commitAnimations];
}


- (void) hideSongInfo
{
	CGRect frame = self.view.frame;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];

	frame.origin.x = -320;
	self.view.frame = frame;

	[UIView commitAnimations];
}


- (void) hideSongInfoFast
{
	CGRect frame = self.view.frame;
	frame.origin.y = 0;
	frame.origin.x = -320;
	self.view.frame = frame;
	
	[self.view removeFromSuperview];
}



- (IBAction) songInfoToggle
{
	[self hideSongInfo];
}


- (IBAction) repeatButtonToggle
{
	if(appDelegate.repeatMode == 0)
	{
		[repeatButton setTitle:@"Repeat One" forState:UIControlStateNormal];
		appDelegate.repeatMode = 1;
	}
	else if(appDelegate.repeatMode == 1)
	{
		[repeatButton setTitle:@"Repeat All" forState:UIControlStateNormal];
		appDelegate.repeatMode = 2;
	}
	else if(appDelegate.repeatMode == 2)
	{
		[repeatButton setTitle:@"Repeat Off" forState:UIControlStateNormal];
		appDelegate.repeatMode = 0;
	}
}


- (IBAction) shuffleButtonToggle
{
	if(appDelegate.isShuffle)
	{
		[shuffleButton setTitle:@"Shuffle Off" forState:UIControlStateNormal];
		appDelegate.isShuffle = NO;
	}
	else
	{
		[shuffleButton setTitle:@"Shuffle On" forState:UIControlStateNormal];
		appDelegate.isShuffle = YES;
		appDelegate.shufflePlaylist = [NSMutableArray arrayWithCapacity:[appDelegate.currentPlaylist count]];
						
		// Add all but the current playing song to the shuffled playlist
		for (id song in appDelegate.currentPlaylist)
		{
			if(![song isEqualToString:[appDelegate.currentSongObject title]])
			{
				NSUInteger randomPos = arc4random()%([appDelegate.shufflePlaylist count]+1);
				[appDelegate.shufflePlaylist insertObject:song atIndex:randomPos];
			}
		}
		
		// Add the current playing song as the first song in the shuffled playlist
		[appDelegate.shufflePlaylist insertObject:[[appDelegate.currentSongObject title] copy] atIndex:0];
		
		// Copy the currentPlaylistDict (using a separate dictionary for flexability in the future)
		appDelegate.shufflePlaylistDict = [appDelegate.currentPlaylistDict copy];
	}
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[self initInfo];
	
	CGRect frame = self.view.frame;
	frame.origin.y = 0;
	frame.origin.x = -320;
	self.view.frame = frame;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlider) name:@"updateProgress" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSongInfoFast) name:@"hideSongInfoFast" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initInfo) name:@"initSongInfo" object:nil];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	[progressSlider release];
	[elapsedTimeLabel release];
	[remainingTimeLabel release];
	[artistLabel release];
	[albumLabel release];
	[titleLabel release];
	[trackLabel release];
	[yearLabel release];
	[genreLabel release];
	[bitRateLabel release];
	[lengthLabel release];
    [super dealloc];
}


@end

