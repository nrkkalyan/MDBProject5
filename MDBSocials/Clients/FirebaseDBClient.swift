//
//  FirebaseAPIClient.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation

public enum ResourceNotFoundError: Error {
    case resourceNotFound
}

extension ResourceNotFoundError: LocalizedError {
    public var errorDescription: String? {
        return "The requested resource was not found in the database."
    }
}

public enum RequestTimedOutError: Error {
    case requestTimedOut
}

extension RequestTimedOutError: LocalizedError {
    public var errorDescription: String? {
        return "The network request timed out."
    }
}

class FirebaseDBClient {
    
}

