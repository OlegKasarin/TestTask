//
//  ViewController.m
//  TestTask
//
//  Created by apple on 15.04.16.
//  Copyright © 2016 OlegKasarin. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString:@"https://devimages.apple.com.edgekey.net/wwdc-services/ftzj8e4h/6rsxhod7fvdtnjnmgsun/videos.json"] //2

#import "ViewController.h"
#import "ViewCell.h"
#import "UIView+UITableViewCell.h"
#import "VideoObject.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) NSMutableArray* tableViewData;

@property (nonatomic) NSMutableData* receivedData;

@property (nonatomic) NSIndexPath* currentIndexCell;
//@property (assign, nonatomic) float expectedBytes;

@end

@implementation ViewController

- (void) loadView {
    [super loadView];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: kLatestKivaLoansURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];});
    
    self.tableViewData = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.navigationItem.title = @"Downloads";
    
    UIBarButtonItem* downloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionDownload:)];
    
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefresh:)];
    
    self.navigationItem.rightBarButtonItem = downloadButton;
    self.navigationItem.leftBarButtonItem = refreshButton;

}

- (void) fetchedData: (NSData*) responseData {
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];

    NSArray* sessions = [json objectForKey:@"sessions"];
    NSMutableArray* list = [[NSMutableArray alloc] init];
    
   
    
    for (int i = 0; i < 15; i++) {  //for (int i = 0; i < [sessions count]; i++) {

        NSMutableDictionary* session = [sessions objectAtIndex:i];
        NSString* title = [session objectForKey:@"title"];
        NSString* link = [session objectForKey:@"download_sd"];
    
        if ([link isKindOfClass: [NSNull class]])
            continue;
    
        //define file size by link
        NSURL* URL = [NSURL URLWithString:link];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:@"HEAD"];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: nil];
        
        
        double size = [response expectedContentLength];
        
        VideoObject* video = [[VideoObject alloc] init];
        [video setName:title];
        [video setLink:link];
        [video setSize: size];
        [video setStatus: 0];
        [video setDownloaded:0];

        
        if (![link  isKindOfClass:[NSNull class]] && [[link substringFromIndex: (link.length - 4)] isEqual: @".mp4"]) {
            [list addObject:video];
        }
        else {
            continue;
        }
        
    }
    
    //set array of videos
    [self setTableViewData:list];
    
    
    //reload data table
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions


- (void) actionDownload: (UIBarButtonItem*) sender {
    NSLog(@"Starting download the first ten items:");
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    for (int i = 0; i < 10; i++) {

        indexPath = [NSIndexPath indexPathForRow:i inSection:0];

        ViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self startDownload:cell];
    }
    
}

- (void) actionRefresh: (UIBarButtonItem*) sender {
    NSLog(@"tableView is refreshed");
    [self.tableView reloadData];
}


- (void) startDownload: (ViewCell*) cell {
    
    self.currentIndexCell = [self.tableView indexPathForCell:cell];
    
    VideoObject* object = (VideoObject*)cell.relatedObject;
    
    
    if (object.status == defaultState) {
        //start download
        [cell.downloadButton setTitle:@"Paused" forState:UIControlStateNormal];
        object.status = downloadingState;
        
        
        [self downloadWithNSURLConnection];
        
        
    } else if (object.status == downloadingState){
        //set pause
        object.status = pausedState;
        [cell.downloadButton setTitle:@"Resume" forState:UIControlStateNormal];


    } else if (object.status == pausedState){
        //resume download
        object.status = downloadingState;
        [cell.downloadButton setTitle:@"Paused" forState:UIControlStateNormal];

        NSLog(@"%@. Status: %u, %f / %f", object.name, object.status, object.downloaded, object.size);

    } else {
        //delete downloaded
        object.status = deletedState;
        [cell.downloadButton setTitle:@"Delete" forState:UIControlStateNormal];


    }
    
    [self.tableView reloadData];

}


#pragma mark - NSURLConnectionDataDelegate

- (void) downloadWithNSURLConnection {
    
    ViewCell* cell = [self.tableView cellForRowAtIndexPath:self.currentIndexCell];
    
    VideoObject* object = (VideoObject*)cell.relatedObject;

    
    NSURL *url = [NSURL URLWithString:object.link];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    self.receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    NSLog(@"downloadWithNSURLConnection: %f, %@", object.size, object.name);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    ViewCell* cell = [self.tableView cellForRowAtIndexPath:self.currentIndexCell];
    VideoObject* object = (VideoObject*)cell.relatedObject;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    cell.progressBar.hidden = NO;
    [self.receivedData setLength:0];
    object.size = [response expectedContentLength];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    ViewCell* cell = [self.tableView cellForRowAtIndexPath:self.currentIndexCell];
    VideoObject* object = (VideoObject*)cell.relatedObject;
    
    [self.receivedData appendData:data];
    
    object.downloaded = [self.receivedData length];

    cell.progressBar.progress = (float) object.downloaded / (float) object.size;
    
    cell.statusLabel.text = [NSString stringWithFormat:@"%@" , object.subtitleString];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    ViewCell* cell = [self.tableView cellForRowAtIndexPath:self.currentIndexCell];
    VideoObject* object = (VideoObject*)cell.relatedObject;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[object.link stringByAppendingString:@".mp4"]];
    NSLog(@"Succeeded! Received %d bytes of data", [self.receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.receivedData writeToFile:pdfPath atomically:YES];
    cell.progressBar.hidden = YES;
    
    object.status = downloadedState;
    
    cell.statusLabel.text = [NSString stringWithFormat:@"%@" , object.subtitleString];

}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableViewData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* indentifier = @"Cell";
    
    ViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];

    if (!cell) {
        cell = [[ViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:indentifier];
        
    }
    
    VideoObject* video = [self.tableViewData objectAtIndex:indexPath.row];
    
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", video.titleString];
    cell.progressBar.progress = 0;
    cell.statusLabel.text = [NSString stringWithFormat:@"%@" , video.subtitleString];
    cell.delegate = self;
    
    cell.relatedObject = video;
    
    return cell;
}

@end
