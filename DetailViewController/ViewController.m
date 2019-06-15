//
//  RefreshFooterView.m
//  FeedsAPP
//
//  Created by student11 on 2019/6/1.
//  Copyright © 2019 iosGroup. All rights reserved.
//

#import "ViewController.h"
#import "DetailTableViewCell.h"
#import "DetailViewModel.h"
#import <WebKit/WebKit.h>
#import "UIView+HSKit.h"
//comment
#import "CommentView.h"
/**
 * 只有WebView和TableView
 */
//app的高度
#define cl_ScreenWidth ([UIScreen mainScreen].bounds.size.width)
//app的宽度
#define cl_ScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define UIColorFromHEX(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:1.0]

static CGFloat const kBottomViewHeight = 50.0;

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,
WKNavigationDelegate,cmDelegate>

@property (nonatomic, strong) WKWebView     *webView;

@property (nonatomic, strong) UITableView   *tableView;

@property (nonatomic, strong) UIScrollView  *containerScrollView;

@property (nonatomic, strong) UIView        *contentView;
//TableViews的数据源
@property (strong, nonatomic) NSMutableArray *dataSource;
//cm
@property (nonatomic, strong) CommentView *commentView;

@end

@implementation ViewController{
    CGFloat _lastWebViewContentHeight;
    CGFloat _lastTableViewContentHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setTitle:self.title];
    [self initValue];
    [self initView];
    [self addObservers];
    [self initDataSource];
    
    NSString *path = @"";//@"https://www.jianshu.com/p/f31e39d3ce41";
    NSString *path2 = @"http://127.0.0.1/openItunes.html";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [self.webView loadRequest:request];
    //cm
    [self.view addSubview:self.commentView];
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void)dealloc{
    [self removeObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initValue{
    _lastWebViewContentHeight = 0;
    _lastTableViewContentHeight = 0;
}

- (void)initView{
    [self.contentView addSubview:self.webView];
    [self.contentView addSubview:self.tableView];
    
    [self.view addSubview:self.containerScrollView];
    [self.containerScrollView addSubview:self.contentView];

    self.contentView.frame = CGRectMake(0, 0, self.view.width, self.view.height * 2);
    self.webView.top = 0;
    self.webView.height = self.view.height;
    self.tableView.top = self.webView.bottom;
}

#pragma mark -- 初始化表格的数据源
-(void) initDataSource{
    //加载plist文件数据数组
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil]];
    _dataSource = [NSMutableArray array];
    for (NSDictionary *arr in array) {
        [_dataSource addObject:[DetailViewModel newsWithDict:arr]];
    }
}

#pragma mark - Observers
- (void)addObservers{
    [self.webView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers{
    [self.webView removeObserver:self forKeyPath:@"scrollView.contentSize"];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == _webView) {
        if ([keyPath isEqualToString:@"scrollView.contentSize"]) {
            [self updateContainerScrollViewContentSize:0 webViewContentHeight:0];
        }
    }else if(object == _tableView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self updateContainerScrollViewContentSize:0 webViewContentHeight:0];
        }
    }
}

