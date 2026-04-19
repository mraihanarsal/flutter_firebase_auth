const { google } = require('googleapis');
const path = require('path');

// Gunakan path absolut agar tidak bingung lokasinya
const keyFile = path.join(__dirname, 'service-account.json');

const SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];

async function getAccessToken() {
    try {
        const auth = new google.auth.GoogleAuth({
            keyFile: keyFile,
            scopes: SCOPES,
        });

        const client = await auth.getClient();
        const tokens = await client.getAccessToken();

        console.log('\n--- BERHASIL! INI TOKEN ANDA ---');
        console.log(tokens.token);
        console.log('--------------------------------\n');
    } catch (error) {
        console.error('\n❌ Terjadi Kesalahan:');
        console.error(error.message);
    }
}

getAccessToken();