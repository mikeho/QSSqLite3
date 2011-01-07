//
//  SqLiteDatabaseResult.m
//  iVQ
//
//  Created by Mike Ho on 8/30/10.
//  Copyright 2010 Quasidea Development, LLC. All rights reserved.
//

#import "SqLite3DatabaseResult.h"
#import "SqLite3DatabaseRow.h"

@implementation SqLite3DatabaseResult

-(id)initWithStatement:(sqlite3_stmt *)objStatement Database:(SqLite3Database *)objDatabase {
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

-(SqLite3DatabaseRow *)getNextRow {
	if (_intPointer < [_arrResults count]) {
		SqLite3DatabaseRow * objToReturn = [[[SqLite3DatabaseRow alloc] initWithDictionary:[_arrResults objectAtIndex:_intPointer]] autorelease];
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
			return [NSString stringWithFormat:@"%s", sqlite3_column_text(_objStatement, intIndex)];

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