- (void)updateContainerScrollViewContentSize:(NSInteger)flag webViewContentHeight:(CGFloat)inWebViewContentHeight{

    CGFloat webViewContentHeight = flag==1 ?inWebViewContentHeight :self.webView.scrollView.contentSize.height;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;
    
    if (webViewContentHeight == _lastWebViewContentHeight && tableViewContentHeight == _lastTableViewContentHeight) {
        return;
    }
    
    _lastWebViewContentHeight = webViewContentHeight;
    _lastTableViewContentHeight = tableViewContentHeight;
    
    self.containerScrollView.contentSize = CGSizeMake(self.view.width, webViewContentHeight + tableViewContentHeight);
    
    CGFloat webViewHeight = (webViewContentHeight < self.view.height) ?webViewContentHeight :self.view.height ;
    CGFloat tableViewHeight = tableViewContentHeight < self.view.height ?tableViewContentHeight :self.view.height;
    self.webView.height = webViewHeight <= 0.1 ?0.1 :webViewHeight;
    self.contentView.height = webViewHeight + tableViewHeight;
    self.tableView.height = tableViewHeight;
    self.tableView.top = self.webView.bottom;
    
    //Fix:contentSize变化时需要更新各个控件的位置
    [self scrollViewDidScroll:self.containerScrollView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_containerScrollView != scrollView) {
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    CGFloat webViewHeight = self.webView.height;
    CGFloat tableViewHeight = self.tableView.height;
    
    CGFloat webViewContentHeight = self.webView.scrollView.contentSize.height;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;
    
    if (offsetY <= 0) {
        self.contentView.top = 0;
        self.webView.scrollView.contentOffset = CGPointZero;
        self.tableView.contentOffset = CGPointZero;
    }else if(offsetY < webViewContentHeight - webViewHeight){
        self.contentView.top = offsetY;
        self.webView.scrollView.contentOffset = CGPointMake(0, offsetY);
        self.tableView.contentOffset = CGPointZero;
    }else if(offsetY < webViewContentHeight){
        self.contentView.top = webViewContentHeight - webViewHeight;
        self.webView.scrollView.contentOffset = CGPointMake(0, webViewContentHeight - webViewHeight);
        self.tableView.contentOffset = CGPointZero;
    }else if(offsetY < webViewContentHeight + tableViewContentHeight - tableViewHeight){
        self.contentView.top = offsetY - webViewHeight;
        self.tableView.contentOffset = CGPointMake(0, offsetY - webViewContentHeight);
        self.webView.scrollView.contentOffset = CGPointMake(0, webViewContentHeight - webViewHeight);
    }else if(offsetY <= webViewContentHeight + tableViewContentHeight ){
        self.contentView.top = self.containerScrollView.contentSize.height - self.contentView.height;
        self.webView.scrollView.contentOffset = CGPointMake(0, webViewContentHeight - webViewHeight);
        self.tableView.contentOffset = CGPointMake(0, tableViewContentHeight - tableViewHeight);
    }else {
        //do nothing
        NSLog(@"do nothing");
    }
}

#pragma mark - UITableViewDataSouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //DetailTableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    //return cell.frame.size.height;
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell"];
    if (cell == nil) {
        cell = [[DetailTableViewCell alloc] initWithReuseIdentifier:@"DetailTableViewCell"];
    }
    DetailViewModel *theModel = _dataSource[indexPath.row];
    cell.model = theModel;
    return cell;
}

#pragma mark - private
- (WKWebView *)webView{
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.scrollView.scrollEnabled = NO;
        _webView.navigationDelegate = self;
    }
    
    return _webView;
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = YES;

    }
    return _tableView;
}

- (UIScrollView *)containerScrollView{
    if (_containerScrollView == nil) {
        _containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _containerScrollView.delegate = self;
        _containerScrollView.alwaysBounceVertical = YES;
    }
    
    return _containerScrollView;
}

- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
    }
    
    return _contentView;
}


//cm

- (void)cl_textViewDidChange:(textView *)textView {
    if (textView.commentTextView.text.length > 0) {
        NSString *originalString = [NSString stringWithFormat:@"[草稿]%@",textView.commentTextView.text];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:originalString];
        //kColorNavigationBar
        [attriString addAttributes:@{NSForegroundColorAttributeName: UIColorFromHEX(0xf26220)} range:NSMakeRange(0, 4)];
        //main text color
        [attriString addAttributes:@{NSForegroundColorAttributeName: UIColorFromHEX(0x333333)} range:NSMakeRange(4, attriString.length - 4)];
        
        self.commentView.editTextField.attributedText = attriString;
    }
}

- (CommentView *)commentView {
    if (!_commentView) {
        //, [UIScreen mainScreen].bounds.size.width - kBottomViewHeight
        _commentView = [[CommentView alloc] initWithFrame:CGRectMake(0, cl_ScreenHeight - kBottomViewHeight, cl_ScreenWidth, kBottomViewHeight)];
        _commentView.delegate = self;
        _commentView.clTextView.delegate = self;
    }
    return _commentView;
}

- (void)cl_textViewDidEndEditing:(textView *)textView {
    NSLog(textView.commentTextView.text);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.commentView clearComment];
    });
    
    DetailViewModel *model = [DetailViewModel newsWithStr:textView.commentTextView.text];
    [_dataSource addObject:model];
   /*
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths  objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"data.plist"];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:textView.commentTextView.text,@"title",nil]; //写入数据
    [dic writeToFile:filename atomically:YES];
    */
    /*
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data.plist" ofType:nil]];
    _dataSource = [NSMutableArray array];
    //for (NSDictionary *arr in array) {
    //    [_dataSource addObject:[DetailViewModel newsWithDict:arr]];
    //}
    
    //NSDictionary *arr =[NSDictionary dictionary];
    //[arr setValue:textView.commentTextView.text forKey:@"title"];
    
    // [_dataSource addObject:[DetailViewModel newsWithDict:arr]];
     */
    
    
    [self.tableView reloadData];
    
}

@end
