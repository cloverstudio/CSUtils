//
//  CSMessage.m
//  StoragePipe
//
//  Created by Josip Bernat on 10/01/14.
//
//

#import "CSMessage.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CSUReachability.h"
#import "CSMessageCenter.h"

//String Encoding
NSString * CSURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)kAFLegalCharactersToBeEscaped,
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

//Notifications
NSString * const CSMessageInternerDidBecomeAvailableNotification    = @"CSMessageInternerDidBecomeAvailableNotification";
NSString * const CSMessageInternerDidBecomeUnavailableNotification  = @"CSMessageInternerDidBecomeUnavailableNotification";

//Domains
NSString * const CSMessageErrorDomainInvalidArgument        = @"CSMessageErrorDomainInvalidArgument";
NSString * const CSMessageErrorDomainInternetUnavailable    = @"CSMessageErrorDomainInternetUnavailable";

//Keys
NSString * const CSMessageErrorUserInfoKey                  = @"CSMessageErrorUserInfoKey";

//Codes
NSInteger const CSMessageErrorCodeInvalidArgument           = 701;

//HTTP methods
CSHTTPMethod const CSHTTPMethodGET      = @"GET";
CSHTTPMethod const CSHTTPMethodPOST     = @"POST";
CSHTTPMethod const CSHTTPMethodPUT      = @"PUT";
CSHTTPMethod const CSHTTPMethodDELETE   = @"DELETE";

@interface CSMessage () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {

    NSUInteger _bytesReceived;
    unsigned long long _expectedContentLength;
}

@property (nonatomic, strong) CSHTTPMethod defaultMethod;
@property (nonatomic, strong) NSString *defaultAction;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@interface CSMessage (NSURLConnectionHelper)

/**
 *  Generates boundary string used in httpBody.
 *
 *  @return String object containing generated boundary.
 */
- (NSString *)generateBoundaryString;

/**
 *  Generates mimeType string depending on file that is path pointing on.
 *
 *  @param path Path to file in system.
 *
 *  @return String object containing mimeType.
 */
- (NSString *)mimeTypeForPath:(NSString *)path;

/**
 * Generates endpoint URL object containing baseURL and action.
 *
 *  @return URL object containing full path to execute.
 */
- (NSURL *)targetPath;

@end

@implementation CSMessage

#pragma MARK - Class Methods

static NSURL *_registratedBaseURL = nil;

+ (void)registerBaseURL:(NSURL *)baseURL {
    
    if (!baseURL) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                reason:@"baseURL argument cannot be nil!"
                              userInfo:nil] raise];
    }
    
    [[self class] reachability];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _registratedBaseURL = baseURL;
    });
}

+ (NSURL *)registratedBaseURL {
    return _registratedBaseURL;
}

#pragma mark - Reachability

+ (void)startNetworkNotifiers {
    [[self class] reachability];
}

+ (CSUReachability *)reachability {

    static CSUReachability *reachability = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reachability = [CSUReachability reachabilityWithHostname:@"www.example.com"];
        [reachability startNotifier];
        [[self class] registerReachabilityNotifiers:reachability];
    });
    return reachability;
}

+ (void)registerReachabilityNotifiers:(CSUReachability *)reachability {
    
    reachability.reachableBlock = ^(CSUReachability * reachability) {
        [[self class] checkReachability:reachability];
    };

    reachability.unreachableBlock = ^(CSUReachability * reachability) {
        [[self class] checkReachability:reachability];
    };
}

+ (void)checkReachability:(CSUReachability *)reachability {
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
	
	if(remoteHostStatus == NotReachable) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CSMessageInternerDidBecomeUnavailableNotification
                                                            object:nil];
    }
	else if (remoteHostStatus == ReachableViaWiFi || remoteHostStatus == ReachableViaWWAN) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CSMessageInternerDidBecomeAvailableNotification
                                                            object:nil];
    }
}

#pragma mark -

+ (instancetype)messageWithParameters:(NSDictionary *)parameters {
    return [[self alloc] initWithParameters:parameters];
}

+ (instancetype)messageWithParameters:(NSDictionary *)parameters
                        responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.responseBlock = responseBlock;
    return message;
}

+ (instancetype)postMessageWithParameters:(NSDictionary *)parameters
                                   action:(NSString *)action
                            responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.defaultAction = action;
    message.defaultMethod = CSHTTPMethodPOST;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}

+ (instancetype)postMessageWithParameters:(NSDictionary *)parameters
                                      url:(NSURL *)URL
                            responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.baseURL = URL;
    message.defaultMethod = CSHTTPMethodPOST;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}

+ (instancetype)getMessageWithParameters:(NSDictionary *)parameters
                                  action:(NSString *)action
                           responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.defaultAction = action;
    message.defaultMethod = CSHTTPMethodGET;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}

