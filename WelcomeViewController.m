//
//  WelcomeViewController.m
//  MTGallery
//
//  Created by Matt Tuzzolo on 5/5/10.
//  Copyright 2010 Regulars LLC. All rights reserved.
//

#import "MTGalleryAppDelegate.h"
#import "WelcomeViewController.h"
#import "MTGalleryViewController.h"

@implementation WelcomeViewController

- (IBAction) launchGallery:(id)sender
{
    // Make sure to hide the status bar before called presentModalViewController (and not withing MTGalleryViewController itself).
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    NSMutableArray *myPhotos = [[NSMutableArray alloc] init];
    [myPhotos addObject:@"http://www.luminous-landscape.com/images64/gallery4741-thumb.jpg"];    
    [myPhotos addObject:@"http://www.secondspacegallery.com/images/Second-Space-Gallery_for-we.jpg"];
    [myPhotos addObject:@"http://images.politico.com/global/portland.jpg"];
    [myPhotos addObject:@"http://www.cape-verde-holiday.com/kitesurf.jpg"];
    [myPhotos addObject:@"http://www.reuk.co.uk/OtherImages/repower-5mw-wind-turbine.jpg"];
    [myPhotos addObject:@"http://www.luminous-landscape.com/images64/gallery4741-thumb.jpg"];    
    [myPhotos addObject:@"http://www.secondspacegallery.com/images/Second-Space-Gallery_for-we.jpg"];
    
    NSMutableArray *myCaptions = [[NSMutableArray alloc] init];
    [myCaptions addObject:@"Gallery 1"];    
    [myCaptions addObject:@"Gallery 2"];
    [myCaptions addObject:@"Portland"];
    [myCaptions addObject:@"Kiting"];
    [myCaptions addObject:@"Energy"];
    
    MTGalleryViewController *controller = [[MTGalleryViewController alloc] initWithPhotos:myPhotos andCaptions:myCaptions];    
    
    [self presentModalViewController:controller animated:YES];	
    
    [myPhotos release];
    [myCaptions release];
    
    [controller release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
