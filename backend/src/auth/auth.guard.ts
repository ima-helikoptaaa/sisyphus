import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { getFirebaseApp } from '../config/firebase.config';

@Injectable()
export class AuthGuard implements CanActivate {
  private readonly logger = new Logger(AuthGuard.name);

  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid authorization header');
    }

    const token = authHeader.split('Bearer ')[1];

    if (!token) {
      throw new UnauthorizedException('Missing token');
    }

    let decodedToken;
    try {
      const firebaseApp = getFirebaseApp();
      decodedToken = await firebaseApp.auth().verifyIdToken(token);
    } catch (error) {
      this.logger.warn('Firebase token verification failed');
      throw new UnauthorizedException('Invalid or expired token');
    }

    try {
      const user = await this.authService.findOrCreateUser(
        decodedToken.uid,
        decodedToken.email || '',
        decodedToken.name || decodedToken.displayName || null,
        decodedToken.picture || null,
      );

      request.user = user;
      return true;
    } catch (error) {
      this.logger.error('User creation/lookup failed', error instanceof Error ? error.stack : error);
      throw new UnauthorizedException('Authentication failed: unable to resolve user');
    }
  }
}
