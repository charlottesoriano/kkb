import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';

// Returns the Clerk user ID that ClerkGuard verified and stored on the request.
export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): string =>
    GqlExecutionContext.create(context).getContext().req.userId,
);
