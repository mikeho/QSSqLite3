/**
 * QSSqLite3Database.m
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

@implementation SqLite3Database

#pragma mark -
#pragma mark Object Lifecycle

-(id)initWithFile:(NSString *)strDbPath {
	if (self = [super init]) {
		if (sqlite3_open([strDbPath fileSystemRepresentation], &_objDatabase) != SQLITE_OK)
			NSAssert1(false, @"SQLite Error on initWithFile: %s", sqlite3_errmsg(_objDatabase));
	}

	return self;
}

-(void)close {
	if (_objDatabase == nil) return;

	int intRetryCount = 0;
	while (intRetryCount < SqLite3BusyRetryCount) {
		switch (sqlite3_close(_objDatabase)) {
			case SQLITE_OK:
				_objDatabase = nil;
				return;

			default:
				NSLog(@"SQLite Busy while close");
				usleep(SqLite3BusyRetryTimeout);
				intRetryCount++;
				break;
		}
	}

	NSAssert(false, @"SQLite Error on close: TIMEOUT");	
}

- (void)dealloc {
	[self close];
	[super dealloc];
}

#pragma mark -
#pragma mark Error Handling

- (NSInteger)errorCode {
	return sqlite3_errcode(_objDatabase);
}

- (NSString *)errorMessage {
	return [NSString stringWithFormat:@"%s", sqlite3_errmsg(_objDatabase)];
}

#pragma mark -
#pragma mark Last Insert RowId

- (NSInteger)lastInsertId {
	return sqlite3_last_insert_rowid(_objDatabase);
}

#pragma mark -
#pragma mark Query Execution

- (SqLite3DatabaseResult *)query:(NSString *)strQuery, ... {
	va_list arrParameters;
	va_start(arrParameters, strQuery);

	NSMutableArray *arrArguments = [[NSMutableArray alloc] init];
	NSUInteger i;
	for (i = 0; i < [strQuery length]; ++i) {
		if ([strQuery characterAtIndex:i] == '?') {
			[arrArguments addObject:va_arg(arrParameters, id)];
		}
	}
	
	va_end(arrParameters);

	SqLite3DatabaseResult * objToReturn = [self query:strQuery WithArguments:arrArguments];
	[arrArguments release];
	return objToReturn;
}

- (SqLite3DatabaseResult *)query:(NSString *)strQuery WithArguments:(NSArray *)arrArguments {
	sqlite3_stmt * objStatement;

	if (![self prepareSql:strQuery WithStatement:&objStatement])
		return nil;

	int intQueryParameterCount = sqlite3_bind_parameter_count(objStatement);
	for (int i = 0; i < intQueryParameterCount; i++) {
		[self bindObject:[arrArguments objectAtIndex:i] AtColumnIndex:i ForStatement:objStatement];
	}

	SqLite3DatabaseResult * objToReturn = [[[SqLite3DatabaseResult alloc] initWithStatement:objStatement Database:self] autorelease];
	return objToReturn;
}

-(void)nonQuery:(NSString *)strQuery, ... {
	va_list arrParameters;
	va_start(arrParameters, strQuery);

	NSMutableArray *arrArguments = [[NSMutableArray alloc] init];
	NSUInteger i;
	for (i = 0; i < [strQuery length]; ++i) {
		if ([strQuery characterAtIndex:i] == '?')
			[arrArguments addObject:va_arg(arrParameters, id)];
	}

	va_end(arrParameters);

	[self nonQuery:strQuery WithArguments:arrArguments];
	[arrArguments release];
}

-(void)nonQuery:(NSString *)strQuery WithArguments:(NSArray *)arrArguments {
	sqlite3_stmt * objStatement;
	
	if (![self prepareSql:strQuery WithStatement:&objStatement])
		return;

	int intQueryParameterCount = sqlite3_bind_parameter_count(objStatement);
	for (int i = 0; i < intQueryParameterCount; i++) {
		[self bindObject:[arrArguments objectAtIndex:i] AtColumnIndex:i ForStatement:objStatement];
	}

	int intRetryCount = 0;
	while (intRetryCount < SqLite3BusyRetryCount) {
		switch (sqlite3_step(objStatement)) {
			case SQLITE_OK:
			case SQLITE_DONE:
				sqlite3_finalize(objStatement);
				return;

			case SQLITE_BUSY:
				NSLog(@"SQLite Busy while nonQuery");
				usleep(SqLite3BusyRetryTimeout);
				intRetryCount++;
				break;

			default:
				NSAssert3(false, @"SQLite Error while performing '%@' with %@ on nonQuery: %@", strQuery, arrArguments, [self errorMessage]);
				break;
		}
	}
	
	NSAssert(false, @"SQLite Error on nonQuery: TIMEOUT");	
}

#pragma mark -
#pragma mark Transaction Support

- (void)commit {
	[self nonQuery:@"COMMIT TRANSACTION;"];
}

- (void)rollback {
	[self nonQuery:@"ROLLBACK TRANSACTION;"];
}

- (void)beginTransaction {
	[self nonQuery:@"BEGIN EXCLUSIVE TRANSACTION;"];
}

- (void)beginDeferredTransaction {
	[self nonQuery:@"BEGIN DEFERRED TRANSACTION;"];
}


/* ============================================================================
 *  Private Helper Methods
 */

