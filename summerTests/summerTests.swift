//
//  summer_iosTests.swift
//  summer.iosTests
//
//  Created by Cam Tucker on 2017-10-26.
//  Copyright © 2017 Regent College. All rights reserved.
//

import XCTest
import Firebase

class summerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        FirebaseApp.configure()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    
        Firestore.firestore().collection("courses").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
