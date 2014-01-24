//
//  CSMessage.h
//  StoragePipe
//
//  Created by Josip Bernat on 10/01/14.
//
//

#import <Foundation/Foundation.h>
#import "CSGenericOperation.h"

/**
 *  HTTP request method types.
 */
typedef NSString *CSHTTPMethod;
extern CSHTTPMethod const CSHTTPMethodGET;      ///HTTP GET method.
extern CSHTTPMethod const CSHTTPMethodPOST;     ///HTTP POST method.
extern CSHTTPMethod const CSHTTPMethodPUT;      ///HTTP PUT method.
extern CSHTTPMethod const CSHTTPMethodDELETE;   ///HTTP DELETE method.

/**
 *  Returns a string, replacing certain characters with the equivalent percent escape sequence based on the specified encoding.
 *
 *  @param string   The string to URL encode
 *  @param encoding The encoding to use for the replacement. If you are uncertain of the correct encoding, you should use UTF-8 (NSUTF8StringEncoding), which is the encoding designated by RFC 3986 as the correct encoding for use in URLs.
 *
 *  @discussion The characters escaped are all characters that are not legal URL characters (based on RFC 3986), including any whitespace, punctuation, or special characters.
 *
 *  @return A URL-encoded string. If it does not need to be modified (no percent escape sequences are missing), this function may merely return string argument.
 */
extern NSString * CSURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding);

/**
 *  Sent when networkStatus changes to ReachableViaWiFi or ReachableViaWWAN
 */
extern NSString * const CSMessageInternerDidBecomeAvailableNotification;

/**
 *  Sent when networkStatus changes to NotReachable.
 */
extern NSString * const CSMessageInternerDidBecomeUnavailableNotification;

/**
 *  String object identifing invalid argument error.
 */
extern NSString * const CSMessageErrorDomainInvalidArgument;

/**
 *  String object network unavailability error.
 */
extern NSString * const CSMessageErrorDomainInternetUnavailable;

/**
 *  String object used as key in error.userInfo dictionary.
 */
extern NSString * const CSMessageErrorUserInfoKey;

/**
 *  Integer value defining error.code when domain is CSMessageErrorDomainInvalidArgument.
 */
extern NSInteger const CSMessageErrorCodeInvalidArgument;

/**
 *  CSMessage is a concurrent operation suitable for sending data over network. Subclassing can enable sending message to different queues then default one. For all other actions default implementation provides a lot of required options.
 */
@interface CSMessage : CSGenericOperation

/**
 *  Block object called when request done with operation. Contains responseObject with HTTP response and error object with given URL operation error.
 */
@property (copy) CSResponseBlock responseBlock;

/**
 *  Block object called when upload bytes state changes. Can be called multiply times during the request.
 */
@property (copy) CSUploadProgressBlock uploadProgressBlock;

/**
 *  Block object called when download bytes state changes. Can be called multiply times during the request.
 */
@property (copy) CSDownloadProgressBlock downloadProgressBlock;

/**
 *  Dictionary containing data to be sent.
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 *  Path of file to be sent.
 */
@property (nonatomic, strong) NSString *filePath;

/**
 *  Name of field for file being sent. Default is file.
 */
@property (nonatomic, strong) NSString *fileField;

/**
 *  NSURL object to be used as base URL path. If baseURL is not set and registerBaseURL: method was called, baseURL will be same as registrated URL.
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  HTTP path for request. Usually this is last path component of NSURL object.
 */
@property (nonatomic, readonly) NSString *action;

/**
 *  HTTP method tipe. Default is POST.
 */
@property (nonatomic, readonly) CSHTTPMethod httpMethod;

#pragma mark - Class Methods

/**
 *  Saves baseURL parameter as base URL object for all futher requests.
 *
 *  @param baseURL NSURL object with pull path to your API. Usually it looks like http://example.com/api/. It must have '/' at the end of the path. NSInvalidArgumentException is raised if baseURL is nil.
 */
+ (void)registerBaseURL:(NSURL *)baseURL;

/**
 *  Starts with network availability monitoring. You should call this method from application:didFinishLaunchingWithOptions:.
 */
+ (void)startNetworkNotifiers;

#pragma mark - Initialization
/**
 *  Creates new instance and saves parameters. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters Dictionary object containing data to be sent.
 *
 *  @return New instance of CSMessage.
 */
+ (instancetype)messageWithParameters:(NSDictionary *)parameters;

/**
 *  Creates new instance and saves parameters. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage.
 */
+ (instancetype)messageWithParameters:(NSDictionary *)parameters
                        responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, saves parameters and has httpMethod set to CSHTTPMethodPOST. Sutable for generic use without need for subclassing. BaseURL must be set using registrateBaseURL: method before invoking this method. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param action        HTTP action path for request.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured action and HTTP POST parametes.
 */
