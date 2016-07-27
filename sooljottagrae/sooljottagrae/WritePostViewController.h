//
//  WritePostViewController.h
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 13..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>


@interface WritePostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) NSString *postId;

@end
