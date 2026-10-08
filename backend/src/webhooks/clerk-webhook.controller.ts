import { Controller, Post, Req, Inject, BadRequestException, HttpCode } from '@nestjs/common';
import type { RawBodyRequest } from '@nestjs/common';
import type { Request as ExpressRequest } from 'express';
import { verifyWebhook } from '@clerk/backend/webhooks';
import type { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../supabase/supabase.provider.js';

@Controller('webhooks')
export class ClerkWebhookController {
  constructor(@Inject(SUPABASE) private readonly supabase: SupabaseClient) {}

  @Post('clerk')
  @HttpCode(200)
  async handle(@Req() req: RawBodyRequest<ExpressRequest>) {
    if (!req.rawBody) throw new BadRequestException('Missing raw body');

    const request = new Request('http://localhost/webhooks/clerk', {
      method: 'POST',
      headers: {
        'svix-id': req.header('svix-id') ?? '',
        'svix-timestamp': req.header('svix-timestamp') ?? '',
        'svix-signature': req.header('svix-signature') ?? '',
      },
      body: req.rawBody.toString('utf8'),
    });

    let evt;
    try {
      evt = await verifyWebhook(request, {
        signingSecret: process.env.CLERK_WEBHOOK_SIGNING_SECRET,
      });
    } catch {
      throw new BadRequestException('Invalid webhook signature');
    }

    if (evt.type === 'user.created' || evt.type === 'user.updated') {
      const u = evt.data;
      const { error } = await this.supabase.from('users').upsert(
        {
          id: u.id,
          email: u.email_addresses[0].email_address,
          display_name: [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username,
          first_name: u.first_name,
          last_name: u.last_name,
          image_url: u.image_url,
          deleted_at: null,
        },
        { onConflict: 'id' },
      );
      if (error) throw error; // a non-2xx response makes Clerk retry
    }

    // anonymise instead of deleting so expenses they paid for keep a valid paid_by
    if (evt.type === 'user.deleted' && evt.data.id) {
      const id = evt.data.id;
      const { error } = await this.supabase
        .from('users')
        .update({
          email: null,
          display_name: 'Deleted user',
          first_name: null,
          last_name: null,
          image_url: null,
          deleted_at: new Date().toISOString(),
        })
        .eq('id', id);
      if (error) throw error;

      // personal data that isn't part of shared group history
      const favorites = await this.supabase.from('user_favorites').delete().eq('user_id', id);
      if (favorites.error) throw favorites.error;
      const tokens = await this.supabase.from('device_tokens').delete().eq('user_id', id);
      if (tokens.error) throw tokens.error;
    }

    return { received: true };
  }
}
