import { Module } from '@nestjs/common';
import { GroupsService } from './groups.service.js';
import { GroupsResolver } from './groups.resolver.js';

@Module({
  providers: [GroupsResolver, GroupsService],
})
export class GroupsModule {}
