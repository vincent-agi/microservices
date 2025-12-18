import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { Role } from './entities/role.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST || 'user-db',
      port: 3306,
      username: process.env.DB_USER || 'user_db_user',
      password: process.env.DB_PASSWORD || 'user_password',
      database: process.env.DB_NAME || 'user_database',
      entities: [User, Role],
      synchronize: false, // Set to false in production - use migrations instead
      logging: process.env.NODE_ENV === 'development',
    }),
    TypeOrmModule.forFeature([User, Role]),
  ],
  controllers: [AppController],
  providers: [UsersService],
})
export class AppModule {}
