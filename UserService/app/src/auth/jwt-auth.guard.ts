import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * JWT Authentication Guard
 * Extends Passport's AuthGuard to use JWT strategy
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
