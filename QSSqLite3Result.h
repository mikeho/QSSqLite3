/**
 * QSSqLite3Result.h
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

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <unistd.h>

@class QSSqLite3Database;
@class QSSqLite3Row;

@interface QSSqLite3Result : NSObject {
	@protected
		NSMutableArray * _arrResults;
		QSSqLite3Database * _objDatabase;
		sqlite3_stmt * _objStatement;
		int _intPointer;
}

-(id)initWithStatement:(sqlite3_stmt *)objStatement Database:(QSSqLite3Database *)objDatabase;
-(QSSqLite3Row *)getNextRow;

@end

@interface QSSqLite3Result (private)

-(bool)isRowsExist;
-(id)getColumnDataAtColumnIndex:(NSInteger)intIndex;
-(NSString *)getColumnNameAtColumnIndex:(NSInteger)intIndex;
-(void)finalizeResult;

@end
