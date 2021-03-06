//
//  StatisticsSDK.m
//  StatisticsSDKDemo
//
//  Created by Eric on 12/12/13.
//  Copyright (c) 2013 Saick. All rights reserved.
//

#import "AnalyticsSDK.h"
#import "MobClick.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "AVOSCloud.h"

#define kAnalyticsUD         @"Analytics_UDKey"
#define kAnalyticsUmeng      @"Analytics_Umeng"
#define kAnalyticsGoogle     @"Analytics_Google"
#define kAnalyticsAVOS       @"Analytics_AVOS"

#define kIsEnable            @"isEnable"

@interface AnalyticsSDK ()

@end

@implementation AnalyticsSDK (private)

#pragma mark - Check isEnable statistics item

+ (void)initDefaultSettings
{
  NSDictionary *allItems = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD];
  if (![allItems isKindOfClass:[NSDictionary class]]) {
    allItems = @{kAnalyticsUmeng:  @{kIsEnable: @"NO"},
                 kAnalyticsGoogle: @{kIsEnable: @"NO"},
                 kAnalyticsAVOS: @{kIsEnable: @"NO"}};
    [[NSUserDefaults standardUserDefaults] setObject:allItems forKey:kAnalyticsUD];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } // If there is, use it.
}

+ (void)enableUmeng
{
  [self initDefaultSettings];
  NSMutableDictionary *allItems = [NSMutableDictionary dictionaryWithDictionary:
                                   [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD]];
  NSMutableDictionary *umeng = [NSMutableDictionary dictionaryWithDictionary:[allItems objectForKey:kAnalyticsUmeng]];
  [umeng setValue:@"YES" forKey:kIsEnable];
  [allItems setObject:umeng forKey:kAnalyticsUmeng];
  [[NSUserDefaults standardUserDefaults] setObject:allItems forKey:kAnalyticsUD];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)enableGoogle
{
  [self initDefaultSettings];
  NSMutableDictionary *allItems = [NSMutableDictionary dictionaryWithDictionary:
                                   [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD]];
  NSMutableDictionary *google = [NSMutableDictionary dictionaryWithDictionary:[allItems objectForKey:kAnalyticsGoogle]];
  [google setValue:@"YES" forKey:kIsEnable];
  [allItems setObject:google forKey:kAnalyticsGoogle];
  [[NSUserDefaults standardUserDefaults] setObject:allItems forKey:kAnalyticsUD];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)enableAVOS
{
  [self initDefaultSettings];
  NSMutableDictionary *allItems = [NSMutableDictionary dictionaryWithDictionary:
                                   [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD]];
  NSMutableDictionary *google = [NSMutableDictionary dictionaryWithDictionary:[allItems objectForKey:kAnalyticsAVOS]];
  [google setValue:@"YES" forKey:kIsEnable];
  [allItems setObject:google forKey:kAnalyticsAVOS];
  [[NSUserDefaults standardUserDefaults] setObject:allItems forKey:kAnalyticsUD];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isEnableUmeng
{
  [self initDefaultSettings];
  NSDictionary *allItems = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD];
  return [[[allItems objectForKey:kAnalyticsUmeng] objectForKey:kIsEnable] boolValue];
}

+ (BOOL)isEnableGoogle
{
  [self initDefaultSettings];
  NSDictionary *allItems = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD];
  return [[[allItems objectForKey:kAnalyticsGoogle] objectForKey:kIsEnable] boolValue];
}

+ (BOOL)isEnableAVOS
{
  [self initDefaultSettings];
  NSDictionary *allItems = [[NSUserDefaults standardUserDefaults] objectForKey:kAnalyticsUD];
  return [[[allItems objectForKey:kAnalyticsAVOS] objectForKey:kIsEnable] boolValue];
}

@end

@implementation AnalyticsSDK

/*
 connections
 */

#pragma mark - Connections-Umeng
// Umeng
+ (void)connectUmengWithAppKey:(NSString *)appKey
{
  [self connectUmengWithAppKey:appKey reportPolicy:AS_BATCH channelID:kDefaultChannel];
}

