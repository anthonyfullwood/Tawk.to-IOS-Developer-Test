//
//  UserViewModelTests.swift
//  TawkIOSDeveloperTestTests
//
//  Created by Anthony Fullwood on 30/10/2022.
//

import XCTest
@testable import TawkIOSDeveloperTest

final class UserViewModelTests: XCTestCase {


    
    /* Note that this unit test is not working becuase I just could not get it to work
       with Core Data and unit testing is new to me but I wanted to show that
       I am interested in learning how to do it properly and that I have basic understanding of
       what it is and its importance
     */
    
    private var userVM: UserViewModel!
    
    override func setUp() {
    
     
        self.userVM = UserViewModel()
        self.userVM.users = []
        
    }
    
    func test_should_return_a_value(){
        
        let result = userVM.cellForRowAt(5)
        
        XCTAssertNotNil(result)
        
    }
    
}
