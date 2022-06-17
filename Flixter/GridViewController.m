//
//  GridViewController.m
//  Flixter
//
//  Created by Mitchel Igolimah on 6/17/22.
//

#import "GridViewController.h"
#import "CollectionViewGridCell.h"
#import "UIImageView+AFNetworking.h"

@interface GridViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong )NSArray *movieArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies)forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    
    //Activity Indicator.
    [self.activityIndicator startAnimating];

    // Stop the activity indicator
    // Hides automatically if "Hides When Stopped" is enabled
    [self.activityIndicator stopAnimating];
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=043cf69f9597ab9a0a63b5c570ef7a7f"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               
               if (error.code == -1009){
                   UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                  message:@"No Internet Connection."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                   UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {[self fetchMovies];  }];
                    
                   [alert addAction:defaultAction];
                   [self presentViewController:alert animated:YES completion:nil];

                   
                   
               }
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", dataDictionary);
               
               
               // TODO: Get the array of movies
               self.movieArray = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movieArray) {
               NSLog(@"%@", movie[@"title"]);
               }
               
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
               [self.collectionView reloadData];
           }
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movieArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewGridCell" forIndexPath:indexPath];
    
    NSDictionary *movies = self.movieArray[indexPath.item];
      
      
      
      NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
      NSString *posterURLString = movies[@"poster_path"];
      NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
      
      NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
      [cell.posterView setImageWithURL:posterURL];
   
    
    return cell;
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
