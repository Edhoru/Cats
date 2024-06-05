//
//  CatsTests.swift
//  CatsTests
//
//  Created by Alberto on 29/02/24.
//

import XCTest

final class CatsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchingCatsSuccess() async {
        do {
            let cats = try await Cat.fetch(tags: [], skip: 0, limit: 10)
            XCTAssertTrue(cats.count > 0)
        } catch {
            XCTFail("Fetching cats failed: \(error)")
        }
    }
    
    func testFetchingCatsWithTagSuccess() async {
        do {
            let cats = try await Cat.fetch(tags: ["white"], skip: 0, limit: 10)
            XCTAssertTrue(cats.count > 0)
        } catch {
            XCTFail("Fetching cats failed: \(error)")
        }
    }

    func testCatLikeAndDislike() {
        let cat = Cat(id: "testCat", size: 1.0, tags: ["cute"], mimetype: "image/jpeg", createdAt: .now, editedAt: .now)
        XCTAssertFalse(cat.isFavorited())
        cat.favorite()
        XCTAssertTrue(cat.isFavorited())
        cat.unfavorite()
        XCTAssertFalse(cat.isFavorited())
    }

}
