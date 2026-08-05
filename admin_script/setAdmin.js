const admin = require('firebase-admin');

// Replace this with the path to your service account key file
// You can download this from Firebase Console -> Project Settings -> Service Accounts
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// The email of the user you want to make an admin
const adminEmail = 'YOUR_EMAIL@HERE.COM';

async function setAdminClaim() {
  try {
    const user = await admin.auth().getUserByEmail(adminEmail);
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    
    // Also update their Firestore document to reflect the role, if you want
    await admin.firestore().collection('users').doc(user.uid).update({
      role: 'admin'
    });

    console.log(`Success! ${adminEmail} is now an admin.`);
    console.log('They will need to log out and log back in to get the new token.');
    process.exit(0);
  } catch (error) {
    console.error('Error making user admin:', error);
    process.exit(1);
  }
}

setAdminClaim();
