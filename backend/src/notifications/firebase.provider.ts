import { cert, initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

export const FIREBASE_MESSAGING = 'FIREBASE_MESSAGING';

export const firebaseMessagingProvider = {
  provide: FIREBASE_MESSAGING,
  useFactory: () =>
    getMessaging(initializeApp({
      credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        // .env stores the key's newlines as \n
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      }),
    })),
};