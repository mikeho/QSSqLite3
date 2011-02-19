/**
 * QSSqLite3Result.m
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

@implementation QSSqLite3Result

-(id)initWithStatement:(sqlite3_stmt *)objStatement Database:(QSSqLite3Database *)objDatabase {
	// Store Object Pointers
	_objDatabase = objDatabase;
	[_objDatabase retain];
	_objStatement = objStatement;

	// Create the Results Array
	_arrResults = [[NSMutableArray alloc] init];
	int intColumnCount = sqlite3_column_count(objStatement);

	while ([self isRowsExist]) {
		NSMutableDictionary * dctRow = [[NSMutableDictionary alloc] init];
		for (int intColumnIndex = 0; intColumnIndex < intColumnCount; intColumnIndex++) {
			NSString * strColumnName = [self getColumnNameAtColumnIndex:intColumnIndex];
			id objColumnData = [self getColumnDataAtColumnIndex:intColumnIndex];
			[dctRow setObject:objColumnData forKey:strColumnName];
		}
		
		[_arrResults addObject:dctRow];
		[dctRow release];
	}
	
	_intPointer = 0;
	return self;
}

-(QSSqLite3Row *)getNextRow {
	if (_intPointer < [_arrResults count]) {
		QSSqLite3Row * objToReturn = [[[QSSqLite3Row alloc] initWithDictionary:[_arrResults objectAtIndex:_intPointer]] autorelease];
		_intPointer++;
		return objToReturn;
	} else {
		return nil;
	}
}

-(void)finalizeResult {
	switch (sqlite3_finalize(_objStatement)) {
		case SQLITE_OK:
			break;
		default:
			NSAssert1(false, @"SQLite Error on finalizeResult: %@", [_objDatabase errorMessage]);
	}
	
	_objStatement = nil;
}

-(bool)isRowsExist {
	int intRetryCount = 0;
	while (intRetryCount < SqLite3BusyRetryCount) {
		switch (sqlite3_step(_objStatement)) {
			case SQLITE_ROW:
				return true;
			case SQLITE_DONE:
				return false;
			case SQLITE_BUSY:
				NSLog(@"SQLite Busy while isStatementHasRows");
				usleep(SqLite3BusyRetryTimeout);
				intRetryCount++;
				break;
			default:
				NSAssert1(false, @"SQLite Error on isStatementHasRows: %@", [_objDatabase errorMessage]);
				break;
		}
	}

	NSAssert(false, @"SQLite Error on isStatementHasRows: TIMEOUT");
	return false;
}

-(id)getColumnDataAtColumnIndex:(NSInteger)intIndex {
	switch (sqlite3_column_type(_objStatement, intIndex)) {
		case SQLITE_NULL:
			return [NSNull null];

		case SQLITE_INTEGER:
			return [NSNumber numberWithInt:sqlite3_column_int(_objStatement, intIndex)];

		case SQLITE_FLOAT:
			return [NSNumber numberWithDouble:sqlite3_column_double(_objStatement, intIndex)];

		case SQLITE_TEXT:
			return [[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(_objStatement, intIndex)] autorelease];
//			return [NSString stringWithFormat:@"%s", sqlite3_column_text(_objStatement, intIndex)];

		case SQLITE_BLOB:
			return [NSData dataWithBytes:sqlite3_column_blob(_objStatement, intIndex)
								  length:sqlite3_column_bytes(_objStatement, intIndex)];

		default:
			return nil;
	}
	
	return nil;;
}

-(NSString *)getColumnNameAtColumnIndex:(NSInteger)intIndex {
	return [NSString stringWithUTF8String:sqlite3_column_name(_objStatement, intIndex)];
}

- (void) dealloc {
	if (_objStatement != nil) sqlite3_finalize(_objStatement);
	[_objDatabase release];
	[_arrResults release];
	[super dealloc];
}

@end
