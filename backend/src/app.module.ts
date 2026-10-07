import { Module } from '@nestjs/common';
import { createObserveModule } from '@nestjs/observe';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { ExpensesModule } from './expenses/expenses.module.js';
import { GroupsModule } from './groups/groups.module.js';
import { BalancesModule } from './balances/balances.module.js';
import { SettlementsModule } from './settlements/settlements.module.js';
import { NotificationsModule } from './notifications/notifications.module.js';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { Request } from 'express';
import { SupabaseModule } from './supabase/supabase.module.js';
import { ConfigModule } from '@nestjs/config';

export const { ObserveModule, ObserveInstrument } = createObserveModule();

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: true,
      context: ({ req }: { req: Request }) => ({ req }),
    }),
    SupabaseModule,
    ExpensesModule,
    GroupsModule,
    BalancesModule,
    SettlementsModule,
    NotificationsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
