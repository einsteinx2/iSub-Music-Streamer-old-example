//
//  AlbumUITableViewCell.m
//  iSub
//
//  Created by Ben Baron on 3/20/10.
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

#import "AlbumUITableViewCell.h"
#import "AsynchronousImageViewCached.h"

@implementation AlbumUITableViewCell

@synthesize coverArtView, albumNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
				
		// we need a view to place our labels on.
		UIView *myContentView = self.contentView;
		
		self.coverArtView = [[AsynchronousImageViewCached alloc] init];
		[myContentView addSubview:self.coverArtView];
		[self.coverArtView release];
		
		self.albumNameLabel = [[UILabel alloc] init];
		self.albumNameLabel.textAlignment = UITextAlignmentLeft; // default
		self.albumNameLabel.font = [UIFont boldSystemFontOfSize:20];
		[myContentView addSubview:self.albumNameLabel];
		[self.albumNameLabel release];
	}
	
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
	
    [super layoutSubviews];
		
	self.albumNameLabel.frame = CGRectMake(65, 0, 240, 60);
	self.coverArtView.frame = CGRectMake(0, 0, 60, 60);
}


- (void)dealloc {
	[albumNameLabel release];
	[coverArtView release];
    [super dealloc];
}


@end
