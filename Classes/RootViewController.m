//
//  RootViewController.m
//  iSub
//
//  Created by Ben Baron on 2/27/10.
//  Copyright Ben Baron 2010. All rights reserved.
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

#import "RootViewController.h"
#import "iSubAppDelegate.h"
#import "iPhoneStreamingPlayerViewController.h"
#import "SettingsViewController.h"
#import "XMLParser.h"
#import "AlbumViewController.h"
#import "Artist.h"


@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.title = @"Index";
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsAction:)] autorelease];
			
	if (appDelegate.listOfArtists == nil)
	{
		appDelegate.parseState = @"artists";
		//NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:[appDelegate getBaseUrl:@"getIndexes.view"]]];
		NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:[appDelegate getBaseUrl:@"getIndexes.view"]]];
		
		//Initialize the delegate.
		XMLParser *parser = [[XMLParser alloc] initXMLParser];
	
		//Set delegate
		[xmlParser setDelegate:parser];
	
		//Start parsing the XML file.
		if([xmlParser parse])
			NSLog(@"No Errors");
		else
			NSLog(@"Error Error Error!!!");	
		
		[xmlParser release];
		[parser release];
	}
	
	//Initialize the copy array.
	copyListOfArtists = [[NSMutableArray alloc] init];
	
	//Add the search bar
	self.tableView.tableHeaderView = searchBar;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		
	searching = NO;
	letUserSelectRow = YES;
}


-(void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	if(appDelegate.viewHistory)
		[appDelegate.viewHistory release];
	appDelegate.viewHistory = [[NSMutableDictionary alloc] init];
	
	if(appDelegate.streamer)
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingAction:)] autorelease];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[appDelegate dealloc];
    [super dealloc];
}


#pragma mark -
#pragma mark Button handling methods


- (void) doneSearching_Clicked:(id)sender {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsAction:)] autorelease];
	self.tableView.scrollEnabled = YES;
	
	[self.tableView reloadData];
}


- (void) settingsAction:(id)sender 
{
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[appDelegate.window addSubview:[settingsViewController view]];
	[appDelegate.window makeKeyAndVisible];
	[self.view removeFromSuperview];
	//[settingsViewController release];
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


#pragma mark -
#pragma mark Tableview methods


- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar 
{
	searching = YES;
	letUserSelectRow = NO;
	self.tableView.scrollEnabled = NO;
	
	//Add the done button.
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSearching_Clicked:)] autorelease];
}


- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
	//Remove all objects first.
	[copyListOfArtists removeAllObjects];
	
	if([searchText length] > 0) 
	{
		searching = YES;
		letUserSelectRow = YES;
		self.tableView.scrollEnabled = YES;
		[self searchTableView];
	}
	else 
	{
		searching = NO;
		letUserSelectRow = NO;
		self.tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[self searchTableView];
	//[searchBar resignFirstResponder];
}

- (void) searchTableView {
	
	NSString *searchText = searchBar.text;
	NSMutableArray *searchArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *dictionary in appDelegate.listOfArtists)
	{
		NSArray *array = [dictionary objectForKey:@"Artists"];
		[searchArray addObjectsFromArray:array];
	}
	
	for (NSString *sTemp in searchArray)
	{
		NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[copyListOfArtists addObject:sTemp];
	}
	
	[searchArray release];
	searchArray = nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if (searching)
		return 1;
	else
		return [appDelegate.listOfArtists count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (searching)
	{
		return [copyListOfArtists count];
	}
	else 
	{
		//Number of rows it should expect should be based on the section
		NSDictionary *dictionary = [appDelegate.listOfArtists objectAtIndex:section];
		NSArray *array = [[[NSArray alloc] init] autorelease];
		array = [dictionary objectForKey:@"Artists"];
		return [array count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	if(searching)
	{
		[cell.textLabel setText:[copyListOfArtists objectAtIndex:indexPath.row]];
	}
	else
	{
		//First get the dictionary that contains the artists from that section from the listOfArtists array
		NSDictionary *dictionary = [appDelegate.listOfArtists objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Artists"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		[cell.textLabel setText:cellValue];
	}
	
	cell.backgroundView = [[[UIView alloc] init] autorelease];
	cell.backgroundView.backgroundColor = [UIColor whiteColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(searching)
		return @"";
	
	return [appDelegate.indexes objectAtIndex:section];
}


// Following 2 methods handle the right side index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	
	if(searching)
		return nil;
	else
	{
		NSMutableArray *searchIndexes = [[[NSMutableArray alloc] init] autorelease];
		[searchIndexes addObject:@"{search}"];
		[searchIndexes addObjectsFromArray:appDelegate.indexes];
		return searchIndexes;
	}
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	
	if(searching)
		return -1;
	
	if (index == 0) 
	{
		[tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
		return -1;
	}
	
	return index - 1;
}


- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(letUserSelectRow)
		return indexPath;
	else
		return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	appDelegate.isTopLevel = YES;
	
	if(searching)
	{
		NSString *cellValue = [copyListOfArtists objectAtIndex:indexPath.row];
		if (appDelegate.artistObject)
			[appDelegate.artistObject release];
		appDelegate.artistObject = [[Artist alloc] init];
		[appDelegate.artistObject setName:cellValue];
		[appDelegate.artistObject setArtistId:[appDelegate.dictOfArtists objectForKey:cellValue]];
	}
	else 
	{	
		NSDictionary *dictionary = [appDelegate.listOfArtists objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Artists"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		if (appDelegate.artistObject)
			[appDelegate.artistObject release];
		appDelegate.artistObject = [[Artist alloc] init];
		[appDelegate.artistObject setName:cellValue];
		[appDelegate.artistObject setArtistId:[appDelegate.dictOfArtists objectForKey:cellValue]];
	}
	
	appDelegate.currentId = [appDelegate.artistObject artistId];
	if ([appDelegate.albumListCache objectForKey:[appDelegate.artistObject artistId]] == nil)
	{
		NSString *urlString = [appDelegate getBaseUrl:@"getMusicDirectory.view"];
		urlString2 = [urlString stringByAppendingString:[appDelegate.artistObject artistId]];
		url = [[NSURL alloc] initWithString:urlString2];
	
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
		
		appDelegate.listOfAlbums = [[cache objectAtIndex:0] retain];
		appDelegate.dictOfAlbums = [[cache objectAtIndex:1] retain];
		appDelegate.listOfSongs = [[cache objectAtIndex:2] retain];
		appDelegate.dictOfSongs = [[cache objectAtIndex:3] retain];
	}

		
	AlbumViewController *albumViewController = [[AlbumViewController alloc] initWithNibName:@"AlbumViewController" bundle:nil];
	[self.navigationController pushViewController:albumViewController animated:YES];
	[albumViewController release];
}


@end

