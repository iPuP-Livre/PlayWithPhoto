//
//  ViewController.m
//  PlayWithPhoto
//
//  Created by Marian PAUL on 10/03/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // la vue qui affichera l'image en fond
    _imageViewBackgroundPhoto = [[UIImageView alloc] initWithFrame:self.view.bounds];
    // on ne met pas d'image ici 
    [self.view addSubview:_imageViewBackgroundPhoto];
    
    // bouton pour prendre la photo
    UIButton *buttonTakePhotoFromCamera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonTakePhotoFromCamera setFrame:CGRectMake(30, 430, 80, 30)];
    [buttonTakePhotoFromCamera addTarget:self action:@selector(showCameraPicker:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTakePhotoFromCamera setTitle:@"Photo" forState:UIControlStateNormal];
    [self.view addSubview:buttonTakePhotoFromCamera];
    
    // si on ne peut pas prendre de photo, on cache le bouton
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        buttonTakePhotoFromCamera.hidden = YES;
    
    // bouton pour prendre une photo depuis l'album
    UIButton *buttonTakePhotoFromAlbum = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonTakePhotoFromAlbum setFrame:CGRectMake(120, 430, 80, 30)];
    [buttonTakePhotoFromAlbum addTarget:self action:@selector(showPhotoAlbumPicker:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTakePhotoFromAlbum setTitle:@"Album" forState:UIControlStateNormal];
    [self.view addSubview:buttonTakePhotoFromAlbum];
    
    // si on ne peut pas accéder à l'album photo, on cache le bouton
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        buttonTakePhotoFromAlbum.hidden = YES;

    // trouvée sur http://www.iconfinder.com Auteur Everaldo Coelho
    _funnyImage = [UIImage imageNamed:@"shot.png"];
    
    // bouton pour sauver la photo
    UIButton *buttonSavePhoto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonSavePhoto setFrame:CGRectMake(210, 430, 80, 30)];
    [buttonSavePhoto addTarget:self action:@selector(savePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSavePhoto setTitle:@"Sauver" forState:UIControlStateNormal];
    [self.view addSubview:buttonSavePhoto];


}

#pragma mark -Action methods

- (void) showCameraPicker:(id)sender 
{
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera; // [1]
    picker.delegate = self; // [2]
    picker.allowsEditing = NO; // [3]
    
    //on affiche le picker
    [self presentModalViewController:picker animated:YES];
}

- (void) showPhotoAlbumPicker:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    //on affiche le picker
    [self presentModalViewController:picker animated:YES];
}

- (void) savePhoto:(id)sender 
{
    // on va prendre une capture écran
    // on cache toutes les vues sauf les image view
    for (UIView *vi in [self.view subviews])
        if (![vi isKindOfClass:[UIImageView class]])
            [vi setHidden:YES];
    
    // on fait la capture écran, et on fait attention à la résolution de l'écran ! (À cause des écrans retina)
    CGRect screenRect = [[UIScreen mainScreen] bounds];     
    CGFloat scale = -1.0;
    
    if (scale<0.0) {
        UIScreen *screen = [UIScreen mainScreen];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
            scale = [screen scale];
        }
        else {
            scale = 0.0;	// utilisation de la vieille API
        }
    }
    if (scale>0.0) {
        UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, scale);
    }
    else {
        UIGraphicsBeginImageContext(screenRect.size);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:ctx];
    
    UIImage *capturedimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(capturedimage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - Image picker delegate 
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    // on enlève la vue
    [self dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo 
{
    
    _imageViewBackgroundPhoto.image = image;
    
    // on enlève la vue
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Sauvegarde

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *) error contextInfo:(void *)contextInfo 
{
    NSLog(@"Image sauvée");
    // on remet tous les boutons
    for (UIView *vi in [self.view subviews])
        vi.hidden = NO;
}

#pragma mark - Gestion de la secousse

- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated 
{
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        // on fait une copie des sous vues de la vue du contrôleur
        NSArray *arrayOfSubviews = [self.view subviews];
        // on énumère toutes les image view
        for (UIView *vi in arrayOfSubviews)
        {
            // si ce sont des seringues, on les enlève
            if ([vi isKindOfClass:[UIImageView class]])
                if (((UIImageView*)vi).image == _funnyImage)
                    [vi removeFromSuperview];
        }
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Gestion du touch

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    // on récupère les coordonnées dans la vue
    CGPoint touchCoordinates = [touch locationInView:self.view];    
    // on crée une nouvelle image view
    UIImageView *shot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    shot.image = _funnyImage;
    // on centre par rapport au doigt
    shot.center = touchCoordinates;
    [self.view addSubview:shot];
}

@end
