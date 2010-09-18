//
//  MTGalleryViewController.h
//  MTGallery
//
//  Created by Matt Tuzzolo on 9/7/10.
//  Copyright Regulars LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTScrollView.h"

@protocol MTGalleryDelegate

- (void) touchOnItemWithIndex:(NSInteger)index;

@end

@interface MTGalleryViewController : UIViewController <UIScrollViewDelegate, MTGalleryDelegate> {
    id delegate;    
    IBOutlet MTScrollView *scrollView;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UILabel *pageLabel;
    NSOperationQueue *queue;
    NSMutableArray *photoUrls;
    NSInteger currentPage;
    NSArray *captions;
    IBOutlet UITextView *captionTextView;
}

@property (nonatomic, assign) id <MTGalleryDelegate> delegate;
@property (nonatomic,retain) IBOutlet MTScrollView *scrollView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,retain) IBOutlet UILabel *pageLabel;
@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,retain) NSMutableArray *photoUrls;
@property NSInteger currentPage;;
@property (nonatomic,assign) NSArray *captions;
@property (nonatomic,retain) IBOutlet UITextView *captionTextView;

- (IBAction) closePhotos;
- (void) resizeScrollView;
- (void) loadImageViewWithUrl:(NSArray *)args;
- (void) queueImageRetrievalForPage:(NSInteger)page;
- (void)loadImagesForCurrentPosition;
- (MTGalleryViewController *)initWithPhotos:(NSArray *)photoURLStrings andCaptions:(NSArray *)captions;

@end

