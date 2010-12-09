//
//  MTGalleryViewController.m
//  MTGallery
//
//  Created by Matt Tuzzolo on 9/7/10.
//  Copyright Regulars LLC 2010. All rights reserved.
//

#import "MTGalleryViewController.h"

@implementation MTGalleryViewController

@synthesize scrollView, spinner, queue, photoUrls, currentPage, delegate, captions, captionTextView, pageLabel;

- (MTGalleryViewController *)initWithPhotos:(NSArray *)photoURLStrings andCaptions:(NSArray *)myCaptions
{
    self = [super init];

    captions = [myCaptions copy];

    photoUrls = [[NSMutableArray alloc] init];
    
    for (NSString *photoURLString in photoURLStrings)
    {
        [photoUrls addObject:[NSURL URLWithString:photoURLString]];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    
    /* Operation Queue init (autorelease) */
    self.queue = [NSOperationQueue new];
    [self.queue setMaxConcurrentOperationCount:1];
    
    [self resizeScrollView];
}

- (NSString *) pathForCachedUrl:(NSString *)urlString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

    return [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], [[urlString componentsSeparatedByString:@"/"] lastObject]];
}

- (void) loadImageViewWithUrl:(NSArray *)args 
{
    UIImageView *imageView = [args objectAtIndex:0];
    NSURL *imageURL = [args objectAtIndex:1];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = nil;
    
    NSString *filePath = [self pathForCachedUrl:[imageURL absoluteString]];
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSLog(@"Using cached file!");
        data = [NSData dataWithContentsOfFile:filePath];
        [imageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:data] waitUntilDone:NO];
    }
    else
    {
        // Download        
        NSLog(@"Downloading %@", [imageURL absoluteString]);
        data = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        // Stop spinner
        if (data != nil)
        {
            NSLog(@"Download complete for %@", [imageURL absoluteString]);
            
            // Cache to FS            
            [fileManager createFileAtPath:filePath contents:data attributes:nil];
            
            // Update the imageView
            [imageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:data] waitUntilDone:NO];
            
            [data release];
        }
        else
        {
            NSLog(@"Download failed for %@", [imageURL absoluteString]);
            [imageView performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"MTGallery_image_not_found"] waitUntilDone:NO];
        }        
    }
    
    if (imageView.tag == currentPage)
    {
        [self.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    }
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
    
    BOOL foundCurrent = NO;
    BOOL foundPrevious = NO;
    BOOL foundNext = NO;
    
    // Send these to the back
    [self.scrollView sendSubviewToBack:self.captionTextView];
    [self.scrollView sendSubviewToBack:self.spinner];
    [self.scrollView sendSubviewToBack:self.pageLabel];
    
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

        // Remove images
        if (v.tag != 0)
        {
            [v removeFromSuperview];
        }
    }
    
    // Bring back
    [self.scrollView bringSubviewToFront:self.captionTextView];
    [self.scrollView bringSubviewToFront:self.spinner];
    [self.scrollView bringSubviewToFront:self.pageLabel];
    
    
    // Reposition pageLabel
    self.pageLabel.center = CGPointMake(self.scrollView.contentOffset.x + (self.scrollView.frame.size.width / 2), self.pageLabel.center.y);
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%d", self.currentPage, [self.photoUrls count]];
    
    // Reposition caption
    self.captionTextView.center = CGPointMake(self.scrollView.contentOffset.x + (self.scrollView.frame.size.width / 2), self.captionTextView.center.y);

    // Reposition spinner
    self.spinner.center = CGPointMake(self.scrollView.contentOffset.x + (self.scrollView.frame.size.width / 2), self.scrollView.frame.size.height / 2);
    
    
    // Protect again out of bounds.
    if (self.currentPage <= [self.captions count])
    {
        self.captionTextView.hidden = NO;
        self.captionTextView.text = [self.captions objectAtIndex:self.currentPage - 1];
    }
    else
    {
        self.captionTextView.hidden = YES;
    }

    
    // Load Images    
    if (foundCurrent == NO)
    {
        // Start animating
        [self.spinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];

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
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor clearColor];
    
    [self.scrollView bringSubviewToFront:self.captionTextView];
    [self.scrollView bringSubviewToFront:self.spinner];
    [self.scrollView bringSubviewToFront:self.pageLabel];
    
    // Create our NSInvocationOperation to call loadDataWithOperation, passing in nil
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(loadImageViewWithUrl:)
                                                                              object:[NSArray arrayWithObjects:imageView,photoURL,nil]];
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
        if (v.tag != 0)
        {
            [v removeFromSuperview];
            v = nil;
        }
    }    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{    
    [self resizeScrollView];
    
    // Scroll Back to beginning so we're not stuck between pages
    // origin of x and y...then size...
    CGRect r = CGRectMake(0,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);    
    [self.scrollView scrollRectToVisible:r animated:NO];     

    r = CGRectMake(self.scrollView.frame.size.width * (self.currentPage - 1),0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);        
    [self.scrollView scrollRectToVisible:r animated:NO];     
    
    // rebuild contents of scrollview
    [self loadImagesForCurrentPosition];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    // Ignore touches while scrollview is moving
    if (self.scrollView.decelerating)
    {
        return;
    }
    
    UITouch *touch = [[event allTouches] anyObject];
    
    NSInteger itemIndex = [touch view].tag - 1;
    
    // Must be a better way to do this
    if ([[touch view] isKindOfClass:[UIImageView class]] && [touch view].tag > 0)
    {
        if (itemIndex < 0 || itemIndex >= [self.photoUrls count])
        {
            NSLog(@"Out of bounds");
            return;
        }    
        
        [self.delegate touchOnItemWithIndex:itemIndex];
    }
}

# pragma mark -
# pragma mark MTGalleryDelegate Methods

- (void) touchOnItemWithIndex:(NSInteger)index
{
    NSLog(@"touch on item with index: %d", index);
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
    
    [captionTextView release];
    [photoUrls release];
    [spinner release];
    [super dealloc];
}

@end