+ (instancetype)postMessageWithParameters:(NSDictionary *)parameters
                                   action:(NSString *)action
                            responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, saves parameters and has httpMethod set to CSHTTPMethodPOST. Sutable for generic use without need for subclassing. URL must contain full path including acton. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param URL           URL object containing full URL path including action.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured baseURL and HTTP POST parameters.
 */
+ (instancetype)postMessageWithParameters:(NSDictionary *)parameters
                                      url:(NSURL *)URL
                            responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, adds parameters to action and has httpMethod set to CSHTTPMethodGET. Sutable for generic use without need for subclassing. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to being added in URL.
 *  @param action        HTTP action path for request.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured action and HTTP GET parameters.
 */
+ (instancetype)getMessageWithParameters:(NSDictionary *)parameters
                                  action:(NSString *)action
                           responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, configures baseURL to given URL and has httpMethod set to CSHTTPMethodGET. Sutable for generic use without need for subclassing. Automatically invokes send method on instance before it's returned.
 *
 *  @param URL           URL object containing full URL path including action and all data that needs to be sent.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured baseURL.
 */
+ (instancetype)getMessageWithURL:(NSURL *)URL
                    responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, saves parameters and has httpMethod set to CSHTTPMethodPUT. Sutable for generic use without need for subclassing. BaseURL must be set using registrateBaseURL: method before invoking this method. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param action        HTTP action path for request.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured action and HTTP PUT parametes.
 */
+ (instancetype)putMessageWithParameters:(NSDictionary *)parameters
                                  action:(NSString *)action
                           responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, configures baseURL to given URL and has httpMethod set to CSHTTPMethodPUT. Sutable for generic use without need for subclassing. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param URL           URL object containing full URL path including action.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured baseURL and HTTP PUT  parameters.
 */
+ (instancetype)putMessageWithParameters:(NSDictionary *)parameters
                                     url:(NSURL *)URL
                           responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, saves parameters and has httpMethod set to CSHTTPMethodDELETE. Sutable for generic use without need for subclassing. BaseURL must be set using registrateBaseURL: method before invoking this method. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param action        HTTP action path for request.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured action and HTTP DELETE parametes.
 */
+ (instancetype)deleteMessageWithParameters:(NSDictionary *)parameters
                                     action:(NSString *)action
                              responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance, configures baseURL to given URL and has httpMethod set to CSHTTPMethodDELETE. Sutable for generic use without need for subclassing. Automatically invokes send method on instance before it's returned.
 *
 *  @param parameters    Dictionary object containing data to be sent.
 *  @param URL           URL object containing full URL path including action.
 *  @param responseBlock Block object called when request done with operation.
 *
 *  @return New instance of CSMessage with configured baseURL and HTTP DELETE parameters.
 */
+ (instancetype)deleteMessageWithParameters:(NSDictionary *)parameters
                                        url:(NSURL *)URL
                              responseBlock:(CSResponseBlock)responseBlock;

/**
 *  Creates new instance and saves parameters. Designated initializer.
 *
 *  @param parameters Dictionary object containing data to be sent.
 *
 *  @return New instance of CSMessage.
 */
- (instancetype)initWithParameters:(NSDictionary *)parameters; //designated initializer

#pragma mark - Responding To Errors
/**
 *  Handles given error from NSURLConnection request and if needed converts it to application readable NSError object.
 *
 *  @param error object to be localized
 *
 *  @return Localized error object containing formatted data from error parameter.
 */
+ (NSError *)errorForLocalizedError:(NSError *)error;

/**
 *  Creates NSError object containing data related to unavailable internet connection.
 *
 *  @return Error object with CSMessageErrorDomainInternetUnavailable domain.
 */
+ (NSError *)internetUnavailableError;

/**
 *  Creates NSError object containing data about invalid argument.
 *
 *  @param description Description placed in error.userInfo object. Description is saved under CSMessageErrorUserInfoKey key.
 *
 *  @return Error object with CSMessageErrorDomainInvalidArgument domain.
 */
+ (NSError *)invalidArgumentError:(NSString *)description;

#pragma mark - Connection

/**
 *  Checks internet availability.
 *
 *  @return YES if available, NO if unavailable.
 */
+ (BOOL)isInternetAvailable;

#pragma mark - Response Operations

/**
 *  Parses NSURLConnection response to readable format, usually JSON.
 *
 *  @param rawResponse Object received fron NSURLConnection. Usually it's a NSData object.
 *
 *  @return Parsed object, usually NSDictionary.
 */
- (id)parseResponse:(id)rawResponse;

/**
 *  Handles given response and error objects. Called when request is finished.
 *
 *  @param result An object representing given response from NSURLConnection.
 *  @param error  An error object representing error that ocurred while trying to establish or while connection was established.
 */
- (void)receivedResponse:(id)result error:(NSError *)error;

#pragma mark - Message Controll

/**
 *  Sends message to BSMessageCenter queue. If you need to use some other NSOperationQueue override this method and add message to custom NSOperationQueue.
 */
- (void)send;

@end
