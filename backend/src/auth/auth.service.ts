import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async findOrCreateUser(
    firebaseUid: string,
    email: string,
    displayName: string | null,
    avatarUrl: string | null,
  ) {
    return this.prisma.user.upsert({
      where: { firebaseUid },
      update: {
        email,
        displayName,
        avatarUrl,
      },
      create: {
        firebaseUid,
        email,
        displayName,
        avatarUrl,
      },
    });
  }

  async getProfile(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        _count: {
          select: {
            splits: true,
            sessions: true,
          },
        },
      },
    });
  }
}
