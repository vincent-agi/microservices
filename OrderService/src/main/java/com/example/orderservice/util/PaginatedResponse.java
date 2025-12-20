package com.example.orderservice.util;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Paginated response wrapper for list endpoints.
 * Follows the format defined in standardisation_api_rest.md
 */
public class PaginatedResponse<T> extends ApiResponse<List<T>> {

    public PaginatedResponse(List<T> data, int page, int limit, long total) {
        super(data);
        
        Map<String, Object> paginationMeta = new HashMap<>();
        paginationMeta.put("page", page);
        paginationMeta.put("limit", limit);
        paginationMeta.put("total", total);
        paginationMeta.put("totalPages", (int) Math.ceil((double) total / limit));
        
        // Add pagination metadata to existing meta
        getMeta().putAll(paginationMeta);
    }
}
