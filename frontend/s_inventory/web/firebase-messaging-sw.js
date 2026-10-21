importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js'
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: 'AIzaSyDpG-viJcfYb0yQOtWAWZBxx9ITHqL4rZk',
  authDomain: 'sinventory12345.firebaseapp.com',
  projectId: 'sinventory12345',
  storageBucket: 'sinventory12345.firebasestorage.app',
  messagingSenderId: '626102851881',
  appId: '1:626102851881:web:10389b7e6128f8b3437f38',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title =
    payload.notification?.title || 'S-Inventory';

  const options = {
    body:
      payload.notification?.body ||
      'Tienes una nueva notificación.',
    icon: '/images/logo.png',
  };

  self.registration.showNotification(title, options);
});