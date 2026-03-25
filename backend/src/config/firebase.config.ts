import * as admin from 'firebase-admin';

let firebaseApp: admin.app.App;

export function getFirebaseApp(): admin.app.App {
  if (firebaseApp) {
    return firebaseApp;
  }

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  } else if (process.env.FIREBASE_CREDENTIALS_JSON) {
    let serviceAccount: any;
    try {
      serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS_JSON);
    } catch (e) {
      throw new Error('FIREBASE_CREDENTIALS_JSON contains invalid JSON');
    }
    // Fix private key: ensure proper newlines and trim each line
    if (serviceAccount.private_key) {
      serviceAccount.private_key = serviceAccount.private_key
        .replace(/\\n/g, '\n')
        .split('\n')
        .map((line: string) => line.trim())
        .join('\n')
        .trim();
    }
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } else {
    throw new Error(
      'Firebase configuration missing. Set GOOGLE_APPLICATION_CREDENTIALS or FIREBASE_CREDENTIALS_JSON.',
    );
  }

  return firebaseApp;
}
