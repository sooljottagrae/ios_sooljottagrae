//
//  WritePostViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 13..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "WritePostViewController.h"
#import "RequestObject.h"
@import ImageIO;
@import AssetsLibrary;


@interface WritePostViewController ()

@property (nonatomic) NSDictionary *tags;

@property (nonatomic, weak) IBOutlet UIView *textBorderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextView *inputTextView;
@property (nonatomic) NSDictionary *outputData;

@property (nonatomic, strong) UIView *pickerSuperView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic) NSString *selectedBtnTitle;

@property (nonatomic) NSString *selectedTag;
@property (nonatomic, weak) IBOutlet UILabel *selectedAlcoholTag;
@property (nonatomic, weak) IBOutlet UILabel *selectedFoodTag;
@property (nonatomic, weak) IBOutlet UILabel *selectedLocationTag;


@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, weak) IBOutlet UILabel *adressLabel;

@property (nonatomic, weak) IBOutlet UIView *tapView;



@end

@implementation WritePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tags = @{@"술" : @[@"소주", @"맥주", @"양주", @"소맥", @"칵테일", @"6", @"7", @"8"],
                  @"안주" : @[@"치킨", @"족발", @"국밥", @"마른안주", @"감자탕", @"삼겹살", @"회"],
                  @"장소" : @[@"강남", @"여의도", @"동대문", @"이태원", @"가로수길", @"압구정로데오", @"신촌", @"홍대", @"삼성"]};
    
    [[self.textBorderView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.textBorderView layer] setBorderWidth:1];
    [[self.textBorderView layer] setCornerRadius:15];
    
    [self.imageView setImage:[UIImage imageNamed:@"imageSampleInput"]];
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapped:)];
    //tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:tapGesture];
    
    self.pickerSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    //[self.pickerView setBackgroundColor:[UIColor grayColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.pickerSuperView addSubview:self.pickerView];
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [self.toolbar setBackgroundColor:[UIColor blueColor]];
    [self.pickerSuperView addSubview:self.toolbar];
    self.doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 0, 60, 40)];
    [self.doneBtn setTitle:@"완료" forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(doneBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerSuperView addSubview:self.doneBtn];

    
    
    UITapGestureRecognizer *dismissKeyBoard;
    dismissKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard:)];
    //tapGesture.delegate = self;
    dismissKeyBoard.numberOfTapsRequired = 1;
    [self.tapView addGestureRecognizer:dismissKeyBoard];
    
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *arr;
    arr=[self.tags objectForKey:self.selectedBtnTitle];
    return arr.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.tags objectForKey:self.selectedBtnTitle][row];
}

- (IBAction)alcoholBtn:(id)sender {
    self.selectedBtnTitle = @"술";
    [self addPickerView];
    
}
- (IBAction)foodBtn:(id)sender {
    self.selectedBtnTitle = @"안주";
    [self addPickerView];
}
- (IBAction)locationBtn:(id)sender {
    self.selectedBtnTitle = @"장소";
    [self addPickerView];
}

- (void) doneBtn:(UIGestureRecognizer *)sender {
    self.selectedTag=[self.tags objectForKey:self.selectedBtnTitle][[self.pickerView selectedRowInComponent:0]];
    
    if ([self.selectedBtnTitle  isEqual: @"술"])
        self.selectedAlcoholTag.text=self.selectedTag;
    else if ([self.selectedBtnTitle  isEqual: @"안주"])
        self.selectedFoodTag.text=self.selectedTag;
    else if ([self.selectedBtnTitle  isEqual: @"장소"])
        self.selectedLocationTag.text=self.selectedTag;
    
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.pickerSuperView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2);
                     }
                     completion:^(BOOL finished){
                         [self.pickerSuperView removeFromSuperview];
                     }];
    //self.pickerSuperView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2);

}

- (void)addPickerView {
    [self.pickerView setDelegate:self];
    [self.view addSubview:self.pickerSuperView];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.pickerSuperView.frame=CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
                     }
                     completion:nil];
}



- (void) gestureTapped:(UIGestureRecognizer *)sender {
    NSLog(@"tapped");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)dismissKeyBoard:(UIGestureRecognizer *)sender {
    NSLog(@"dismissKeyBoard");
    [self.view endEditing:YES];
    
}

- (void)setPostingImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    /*
    NSData *postingImageData = UIImagePNGRepresentation(self.imageView.image);
    CGImageSourceRef source = CGImageSourceCreateWithData((CFMutableDataRef)postingImageData, NULL);
    NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));

    NSLog(@"image data %@", metadata);
    */
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    if(referenceURL) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSDictionary *metadata = rep.metadata;
            self.latitude = [[[metadata objectForKey:@"{GPS}"] objectForKey:@"Latitude"] floatValue];
            self.longitude = [[[metadata objectForKey:@"{GPS}"] objectForKey:@"Longitude"] floatValue];
            
            [self printAdress];
            
            NSLog(@"%@", [metadata objectForKey:@"{GPS}"]);
            
        } failureBlock:^(NSError *error) {
            // error handling
        }];
    }

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)exitBtn:(id)sender {
    NSData *postingImageData = UIImagePNGRepresentation(self.imageView.image);
    /*
    self.outputData = [[NSDictionary alloc] initWithObjectsAndKeys:
                       //postingImageData, @"postingImage",
                       self.inputTextView.text, @"postingText",
                       self.selectedAlcoholTag.text, @"alcoholtag",
                       self.selectedFoodTag.text, @"foodtag",
                       self.selectedLocationTag.text, @"locationtag",  nil];
     */
    
    self.outputData = [[NSDictionary alloc] initWithObjectsAndKeys:self.inputTextView.text, @"content", @"Hi", @"title", nil];
    NSLog(@"%@", self.outputData);
    
    [[RequestObject sharedInstance] sendToServer:@"/api/posts/create/"
                                      parameters:self.outputData
                                           image:self.imageView.image
                                        fileName:@"filename"
                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
                                            NSLog(@"%@",response);
                                         }
                                        progress:^(NSProgress * _Nonnull uploadProgress) {
                                            NSLog(@"sending...");
                                        }
                                            fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                            NSLog(@"%@",response);
                                            }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) printAdress {
    MKReverseGeocoder *reverseGeocoder;
    CLLocationCoordinate2D cordInfo = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:cordInfo];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"MKReverseGeocoder has failed.");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    MKPlacemark * myPlacemark = placemark;
    NSString *city = myPlacemark.thoroughfare;
    NSString *subThrough=myPlacemark.subThoroughfare;
    NSString *locality=myPlacemark.locality;
    NSString *subLocality=myPlacemark.subLocality;
    NSString *adminisArea=myPlacemark.administrativeArea;
    NSString *subAdminArea=myPlacemark.subAdministrativeArea;
    NSString *postalCode=myPlacemark.postalCode;
    NSString *country=myPlacemark.country;
    NSString *countryCode=myPlacemark.countryCode;
//    NSLog(@"city%@",city);
//    NSLog(@"subThrough%@",subThrough);
//    NSLog(@"locality%@",locality);
//    NSLog(@"subLocality%@",subLocality);
//    NSLog(@"adminisArea%@",adminisArea);
//    NSLog(@"subAdminArea%@",subAdminArea);
//    NSLog(@"postalCode%@",postalCode);
//    NSLog(@"country%@",country);
//    NSLog(@"countryCode%@",countryCode);
    
    NSString *adress = [NSString stringWithFormat:@"%@ %@ %@", adminisArea, locality, subLocality];
    self.adressLabel.text = adress;
    NSLog(@"%@", adress);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
