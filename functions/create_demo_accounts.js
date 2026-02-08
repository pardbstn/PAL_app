const admin = require('firebase-admin');

// Initialize with default credentials
if (!admin.apps.length) {
  admin.initializeApp();
}

async function createDemoAccounts() {
  const auth = admin.auth();
  const db = admin.firestore();
  
  // Demo accounts
  const accounts = [
    {
      email: 'trainer.demo@palapp.com',
      password: 'PalDemo2025!',
      displayName: '데모 트레이너',
      role: 'trainer'
    },
    {
      email: 'member.demo@palapp.com', 
      password: 'PalDemo2025!',
      displayName: '데모 회원',
      role: 'member'
    }
  ];

  for (const account of accounts) {
    try {
      // Create auth user
      const userRecord = await auth.createUser({
        email: account.email,
        password: account.password,
        displayName: account.displayName,
        emailVerified: true
      });
      
      console.log(`Created user: ${account.email} (${userRecord.uid})`);
      
      // Create user document in Firestore
      await db.collection('users').doc(userRecord.uid).set({
        email: account.email,
        name: account.displayName,
        role: account.role,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isDemo: true
      });
      
      console.log(`Created Firestore doc for: ${account.email}`);
      
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        console.log(`Account already exists: ${account.email}`);
      } else {
        console.error(`Error creating ${account.email}:`, error.message);
      }
    }
  }
  
  console.log('Done!');
  process.exit(0);
}

createDemoAccounts();
