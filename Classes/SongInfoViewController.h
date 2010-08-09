//
//  SongInfoViewController.h
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

#import <UIKit/UIKit.h>

@class iSubAppDelegate;

@interface SongInfoViewController : UIViewController {
	iSubAppDelegate *appDelegate;
	
	IBOutlet UIButton *songInfoToggleButton;
	IBOutlet UISlider *progressSlider;
	IBOutlet UILabel *progressLabel;
	IBOutlet UIImageView *progressLabelBackground;
	IBOutlet UILabel *elapsedTimeLabel;
	IBOutlet UILabel *remainingTimeLabel;
	IBOutlet UILabel *artistLabel;
	IBOutlet UILabel *albumLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *trackLabel;
	IBOutlet UILabel *yearLabel;
	IBOutlet UILabel *genreLabel;
	IBOutlet UILabel *bitRateLabel;
	IBOutlet UILabel *lengthLabel;
	IBOutlet UIButton *repeatButton;
	IBOutlet UIButton *shuffleButton;

}

@property (nonatomic, retain) UISlider *progressSlider;
@property (nonatomic, retain) UILabel *elapsedTimeLabel;
@property (nonatomic, retain) UILabel *remainingTimeLabel;
@property (nonatomic, retain) UILabel *artistLabel;
@property (nonatomic, retain) UILabel *albumLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *trackLabel;
@property (nonatomic, retain) UILabel *yearLabel;
@property (nonatomic, retain) UILabel *genreLabel;
@property (nonatomic, retain) UILabel *bitRateLabel;
@property (nonatomic, retain) UILabel *lengthLabel;
@property (nonatomic, retain) UIButton *repeatButton;
@property (nonatomic, retain) UIButton *shuffleButton;

- (void)initInfo;
- (void)updateSlider;
- (void)showSongInfo;
- (void)hideSongInfo;
- (void)hideSongInfoFast;
- (IBAction)songInfoToggle;
- (IBAction)repeatButtonToggle;
- (IBAction)shuffleButtonToggle;
- (IBAction)touchedSlider;
- (IBAction)movingSlider;
- (IBAction)movedSlider;

@end
