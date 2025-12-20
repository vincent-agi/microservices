package com.example.orderservice.util;

import java.util.HashMap;
import java.util.Map;

/**
 * Standardized API error response.
 * Follows the format defined in standardisation_api_rest.md
 */
public class ApiError {
    private ErrorDetails error;

    public ApiError(String code, String message) {
        this.error = new ErrorDetails(code, message, new HashMap<>());
    }

    public ApiError(String code, String message, Map<String, Object> details) {
        this.error = new ErrorDetails(code, message, details);
    }

    // Getters and Setters
    public ErrorDetails getError() {
        return error;
    }

    public void setError(ErrorDetails error) {
        this.error = error;
    }

    public static class ErrorDetails {
        private String code;
        private String message;
        private Map<String, Object> details;

        public ErrorDetails(String code, String message, Map<String, Object> details) {
            this.code = code;
            this.message = message;
            this.details = details;
        }

        // Getters and Setters
        public String getCode() {
            return code;
        }

        public void setCode(String code) {
            this.code = code;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public Map<String, Object> getDetails() {
            return details;
        }

        public void setDetails(Map<String, Object> details) {
            this.details = details;
        }
    }
}
