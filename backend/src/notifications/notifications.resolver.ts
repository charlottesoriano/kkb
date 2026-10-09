import { Resolver, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ClerkGuard } from '../auth/auth.guard.js';
import { CurrentUser } from '../auth/current-user.decorator.js';
import { NotificationsService } from './notifications.service.js';
import { Notification } from './entities/notification.entity.js';
import { SendReminderInput } from './dto/send-reminder.input.js';

@Resolver(() => Notification)
@UseGuards(ClerkGuard)
export class NotificationsResolver {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Mutation(() => Notification)
  sendReminder(@Args('sendReminderInput') sendReminderInput: SendReminderInput, @CurrentUser() userId: string) {
    return this.notificationsService.sendReminder(userId, sendReminderInput);
  }
}
