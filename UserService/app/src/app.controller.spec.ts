import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { UsersService } from './users.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from './entities/user.entity';

describe('AppController', () => {
  let appController: AppController;

  const mockUserRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    findAndCount: jest.fn(),
    softRemove: jest.fn(),
  };

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('createUser', () => {
    it('should create a user', async () => {
      const createUserDto = {
        email: 'test@example.com',
        password: 'password123',
        firstName: 'Test',
        lastName: 'User',
      };

      const mockUser = {
        id: 1,
        email: createUserDto.email,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        passwordHash: 'hashedpassword',
        isActive: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
        roles: [],
      };

      mockUserRepository.findOne.mockResolvedValue(null);
      mockUserRepository.create.mockReturnValue(mockUser);
      mockUserRepository.save.mockResolvedValue(mockUser);

      const result = await appController.createUser(createUserDto);

      expect(result).toHaveProperty('data');
      expect(result).toHaveProperty('meta');
      expect(result.meta).toHaveProperty('timestamp');
    });
  });

  describe('findAllUsers', () => {
    it('should return paginated users', async () => {
      const mockUsers = [
        {
          id: 1,
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          passwordHash: 'hashedpassword',
          isActive: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          roles: [],
        },
      ];

      mockUserRepository.findAndCount.mockResolvedValue([mockUsers, 1]);

      const result = await appController.findAllUsers(1, 20);

      expect(result).toHaveProperty('data');
      expect(result).toHaveProperty('meta');
      expect(result.meta).toHaveProperty('page');
      expect(result.meta).toHaveProperty('limit');
      expect(result.meta).toHaveProperty('total');
    });
  });
});
