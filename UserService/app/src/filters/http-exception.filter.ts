import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

interface ErrorResponse {
  message?: string | string[];
  error?: string;
  statusCode?: number;
}

/**
 * Global exception filter to format errors according to API standards
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorCode = 'INTERNAL_SERVER_ERROR';
    let message = 'An unexpected error occurred';
    let details: Record<string, unknown> = {};

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'object') {
        const responseObj = exceptionResponse as ErrorResponse;
        message =
          (typeof responseObj.message === 'string'
            ? responseObj.message
            : undefined) || exception.message;

        // Handle validation errors
        if (Array.isArray(responseObj.message)) {
          errorCode = 'VALIDATION_ERROR';
          details = {
            fields: responseObj.message,
          };
          message = 'Validation failed';
        } else if (status === HttpStatus.NOT_FOUND) {
          errorCode = 'NOT_FOUND';
        } else if (status === HttpStatus.CONFLICT) {
          errorCode = 'CONFLICT';
        } else if (status === HttpStatus.BAD_REQUEST) {
          errorCode = 'BAD_REQUEST';
        } else if (status === HttpStatus.UNAUTHORIZED) {
          errorCode = 'UNAUTHORIZED';
        } else if (status === HttpStatus.FORBIDDEN) {
          errorCode = 'FORBIDDEN';
        }
      }
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    response.status(status).json({
      error: {
        code: errorCode,
        message: message,
        details: details,
      },
    });
  }
}
