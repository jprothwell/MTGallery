//
//  MTGalleryViewController.h
//  MTGallery
//
//  Created by Matt Tuzzolo on 9/7/10.
//  Copyright Regulars LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTGalleryViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIActivityIndicatorView *spinner;
    NSOperationQueue *queue;
    NSMutableArray *photoUrls;
    NSInteger currentPage;
}

@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,retain) NSMutableArray *photoUrls;
@property NSInteger currentPage;;

- (IBAction) closePhotos;
- (void) resizeScrollView;
- (void) loadImageViewWithUrl:(NSArray *)args;
- (void) queueImageRetrievalForPage:(NSInteger)page;
- (void)loadImagesForCurrentPosition;

@end

