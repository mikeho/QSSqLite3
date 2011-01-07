//
//  SqLiteDatabaseResult.m
//  iVQ
//
//  Created by Mike Ho on 8/30/10.
//  Copyright 2010 Quasidea Development, LLC. All rights reserved.
//

#import "SqLite3DatabaseRow.h"

@implementation SqLite3DatabaseRow

-(id)initWithDictionary:(NSDictionary *)dctRow {
	_dctRow = dctRow;
	[_dctRow retain];
	return self;
}

-(void)dealloc {
	[_dctRow release];
	[super dealloc];
}

-(NSArray *)getColumnNamesAsArray {
	NSMutableArray * arrKeys = [[[NSMutableArray alloc] initWithCapacity:[_dctRow count]] autorelease]; 
	for (NSString * strKey in [_dctRow keyEnumerator]) {
		[arrKeys addObject:strKey];
	}

	return [NSArray arrayWithArray:arrKeys];
}

-(id)getColumnWithKey:(NSString *)strKey {
	return [_dctRow objectForKey:strKey];
}

-(NSData *)getColumnAsBlobWithKey:(NSString *)strKey {
	return [self getColumnWithKey:strKey];
}

-(NSString *)getColumnAsVarCharWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if (objColumnData == [NSNull null]) return nil;
	return (NSString *)objColumnData;
}

-(NSString *)getColumnAsCharWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if (objColumnData == [NSNull null]) return nil;
	return (NSString *)objColumnData;
}

-(NSInteger)getColumnAsIntegerWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if ([objColumnData isKindOfClass:[NSNull class]])
		return 0;
	else
		return [objColumnData intValue];
}

-(float)getColumnAsFloatWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if ([objColumnData isKindOfClass:[NSNull class]])
		return 0;
	else
		return [objColumnData floatValue];
}

-(NSDate *)getColumnAsDateTimeWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if (objColumnData == [NSNull null]) return nil;

	NSDateFormatter * objFormatter = [[NSDateFormatter alloc] init];
	[objFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
	[objFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[objFormatter autorelease];
	
	return [objFormatter dateFromString:objColumnData];
}

-(NSDate *)getColumnAsDateWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if (objColumnData == [NSNull null]) return nil;

	NSDateFormatter * objFormatter = [[NSDateFormatter alloc] init];
	[objFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
	[objFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[objFormatter autorelease];

	return [objFormatter dateFromString:objColumnData];
}

-(NSDate *)getColumnAsTimeWithKey:(NSString *)strKey {
//	id objColumnData = [self getColumnWithKey:strKey];
//	if (objColumnData == [NSNull null]) return nil;
//	return (NSDate *) objColumnData;
// TODO
	return nil;
}

-(bool)getColumnAsBitWithKey:(NSString *)strKey {
	id objColumnData = [self getColumnWithKey:strKey];
	if ([objColumnData isKindOfClass:[NSNull class]])
		return false;
	else
		return [objColumnData intValue] ? true : false;
}

@end