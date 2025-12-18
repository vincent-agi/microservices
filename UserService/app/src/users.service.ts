import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserStatus, booleanToStatus } from './utils/helpers';
import * as bcrypt from 'bcrypt';

/**
 * Service for managing users (CRUD operations)
 */
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Create a new user
   * @param createUserDto - Data for creating a user
   * @returns Created user
   */
  async create(createUserDto: CreateUserDto): Promise<User> {
    // Check if email already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: createUserDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

    // Create user entity
    const user = this.userRepository.create({
      email: createUserDto.email,
      passwordHash: hashedPassword,
      firstName: createUserDto.firstName,
      lastName: createUserDto.lastName,
      phone: createUserDto.phone,
      isActive: UserStatus.ACTIVE,
    });

    return await this.userRepository.save(user);
  }

  /**
   * Get all users with pagination
   * @param page - Page number (starting from 1)
   * @param limit - Number of items per page
   * @returns Paginated list of users
   */
  async findAll(
    page: number = 1,
    limit: number = 20,
  ): Promise<{ data: User[]; total: number; page: number; limit: number }> {
    if (page < 1) {
      throw new BadRequestException('Page must be greater than 0');
    }
    if (limit < 1 || limit > 100) {
      throw new BadRequestException('Limit must be between 1 and 100');
    }

    const skip = (page - 1) * limit;

    const [data, total] = await this.userRepository.findAndCount({
      skip,
      take: limit,
      relations: ['roles'],
      order: { createdAt: 'DESC' },
    });

    return {
      data,
      total,
      page,
      limit,
    };
  }

  /**
   * Get a user by ID
   * @param id - User ID
   * @returns User entity
   */
  async findOne(id: number): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  /**
   * Update a user
   * @param id - User ID
   * @param updateUserDto - Data for updating a user
   * @returns Updated user
   */
  async update(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);

    // Check if email is being changed and if it already exists
    if (updateUserDto.email && updateUserDto.email !== user.email) {
      const existingUser = await this.userRepository.findOne({
        where: { email: updateUserDto.email },
      });

      if (existingUser) {
        throw new ConflictException('Email already exists');
      }
    }

    // Hash password if provided
    if (updateUserDto.password) {
      user.passwordHash = await bcrypt.hash(updateUserDto.password, 10);
    }

    // Update user fields
    if (updateUserDto.email) user.email = updateUserDto.email;
    if (updateUserDto.firstName !== undefined)
      user.firstName = updateUserDto.firstName;
    if (updateUserDto.lastName !== undefined)
      user.lastName = updateUserDto.lastName;
    if (updateUserDto.phone !== undefined) user.phone = updateUserDto.phone;
    if (updateUserDto.isActive !== undefined)
      user.isActive = booleanToStatus(updateUserDto.isActive);

    return await this.userRepository.save(user);
  }

  /**
   * Delete a user (soft delete)
   * @param id - User ID
   */
  async remove(id: number): Promise<void> {
    const user = await this.findOne(id);
    await this.userRepository.softRemove(user);
  }
}
