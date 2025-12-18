import {
  IsEmail,
  IsOptional,
  IsString,
  MinLength,
  MaxLength,
  Matches,
  IsBoolean,
} from 'class-validator';

/**
 * DTO for updating an existing user
 */
export class UpdateUserDto {
  @IsEmail({}, { message: 'Email must be a valid email address' })
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password?: string;

  @IsString()
  @IsOptional()
  @MaxLength(100, { message: 'First name must not exceed 100 characters' })
  firstName?: string;

  @IsString()
  @IsOptional()
  @MaxLength(100, { message: 'Last name must not exceed 100 characters' })
  lastName?: string;

  @IsString()
  @IsOptional()
  @MaxLength(20, { message: 'Phone must not exceed 20 characters' })
  @Matches(/^[\d\s\-+()]*$/, {
    message: 'Phone must contain only valid phone characters',
  })
  phone?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
