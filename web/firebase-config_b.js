import { initializeApp } from "https://www.gstatic.com/firebasejs/11.2.0/firebase-app.js";
import { getMessaging, isSupported } from "https://www.gstatic.com/firebasejs/11.2.0/firebase-messaging.js";

// Konfigurasi Firebase
const firebaseConfig = {
  apiKey: "AIzaSyCqm_edaM0Aji-8JVSOj0GZ84Vxw-bv5WE",
  authDomain: "sedia-567ad.firebaseapp.com",
  databaseURL: "https://sedia-567ad-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "sedia-567ad",
  storageBucket: "sedia-567ad.firebasestorage.app",
  messagingSenderId: "549508688373",
  appId: "1:549508688373:web:72dd0ad4b04ba50e5998bc",
  measurementId: "G-LVHCN4F385"
};

// Inisialisasi Firebase
const app = initializeApp(firebaseConfig);

// ✅ Cek apakah Firebase Messaging didukung di browser ini
let messaging = null;
isSupported().then((supported) => {
  if (supported) {
    messaging = getMessaging(app);
    console.log('✅ Firebase Messaging didukung dan berhasil diinisialisasi');
  } else {
    console.warn('⚠️ Firebase Messaging tidak didukung di browser ini.');
  }
});

export { app, messaging };
