#import <XCTest/XCTest.h>
#import "MPDocument.h"
#import "MPToolbarController.h"

@interface MPDocumentWindowTests : XCTestCase
@end

@implementation MPDocumentWindowTests

- (void)testDefaultToolbarLayout
{
    MPToolbarController *controller = [[MPToolbarController alloc] init];
    NSArray *expected = @[
        @"indent-group", @"text-formatting-group", @"heading-group",
        NSToolbarFlexibleSpaceItemIdentifier,
        @"list-group", NSToolbarFlexibleSpaceItemIdentifier,
        @"blockquote", @"code", NSToolbarFlexibleSpaceItemIdentifier,
        @"link", @"image", NSToolbarFlexibleSpaceItemIdentifier,
        @"copy-html", NSToolbarFlexibleSpaceItemIdentifier, @"layout"
    ];
    XCTAssertEqualObjects([controller toolbarDefaultItemIdentifiers:nil], expected);
}

- (void)testOpenMarkdownDocumentWindow
{
    NSString *markdown = @"# Apple Silicon\n\nA **native** Markdown document.\n";
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory()
        stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"md"]]];
    NSError *error = nil;
    XCTAssertTrue([markdown writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    MPDocument *document = [[MPDocument alloc] initWithContentsOfURL:url
        ofType:@"net.daringfireball.markdown" error:&error];
    XCTAssertNotNil(document, @"%@", error);
    @try {
        [document makeWindowControllers];
        NSWindowController *controller = document.windowControllers.firstObject;
        XCTAssertNotNil(controller.window); // Loads the nib and constructs its toolbar.
        NSPredicate *rendered = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [document.markdown isEqualToString:markdown]
                && [document.html containsString:@"<strong>native</strong>"];
        }];
        [self expectationForPredicate:rendered evaluatedWithObject:document handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];
        XCTAssertEqualObjects(document.markdown, markdown);
        XCTAssertTrue([document.html containsString:@"Apple Silicon"]);
        XCTAssertTrue([document.html containsString:@"<strong>native</strong>"]);
    } @finally {
        [document close];
        [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    }
}

@end
