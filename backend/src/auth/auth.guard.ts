import { verifyToken } from '@clerk/backend';
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';

@Injectable()
export class ClerkGuard implements CanActivate {
  async canActivate(context: ExecutionContext) {
    const req = GqlExecutionContext.create(context).getContext().req;
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) throw new UnauthorizedException('Missing token');

    try {
      const payload = await verifyToken(token, {
        secretKey: process.env.CLERK_SECRET_KEY,
      });
      req.userId = payload.sub; // Clerk user ID
      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}
