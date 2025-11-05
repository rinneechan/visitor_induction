// [web/firebase-messaging-sw.js]

importScripts('https://www.gstatic.com/firebasejs/10.7.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.2/firebase-messaging-compat.js');

// Konfigurasi Firebase Anda
firebase.initializeApp({
  apiKey: "AIzaSyCqm_edaM0Aji-8JVSOj0GZ84Vxw-bv5WE",
  authDomain: "sedia-567ad.firebaseapp.com",
  projectId: "sedia-567ad",
  storageBucket: "sedia-567ad.appspot.com",
  messagingSenderId: "549508688373",
  appId: "1:549508688373:web:72dd0ad4b04ba50e5998bc",
  measurementId: "G-LVHCN4F385",
});

const messaging = firebase.messaging();

// Menangani event notifikasi di background
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/icon-192x192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
