//
//  NetworkError.swift
//  FidoNews
//
//  Created by viki benhaim on 28/08/2022.
//

import Foundation

enum NetworkError: Error {
  case invalidUrl
  case parseError
  case requestError
}
