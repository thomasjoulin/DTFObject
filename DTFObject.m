//
//	Copyright (c) 2010 Thomas Joulin <joulin_t@epitech.net>
//	Licence : <http://opensource.org/licenses/mit-license.php>
//	Website : <http://dailytechfix.net>
//	Project home : <http://github.com/toutankharton/DTFObject>
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

# import <objc/runtime.h>
# import "JRSwizzle.h"
# import "DTFObject.h"

static void SwizzleClassMethods(Class class, SEL firstSelector, SEL secondSelector);

@implementation NSObject (DTFObject)

+ (void)load
{
	NSError	*err = [[NSError alloc] init];

	[self jr_swizzleMethod:@selector(description) withMethod:@selector(dtfDescription) error:&err];
	if ([[err userInfo] valueForKey:@"NSLocalizedDescriptionKey"] != nil)
		NSLog(@"%@", [[err userInfo] valueForKey:@"NSLocalizedDescriptionKey"]);
	[err release];
}

- (NSString *)dtfDescription
{
	unsigned int	i;
	unsigned int	count;
	Ivar			*ivars;
	NSString		*type;
	NSString		*key;
	id				object;
	NSMutableString	*description;

	// If the Sender implements description, call it
	if ([self implementsSelector:@selector(description)])
		return [self dtfDescription];
	
	ivars = class_copyIvarList([self class], &count);
	description = [NSMutableString stringWithFormat:@"<%s:0x%06x>\n(\n", class_getName([self class]), self];
	
	// Loop through the Sender's Ivars
	for (i = 0; i < count; i++)
	{
		type = [[NSString alloc] initWithUTF8String:ivar_getTypeEncoding(ivars[i])];
		key = [[NSString alloc] initWithUTF8String:ivar_getName(ivars[i])];
		
		if ((object = object_getIvar(self, ivars[i])) != nil)
		{
			// I the Ivar is an Instance
			if ([type characterAtIndex:0] == _C_ID)
				[description appendString:[NSString stringWithFormat:@"\t%@ %@ = 0x%6x\n", type, key, object]];
			else
				[description appendFormat:[NSString stringWithFormat:@"\t%@ = %%%@\n", key, type], object];
		}
		else
			[description appendFormat:@"\t%@ = nil 0x%06x", key, object];
		
		[type release];
		[key release];
	}
	
	[description appendString:@")"];
	
	return description;
}

- (BOOL)implementsSelector:(SEL)aSelector
{
	Method			*methods;
	BOOL			implementsSelector = NO;
	unsigned int	count;
	unsigned int	i;
	
	methods = class_copyMethodList([self class], &count);
	for (i = 0; !implementsSelector && i < count; i++)
		if (sel_isEqual(method_getName(methods[i]), aSelector))
			implementsSelector = YES;
	return implementsSelector;
}

@end
