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
          user_id: u.id,
          display_name: [u.first_name, u.last_name].filter(Boolean).join(' ') || u.username,
          avatar_url: u.image_url,
        },
        { onConflict: 'user_id' },
      );
      if (error) throw error; // a non-2xx response makes Clerk retry
    }

    if (evt.type === 'user.deleted' && evt.data.id) {
      await this.supabase.from('users').delete().eq('user_id', evt.data.id);
    }

    return { received: true };
  }
}
