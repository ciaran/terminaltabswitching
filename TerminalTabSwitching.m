#import "JRSwizzle.h"

@implementation NSWindowController (Mine)
- (void)updateTabListMenu
{
	NSMenu* windowsMenu = [[NSApplication sharedApplication] windowsMenu];
	
	for(NSMenuItem* menuItem in [windowsMenu itemArray])
	{
		if([menuItem action] == @selector(selectRepresentedTabViewItem:))
			[windowsMenu removeItem:menuItem];
	}

	NSArray* tabViewItems = [[self valueForKey:@"tabView"] tabViewItems];
	for(size_t tabIndex = 0; tabIndex < [tabViewItems count]; ++tabIndex)
	{
		NSString* keyEquivalent = (tabIndex < 10) ? [NSString stringWithFormat:@"%d", (tabIndex+1)%10] : @"";
		NSTabViewItem* tabViewItem = [tabViewItems objectAtIndex:tabIndex];
		NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:[tabViewItem label]
                                                        action:@selector(selectRepresentedTabViewItem:)
                                                 keyEquivalent:keyEquivalent];
		[menuItem setRepresentedObject:tabViewItem];
		[windowsMenu addItem:menuItem];
		[menuItem release];
	}
}

- (void)TerminalTabSwitching_windowDidBecomeMain:(id)fp8;
{
	[self TerminalTabSwitching_windowDidBecomeMain:fp8];
	[self updateTabListMenu];
}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView*)aTabView
{
	[self updateTabListMenu];
}

- (void)TerminalTabSwitching_awakeFromNib;
{
	[[NSApplication sharedApplication] removeWindowsItem:[self window]];
	[[self window] setExcludedFromWindowsMenu:YES];
	[self TerminalTabSwitching_awakeFromNib];
}

- (void)selectRepresentedTabViewItem:(NSMenuItem*)item
{
	NSTabViewItem* tabViewItem = [item representedObject];
	[[tabViewItem tabView] selectTabViewItem:tabViewItem];
}
@end

@interface TerminalTabSwitching : NSObject
@end

@implementation TerminalTabSwitching
+ (void)load
{
	[[[NSApplication sharedApplication] windowsMenu] addItem:[NSMenuItem separatorItem]];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(windowDidBecomeMain:) withMethod:@selector(TerminalTabSwitching_windowDidBecomeMain:) error:NULL];
	[NSClassFromString(@"TTWindowController") jr_swizzleMethod:@selector(awakeFromNib) withMethod:@selector(TerminalTabSwitching_awakeFromNib) error:NULL];
}
@end
