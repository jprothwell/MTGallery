//
//  MTGalleryAppDelegate.h
//  MTGallery
//
//  Created by Matt Tuzzolo on 9/7/10.
//  Copyright Regulars LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeViewController.h"

@interface MTGalleryAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WelcomeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WelcomeViewController *viewController;

@end

