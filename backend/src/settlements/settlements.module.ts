import { Module } from '@nestjs/common';
import { SettlementsService } from './settlements.service.js';
import { SettlementsResolver } from './settlements.resolver.js';

@Module({
  providers: [SettlementsResolver, SettlementsService],
})
export class SettlementsModule {}
