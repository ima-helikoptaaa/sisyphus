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
    const existingUser = await this.prisma.user.findUnique({
      where: { firebaseUid },
    });

    if (existingUser) {
      return this.prisma.user.update({
        where: { id: existingUser.id },
        data: {
          email,
          displayName,
          avatarUrl,
        },
      });
    }

    return this.prisma.user.create({
      data: {
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