+ (instancetype)getMessageWithURL:(NSURL *)URL
                    responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] init];
    message.baseURL = URL;
    message.defaultMethod = CSHTTPMethodGET;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}

+ (instancetype)putMessageWithParameters:(NSDictionary *)parameters
                                  action:(NSString *)action
                           responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.defaultAction = action;
    message.defaultMethod = CSHTTPMethodPUT;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}

+ (instancetype)putMessageWithParameters:(NSDictionary *)parameters
                                     url:(NSURL *)URL
                           responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.baseURL = URL;
    message.defaultMethod = CSHTTPMethodPUT;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}


+ (instancetype)deleteMessageWithParameters:(NSDictionary *)parameters
                                     action:(NSString *)action
                              responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.defaultAction = action;
    message.defaultMethod = CSHTTPMethodDELETE;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}

+ (instancetype)deleteMessageWithParameters:(NSDictionary *)parameters
                                        url:(NSURL *)URL
                              responseBlock:(CSResponseBlock)responseBlock {

    CSMessage *message = [[self alloc] initWithParameters:parameters];
    message.baseURL = URL;
    message.defaultMethod = CSHTTPMethodDELETE;
    message.responseBlock = responseBlock;
    [message send];
    
    return message;
}


#pragma mark - Memory Management

- (void)dealloc {
    
    self.uploadProgressBlock = nil;
    self.downloadProgressBlock = nil;
    self.responseBlock = nil;
    
    //    CSLog(@"Dealloc called in %@", NSStringFromClass([self class]));
}

#pragma mark - Memory Management

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    
    if (self = [super init]) {
        
        self.parameters = parameters;
        [self setup];
    }
    
    return self;
}

- (instancetype)init {

    if (self = [super init]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {

    self.receivedData = [[NSMutableData alloc] init];
    self.defaultMethod = CSHTTPMethodPOST;
    self.fileField = @"file";
    
    _bytesReceived = 0;
    _expectedContentLength = 0;
}

#pragma mark - Responding To Errors
+ (NSError *)errorForLocalizedError:(NSError *)error {
    
    if (error.code == NSURLErrorNotConnectedToInternet) {
        return [self internetUnavailableError];
    }
    return error;
}

+ (NSError *)internetUnavailableError {
    
    return [NSError errorWithDomain:CSMessageErrorDomainInternetUnavailable
                               code:NSURLErrorNotConnectedToInternet
                           userInfo:nil];
}

+ (NSError *)invalidArgumentError:(NSString *)description {

    return [NSError errorWithDomain:CSMessageErrorDomainInvalidArgument
                               code:CSMessageErrorCodeInvalidArgument
                           userInfo:@{CSMessageErrorUserInfoKey : description}];
}

#pragma mark - Connection

+ (BOOL)isInternetAvailable {
    NetworkStatus status = [[[self class] reachability] currentReachabilityStatus];
    return (status != NotReachable);
}

#pragma mark - Response Operations

- (id)parseResponse:(id)rawResponse {

    if ([rawResponse isKindOfClass:[NSData class]]) {
        
        id response = rawResponse;
        
        if ([NSJSONSerialization isValidJSONObject:rawResponse]) {
            
            NSError *error = nil;
            response = [NSJSONSerialization JSONObjectWithData:rawResponse
                                                          options:0
                                                            error:&error];
#ifdef DEBUG
            if(error) {
                CSLog(@"%@, %@",
                      [error localizedDescription],
                      [[NSString alloc] initWithData:rawResponse encoding:NSUTF8StringEncoding]);
            }
#endif
        }
        return response;
    }
    
    return rawResponse;
}

#pragma mark - Message Controll

- (void)send {
    
    if (![[self class] isInternetAvailable]) {
        if (self.responseBlock) {
            self.responseBlock(nil, [[self class] internetUnavailableError]);
            return;
        }
    }
    [[CSMessageCenter defaultCenter] addMessage:self];
}

- (NSString *)action {
    
    /**
     *  Action must be set eather using constructor or by overriding action method in subclass.
     */
    return self.defaultAction;
}

- (CSHTTPMethod)httpMethod {
    return self.defaultMethod;
}

#pragma mark - Getters

- (NSURL *)baseURL {
    NSURL *URL = (_baseURL ? _baseURL : [CSMessage registratedBaseURL]);
    NSAssert((URL ? YES : NO), @"You must define baseURL eather by registrating it using registerBaseURL or setting baseURL property.");
    return URL;
}

#pragma mark - CSGennericOperation Override

- (void)operationDidFinish {
    
    _receivedData = nil;
    _connection = nil;
    
    [super operationDidFinish];
}

- (void)operationDidStart {
    
    /**
     *  NSURLConnection must me called from main thread. Don't ask me why..
     */
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(operationDidStart)
                               withObject:nil
                            waitUntilDone:NO];
        return;
    }
    [self executeRequest];
}

