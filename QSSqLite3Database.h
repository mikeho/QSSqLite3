/**
 * QSSqLite3Database.h
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

@class QSSqLite3Result;

@interface QSSqLite3Database : NSObject {
	@protected
		sqlite3 * _objDatabase;
}

-(id)initWithFile:(NSString *)strDbPath;
-(void)close;

- (NSInteger)errorCode;
- (NSString *)errorMessage;
- (NSInteger)lastInsertId;

-(QSSqLite3Result *)query:(NSString *)strQuery, ...;
-(QSSqLite3Result *)query:(NSString *)strQuery WithArguments:(NSArray *)arrArguments;

-(void)nonQuery:(NSString *)strQuery, ...;
-(void)nonQuery:(NSString *)strQuery WithArguments:(NSArray *)arrArguments;

-(void)commit;
-(void)rollback;
-(void)beginTransaction;
-(void)beginDeferredTransaction;

@end

@interface QSSqLite3Database (private)
- (bool)prepareSql:(NSString *)strSql WithStatement:(sqlite3_stmt **)objStatement;
- (void)bindObject:(id)objToBind AtColumnIndex:(int)intIndex ForStatement:(sqlite3_stmt *)objStatement;
@end
