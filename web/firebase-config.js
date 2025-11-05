// Gunakan versi compat dari Firebase
// Pastikan ini sudah diload duluan di index.html:
// <script src="https://www.gstatic.com/firebasejs/11.2.0/firebase-app-compat.js"></script>
// <script src="https://www.gstatic.com/firebasejs/11.2.0/firebase-messaging-compat.js"></script>

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

// Inisialisasi Firebase App
firebase.initializeApp(firebaseConfig);

// Inisialisasi Messaging (jika didukung)
let messaging = null;

if (firebase.messaging.isSupported()) {
  messaging = firebase.messaging();
  console.log("✅ Firebase Messaging didukung dan diinisialisasi");
} else {
  console.warn("⚠️ Firebase Messaging tidak didukung di browser ini.");
}
