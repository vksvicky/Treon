#pragma once

#include <spdlog/spdlog.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <memory>

namespace treon {

class Logger {
public:
    static void initialize() {
        if (!s_logger) {
            // Create console sink with colors
            auto console_sink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
            console_sink->set_level(spdlog::level::debug);
            console_sink->set_pattern("[%H:%M:%S.%e] [%^%l%$] [%t] %v");

            // Create logger
            s_logger = std::make_shared<spdlog::logger>("treon", console_sink);
            s_logger->set_level(spdlog::level::debug);
            
            // Register as default logger
            spdlog::register_logger(s_logger);
            spdlog::set_default_logger(s_logger);
            
            spdlog::info("Logger initialized");
        }
    }
    
    static std::shared_ptr<spdlog::logger> get() {
        if (!s_logger) {
            initialize();
        }
        return s_logger;
    }

private:
    static std::shared_ptr<spdlog::logger> s_logger;
};

// Convenience macros for easy logging
#define LOG_DEBUG(...) spdlog::debug(__VA_ARGS__)
#define LOG_INFO(...) spdlog::info(__VA_ARGS__)
#define LOG_WARN(...) spdlog::warn(__VA_ARGS__)
#define LOG_ERROR(...) spdlog::error(__VA_ARGS__)
#define LOG_CRITICAL(...) spdlog::critical(__VA_ARGS__)

} // namespace treon
