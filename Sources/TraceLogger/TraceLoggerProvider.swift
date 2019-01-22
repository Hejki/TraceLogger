// Copyright (c) 2019 Hejki

import Logging
import Service

public final class TraceLoggerProvider: Provider {

    public init() {}

    public func register(_ services: inout Services) throws {

        services.register([Logger.self, TraceLogger.self]) { container -> CombineLogger in
            let config = try? container.make(LoggerConfig.self)

            return CombineLogger(config ?? .default)
        }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
}
