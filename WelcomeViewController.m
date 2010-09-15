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

    MTGalleryViewController *controller = [[MTGalleryViewController alloc] initWithNibName:@"MTGalleryViewController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController:controller animated:YES];	
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
