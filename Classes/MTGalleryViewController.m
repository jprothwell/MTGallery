//
//  MTGalleryViewController.m
//  MTGallery
//
//  Created by Matt Tuzzolo on 9/7/10.
//  Copyright Regulars LLC 2010. All rights reserved.
//

#import "MTGalleryViewController.h"

@implementation MTGalleryViewController

@synthesize scrollView, spinner, queue, photoUrls, currentPage;

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    /* Operation Queue init (autorelease) */
    self.queue = [NSOperationQueue new];
    [self.queue setMaxConcurrentOperationCount:2];
    
    self.photoUrls = [[[NSMutableArray alloc] init] autorelease];
    
    [photoUrls addObject:[NSURL URLWithString:@"http://www.luminous-landscape.com/images64/gallery4741-thumb.jpg"]];
    [photoUrls addObject:[NSURL URLWithString:@"http://www.secondspacegallery.com/images/Second-Space-Gallery_for-we.jpg"]];
    [photoUrls addObject:[NSURL URLWithString:@"http://images.politico.com/global/portland.jpg"]];
    [photoUrls addObject:[NSURL URLWithString:@"http://www.cape-verde-holiday.com/kitesurf.jpg"]];
    [photoUrls addObject:[NSURL URLWithString:@"http://www.reuk.co.uk/OtherImages/repower-5mw-wind-turbine.jpg"]];
    [photoUrls addObject:[NSURL URLWithString:@"http://blog.lib.umn.edu/gratt014/architecture/SolarTowerMojaveDesert.jpg"]];
    [photoUrls addObject:[NSURL URLWithString:@"http://www.treehugger.com/daylesford-organic-garden-chelsea-.jpg"]];
    
    [self resizeScrollView];
}


- (void) loadImageViewWithUrl:(NSArray *)args 
{
    UIImageView *imageView = [args objectAtIndex:0];
    NSURL *imageURL = [args objectAtIndex:1];
    
    NSLog(@"Downloading %@", [imageURL absoluteString]);
    
    //    if (!cached)
    //    {
    //        // download
    //    }
    //    else
    //    {
    //        cached
    //    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];

    // Stop spinner
    if (imageView.tag == currentPage)
    {
        [self.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    }
    
    if (data != nil)
    {
        NSLog(@"Download complete for %@", [imageURL absoluteString]);

        // Cache to FS
        // ...
        
        // Update the imageView
        [imageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:data] waitUntilDone:NO];
        
        [data release];
    }
    else
    {
        NSLog(@"Download failed for %@", [imageURL absoluteString]);
        //                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"png"];
        //                data = [[NSData alloc] initWithContentsOfFile:imagePath];
        //                [self.imageCache setObject:data forKey:[imageURL absoluteString]];
        //                [imageView setImage:[UIImage imageWithData:data]];
    }
    
    //                [imageView setImage:[UIImage imageWithData:data]];
}

- (void) resizeScrollView
{
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * [photoUrls count], self.scrollView.frame.size.height)];
}

// Trigger load of surrounding images here
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{ 
    [self loadImagesForCurrentPosition];
}

- (void)loadImagesForCurrentPosition
{
    self.currentPage = ((self.scrollView.contentOffset.x - self.scrollView.frame.size.width / 2) / self.scrollView.frame.size.width) + 2; 
    NSLog(@"current page: %d", self.currentPage);
    
    BOOL foundCurrent = NO;
    BOOL foundPrevious = NO;
    BOOL foundNext = NO;
    
    // Unload views too far away
    for (UIView *v in [self.scrollView subviews])
    {
        if (v.tag == currentPage)
        {
            foundCurrent = YES;
            continue;
        }
        
        if (v.tag == (currentPage + 1))
        {
            foundNext = YES;
            continue;
        }
        
        if (v.tag == (currentPage - 1))
        {
            foundPrevious = YES;
            continue;
        }

        // Should remove the spinner too
        [v removeFromSuperview];
    }

    if (foundCurrent == NO)
    {
        // Place spinner..
        self.spinner.frame = CGRectMake(0,0,40,40);
        self.spinner.center = CGPointMake(self.scrollView.contentOffset.x + (self.scrollView.frame.size.width / 2), self.scrollView.frame.size.height / 2);
        [self.spinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
        [self.scrollView performSelectorOnMainThread:@selector(addSubview:) withObject:self.spinner waitUntilDone:NO];
        
        
        [self queueImageRetrievalForPage:(currentPage)];
    }
    
    if (foundNext == NO)
    {
        [self queueImageRetrievalForPage:(currentPage + 1)];
    }
    
    if (foundPrevious == NO)
    {
        [self queueImageRetrievalForPage:(currentPage - 1)];
    }
}

- (void) queueImageRetrievalForPage:(NSInteger)page
{
    // Prevent bounds issues
    if (page < 1 || page > [self.photoUrls count])
    {
        return;
    }
    
    NSURL *photoURL = [self.photoUrls objectAtIndex:(page - 1)];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * (page - 1), 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = page;
    
    // Create our NSInvocationOperation to call loadDataWithOperation, passing in nil
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(loadImageViewWithUrl:)
                                                                              object:[[NSArray alloc] initWithObjects:imageView,photoURL,nil]];
    // Add the operation to the queue
    [self.queue addOperation:operation];
    [operation release];
    
    [self.scrollView addSubview:imageView];    
}



- (IBAction) closePhotos{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Clear out scrollview
    for (UIView *v in [self.scrollView subviews])
    {
        [v removeFromSuperview];
    }    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{    
    [self resizeScrollView];
    
    // Scroll Back to beginning so we're not stuck between pages
    // origin of x and y...then size...
    CGRect r = CGRectMake(self.scrollView.frame.size.width * self.currentPage,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
    
    [self.scrollView scrollRectToVisible:r animated:NO];     
    
    // rebuild contents of scrollview
    [self loadImagesForCurrentPosition];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    [spinner release];
    [super dealloc];
}

@end
