/**
 * QSSqLite3Row.m
 * 
 * Copyright (c) 2010 - 2011, Quasidea Development, LLC
 * For more information, please go to http://www.quasidea.com/
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "QSSqLite3.h"

@implementation QSSqLite3Row

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