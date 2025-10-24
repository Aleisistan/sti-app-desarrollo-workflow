/* eslint-disable prettier/prettier */
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors(); // Permitir el envío de cookies o autenticación
  
  await app.listen(3000);
  console.log('Application is running on: http://localhost:3000');
}
bootstrap();