+ (void)connectUmengWithAppKey:(NSString *)appKey
                  reportPolicy:(ASReportPolicy)rp
                     channelID:(NSString *)cid
{
  [self enableUmeng];
  
  [MobClick startWithAppkey:appKey reportPolicy:(ReportPolicy)rp channelId:cid];
}

#pragma mark - Connections-Google
// Google
+ (void)connectGoogleWithTrackingID:(NSString *)trackingID
{
  [self connectGoogleWithTrackingID:trackingID
                   dispatchInterval:kDefaultDispatchTimeInterval
                          channelId:@"App Store"];
}

+ (void)connectGoogleWithTrackingID:(NSString *)trackingID
                   dispatchInterval:(NSTimeInterval)interval
                          channelId:(NSString *)cid
{
  [self enableGoogle];
  
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  [GAI sharedInstance].dispatchInterval = interval;
  id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
  [tracker set:[GAIFields customDimensionForIndex:1] value:cid];
}

#pragma mark - Connections-AVOS

+ (void)connectAvosWithApplicationId:(NSString *)ApplicationId clientKey:(NSString *)key
{
  [AVOSCloud setApplicationId:ApplicationId clientKey:key];
}

/*
 settings
 */

#pragma mark - Settings
// Enable debug log.
+ (void)setLogEnabled:(BOOL)isEnable
{
  if ([self isEnableUmeng])
    [MobClick setLogEnabled:isEnable];
  
  if ([self isEnableGoogle]) {
    if (isEnable)
      [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    else
      [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
  }
  
  if ([self isEnableAVOS]) {
    [AVAnalytics setLogEnabled:isEnable];
  }
}

/*
 basic page view
 */

#pragma mark - Basic page view

+ (void)beginLogView:(NSString *)viewName
{
  if ([self isEnableUmeng])
    [MobClick beginLogPageView:viewName];
  
  if ([self isEnableGoogle]) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:viewName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
  }
  
  if ([self isEnableAVOS]) {
    [AVAnalytics beginLogPageView:viewName];
  }
}

+ (void)endLogView:(NSString *)viewName
{
  if ([self isEnableUmeng])
    [MobClick endLogPageView:viewName];
  
  if ([self isEnableGoogle]) {
    ;
  }
  
  if ([self isEnableAVOS]) {
    [AVAnalytics endLogPageView:viewName];
  }
}

/*
 events
 */

#pragma mark - Events

+ (void)eventWithAction:(NSString *)action
{
  [self eventWithCategory:@"" action:action];
}

+ (void)eventWithCategory:(NSString *)category
                   action:(NSString *)action
{
  [self eventWithCategory:category action:action label:@""];
}

+ (void)eventWithCategory:(NSString *)category
                   action:(NSString *)action
                    label:(NSString *)label
{
  [self eventWithCategory:category action:action label:label value:nil];
}

+ (void)eventWithCategory:(NSString *)category
                   action:(NSString *)action
                    label:(NSString *)label
                    value:(id)value
{
  if ([self isEnableUmeng]) {
    NSString *eventId = [NSString stringWithFormat:@"%@%@", category, action];
    [MobClick event:eventId label:label];
    if (value)
      [MobClick event:eventId attributes:@{@"value": value}];
  }
  
  if ([self isEnableGoogle]) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
  }
  
  if ([self isEnableAVOS]) {
    NSString *aveventId = [NSString stringWithFormat:@"%@%@", category, action];
    [AVAnalytics event:aveventId label:label];
  }
}

+ (void)eventWithCategory:(NSString *)category
                   action:(NSString *)action
                    label:(NSString *)label
                     time:(NSTimeInterval)intervalMillis
{
  if ([self isEnableUmeng]) {
    NSString *eventId = [NSString stringWithFormat:@"%@%@", category, action];
    [MobClick event:eventId label:label durations:(int)intervalMillis];
  }
  
  if ([self isEnableGoogle]) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category
                                                         interval:[NSNumber numberWithFloat:intervalMillis]
                                                             name:action
                                                            label:label] build]];
  }
  
  if ([self isEnableAVOS]) {
    NSString *aveventId = [NSString stringWithFormat:@"%@%@", category, action];
    [AVAnalytics event:aveventId label:label];
  }
}

@end