#pragma mark -
#pragma mark Private Helper Methods

- (bool)prepareSql:(NSString *)strSql WithStatement:(sqlite3_stmt **)objStatement {
	int intRetryCount = 0;
	while (intRetryCount < SqLite3BusyRetryCount) {
		switch (sqlite3_prepare_v2(_objDatabase, [strSql UTF8String], -1, objStatement, NULL)) {
			case SQLITE_OK:
				return true;
				
			case SQLITE_BUSY:
				NSLog(@"SQLite Busy while prepareSql");
				usleep(SqLite3BusyRetryTimeout);
				intRetryCount++;
				break;
				
			default:
				NSAssert2(false, @"SQLite Error on prepareSql: %@ on query %@", [self errorMessage], strSql);
				break;
		}
	}

	NSAssert1(false, @"SQLite Error on prepareSql: TIMEOUT on query %@", strSql);
	return false;
}

- (void)bindObject:(id)objToBind AtColumnIndex:(int)intIndex ForStatement:(sqlite3_stmt *)objStatement {
	int intSqlLiteIndex = intIndex + 1;
	if (objToBind == nil || objToBind == [NSNull null]) {
		sqlite3_bind_null(objStatement, intSqlLiteIndex);
	} else if ([objToBind isKindOfClass:[NSData class]]) {
		sqlite3_bind_blob(objStatement, intSqlLiteIndex, [objToBind bytes], [objToBind length], SQLITE_STATIC);
	} else if ([objToBind isKindOfClass:[NSDate class]]) {
		sqlite3_bind_text(objStatement, intSqlLiteIndex, [[objToBind description] UTF8String], -1, NULL);
	} else if ([objToBind isKindOfClass:[NSNumber class]]) {
		if (!strcmp([objToBind objCType], @encode(BOOL))) {
			sqlite3_bind_int(objStatement, intSqlLiteIndex, [objToBind boolValue] ? 1 : 0);
		} else if (!strcmp([objToBind objCType], @encode(int))) {
			sqlite3_bind_int64(objStatement, intSqlLiteIndex, [objToBind longValue]);
		} else if (!strcmp([objToBind objCType], @encode(long))) {
			sqlite3_bind_int64(objStatement, intSqlLiteIndex, [objToBind longValue]);
		} else if (!strcmp([objToBind objCType], @encode(float))) {
			sqlite3_bind_double(objStatement, intSqlLiteIndex, [objToBind floatValue]);
		} else if (!strcmp([objToBind objCType], @encode(double))) {
			sqlite3_bind_double(objStatement, intSqlLiteIndex, [objToBind doubleValue]);
		} else {
			sqlite3_bind_text(objStatement, intSqlLiteIndex, [[objToBind description] UTF8String], -1, SQLITE_STATIC);
		}
	} else {
		sqlite3_bind_text(objStatement, intSqlLiteIndex, [[objToBind description] UTF8String], -1, SQLITE_STATIC);
	}
}

@end
