//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Богдан Топорин on 25.06.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let extraction = expectation(description: "Loading extraction")
        // Then
        loader.loadMovies(){
            result in
            switch result {
                case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                extraction.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let extraction  = expectation(description: "Loading extraction")
        // Then
        loader.loadMovies(){
            result in
            switch result{
                case .failure(let error):
                XCTAssertNotNil(error)
                extraction.fulfill()
            case .success(_):
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1.0)
    }
}