#pragma mark - Executing Request

- (void)executeRequest {
    
    NSURL *targetPath = [self targetPath];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:targetPath];
    [self configureRequest:urlRequest];

    NSMutableData *httpBody = (self.httpMethod != CSHTTPMethodGET ? [[NSMutableData alloc] init] : nil);
    
    NSString *boundary = [self generateBoundaryString];
    [self appendParameters:httpBody boundary:boundary];
    
    if (self.filePath && [self httpMethod] == CSHTTPMethodPOST) {
        [self appendFile:httpBody boundary:boundary request:urlRequest];
    }
    
    [urlRequest setHTTPBody:httpBody];
    
    [self executeConnectionWithRequest:urlRequest];
}

#pragma mark - Request Configuration

- (void)configureRequest:(NSMutableURLRequest *)urlRequest {

    [urlRequest setHTTPMethod:[self httpMethod]];
    [urlRequest setTimeoutInterval:60.0];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setHTTPShouldHandleCookies:NO];
}

- (void)appendParameters:(NSMutableData *)httpBody
                boundary:(NSString *)boundary {

    if (!self.parameters || !self.parameters.count || self.httpMethod == CSHTTPMethodGET) {
        return;
    }
    if (!self.filePath) {
        
        NSInteger count = self.parameters.allKeys.count;
        __block NSInteger current = 0;
        
         NSMutableString *dataString = [NSMutableString string];
        __weak id this = self;
        [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            __strong CSMessage *strongThis = this;
            [dataString appendString:[NSString stringWithFormat:@"%@=%@",
                                      CSURLEncodedStringFromStringWithEncoding(key, NSUTF8StringEncoding),
                                      CSURLEncodedStringFromStringWithEncoding(strongThis.parameters[key], NSUTF8StringEncoding)]];
            current++;
            if (current < count) {
                [dataString appendString:@"&"];
            }
        }];
        [httpBody appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        [self.parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
            [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
            [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
        }];
    }
}

- (void)appendFile:(NSMutableData *)httpBody
          boundary:(NSString *)boundary
           request:(NSMutableURLRequest *)urlRequest {

    // set content type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //configure filename
    NSString *filename = [self.filePath lastPathComponent];
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", self.fileField, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //configure mime
    NSString *mimetype = [self mimeTypeForPath:self.filePath];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //attach data
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    [httpBody appendData:data];
    
    //finish boundary
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Executing Requests

- (void)executeConnectionWithRequest:(NSURLRequest *)request {

    self.connection = [[NSURLConnection alloc] initWithRequest:request
                                                      delegate:self
                                              startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)receivedResponse:(id)result error:(NSError *)error {
    
    if (self.responseBlock) {
        self.responseBlock([self parseResponse:result], error);
    }
    [self operationDidFinish];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    
    [self receivedResponse:nil error:error];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self receivedResponse:_receivedData error:nil];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    
    [self.receivedData appendData:data];
    
    _bytesReceived += [data length];
    if(_expectedContentLength != NSURLResponseUnknownLength) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(_bytesReceived, _expectedContentLength, _expectedContentLength);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
    
    _expectedContentLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

    if (self.uploadProgressBlock) {
        self.uploadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

@end

@implementation CSMessage (NSURLConnectionHelper)

- (NSString *)generateBoundaryString {
    
    // generate boundary string
    //
    // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
    
    CFUUIDRef  uuid;
    NSString  *uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    assert(uuidStr != NULL);
    
    CFRelease(uuid);
    
    return [NSString stringWithFormat:@"Boundary-%@", uuidStr];
}

- (NSString *)mimeTypeForPath:(NSString *)path {
    
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSURL *)targetPath {
    
    NSMutableString *targetPath = (self.action ?
                                   [NSMutableString stringWithFormat:@"%@%@", [self.baseURL absoluteString], [self action]] :
                                   [[self.baseURL absoluteString] mutableCopy]);
    
    if ([self httpMethod] == CSHTTPMethodGET && self.parameters.count) {
        
        if (![targetPath hasSuffix:@"?"]) {
            [targetPath appendString:@"?"];
        }
        for (NSString *key in [self.parameters allKeys]) {
            
            id value = self.parameters[key];
            if (![value isKindOfClass:[NSString class]]) {
                continue;
            }
            NSString *encodedValue = CSURLEncodedStringFromStringWithEncoding(value, NSUTF8StringEncoding);
            NSString *encodedKey = CSURLEncodedStringFromStringWithEncoding(key, NSUTF8StringEncoding);
            [targetPath appendString:[NSString stringWithFormat:@"%@=%@&", encodedKey, encodedValue]];
        }
    }
    
    return [NSURL URLWithString:targetPath];
}

@end
