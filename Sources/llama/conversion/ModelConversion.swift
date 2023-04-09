//
//  ModelConversion.swift
//  
//
//  Created by Alex Rozanski on 08/04/2023.
//

import Foundation

public struct ModelConversionFile {
  public let url: URL
  public let found: Bool
}

public enum ModelConversionStatus<ResultType> {
  case success(result: ResultType)
  case failure(exitCode: Int32)

  public var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }

  public var exitCode: Int32 {
    switch self {
    case .success: return 0
    case .failure(exitCode: let exitCode): return exitCode
    }
  }
}

public protocol ModelConversionData<ValidationError> where ValidationError: Error {
  associatedtype ValidationError
}

protocol ModelConversion<DataType, ConversionStep, ValidationError, ResultType> where DataType: ModelConversionData<ValidationError> {
  associatedtype DataType
  associatedtype ConversionStep
  associatedtype ValidationError
  associatedtype ResultType

  // Steps
  static var conversionSteps: [ConversionStep] { get }

  // Validation
  static func requiredFiles(for data: DataType) -> [URL]
  static func validate(
    _ data: DataType,
    requiredFiles: inout [ModelConversionFile]?
  ) -> Result<ValidatedModelConversionData<DataType>, ValidationError>

  // Pipeline
  func makeConversionPipeline() -> ModelConversionPipeline<ConversionStep, ValidatedModelConversionData<DataType>, ResultType>
}

public struct ValidatedModelConversionData<DataType> where DataType: ModelConversionData {
  public let validated: DataType

  internal init(validated: DataType) {
    self.validated = validated
  }
}
