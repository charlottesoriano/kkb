import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service.js';
import { NotificationsResolver } from './notifications.resolver.js';
import { firebaseMessagingProvider } from './firebase.provider.js';

@Module({
  providers: [NotificationsResolver, NotificationsService, firebaseMessagingProvider],
  // settlements uses it to notify the receiver when a payment is recorded
  exports: [NotificationsService],
})
export class NotificationsModule {}
