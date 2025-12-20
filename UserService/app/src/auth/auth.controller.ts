import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  ValidationPipe,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from '../dto/register.dto';
import { LoginDto } from '../dto/login.dto';
import { generateTimestamp } from '../utils/helpers';

/**
 * Controller for authentication (register, login)
 */
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Register a new user
   * @param registerDto - Registration data
   * @returns User data and JWT token
   */
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body(ValidationPipe) registerDto: RegisterDto) {
    const result = await this.authService.register(registerDto);

    return {
      data: result,
      meta: {
        timestamp: generateTimestamp(),
      },
    };
  }

  /**
   * Login a user
   * @param loginDto - Login credentials
   * @returns User data and JWT token
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body(ValidationPipe) loginDto: LoginDto) {
    const result = await this.authService.login(loginDto);

    return {
      data: result,
      meta: {
        timestamp: generateTimestamp(),
      },
    };
  }
}
