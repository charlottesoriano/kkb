import { Module } from '@nestjs/common';
import { SettlementsService } from './settlements.service.js';
import { SettlementsResolver } from './settlements.resolver.js';
import { NotificationsModule } from '../notifications/notifications.module.js';

@Module({
  imports: [NotificationsModule],
  providers: [SettlementsResolver, SettlementsService],
})
export class SettlementsModule {}
