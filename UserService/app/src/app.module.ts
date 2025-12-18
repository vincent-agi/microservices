/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
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
      host: process.env.DB_HOST,
      port: 3306,
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      entities: [User, Role],
      synchronize: false,
      logging: process.env.NODE_ENV === 'development',
    }),
    TypeOrmModule.forFeature([User, Role]),
  ],
  controllers: [AppController],
  providers: [UsersService],
})
export class AppModule {}
