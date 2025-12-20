package com.example.orderservice.util;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Standardized API response wrapper.
 * Follows the format defined in standardisation_api_rest.md
 */
public class ApiResponse<T> {
    private T data;
    private Map<String, Object> meta;

    public ApiResponse(T data) {
        this.data = data;
        this.meta = new HashMap<>();
        this.meta.put("timestamp", String.valueOf(Instant.now().toEpochMilli()));
    }

    public ApiResponse(T data, Map<String, Object> additionalMeta) {
        this.data = data;
        this.meta = new HashMap<>(additionalMeta);
        this.meta.put("timestamp", String.valueOf(Instant.now().toEpochMilli()));
    }

    // Getters and Setters
    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public Map<String, Object> getMeta() {
        return meta;
    }

    public void setMeta(Map<String, Object> meta) {
        this.meta = meta;
    }

    public void addMeta(String key, Object value) {
        this.meta.put(key, value);
    }
}
