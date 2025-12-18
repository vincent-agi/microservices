import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  ValidationPipe,
  ParseIntPipe,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { plainToClass } from 'class-transformer';
import { UserResponseDto } from './dto/user-response.dto';
import { generateTimestamp } from './utils/helpers';

/**
 * Controller for user management REST API
 */
@Controller('users')
export class AppController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * Create a new user
   * @param createUserDto - User creation data
   * @returns Response with created user data
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createUser(@Body(ValidationPipe) createUserDto: CreateUserDto) {
    const user = await this.usersService.create(createUserDto);
    const userResponse = plainToClass(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });

    return {
      data: userResponse,
      meta: {
        timestamp: generateTimestamp(),
      },
    };
  }

  /**
   * Get all users with pagination
   * @param page - Page number (default: 1)
   * @param limit - Items per page (default: 20)
   * @returns Response with paginated users list
   */
  @Get()
  async findAllUsers(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    const result = await this.usersService.findAll(page, limit);
    const usersResponse = result.data.map((user) =>
      plainToClass(UserResponseDto, user, { excludeExtraneousValues: true }),
    );

    return {
      data: usersResponse,
      meta: {
        timestamp: generateTimestamp(),
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: Math.ceil(result.total / result.limit),
      },
    };
  }

  /**
   * Get a user by ID
   * @param id - User ID
   * @returns Response with user data
   */
  @Get(':id')
  async findOneUser(@Param('id', ParseIntPipe) id: number) {
    const user = await this.usersService.findOne(id);
    const userResponse = plainToClass(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });

    return {
      data: userResponse,
      meta: {
        timestamp: generateTimestamp(),
      },
    };
  }

  /**
   * Update a user by ID
   * @param id - User ID
   * @param updateUserDto - User update data
   * @returns Response with updated user data
   */
  @Put(':id')
  async updateUser(
    @Param('id', ParseIntPipe) id: number,
    @Body(ValidationPipe) updateUserDto: UpdateUserDto,
  ) {
    const user = await this.usersService.update(id, updateUserDto);
    const userResponse = plainToClass(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });

    return {
      data: userResponse,
      meta: {
        timestamp: generateTimestamp(),
      },
    };
  }

  /**
   * Delete a user by ID (soft delete)
   * @param id - User ID
   * @returns No content response
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removeUser(@Param('id', ParseIntPipe) id: number) {
    await this.usersService.remove(id);
  }
}
