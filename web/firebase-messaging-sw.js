// Import the necessary scripts
importScripts('https://www.gstatic.com/firebasejs/11.2.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.2.0/firebase-messaging-compat.js');

// Your Firebase project configuration
const firebaseConfig = {
  apiKey: "AIzaSyAd4mgByMtt2_s3Arxg_KWLxf9vUq6pZQI",
  authDomain: "shieldlink-b052c.firebaseapp.com",
  projectId: "shieldlink-b052c",
  storageBucket: "shieldlink-b052c.appspot.com",
  messagingSenderId: "1004734408718",
  appId: "1:1004734408718:web:a5b243f8749a8824a9745f",
  measurementId: "G-3Y3BYT6G83",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Initialize Firebase Messaging
const messaging = firebase.messaging();

// Request notification permissions if not granted
if (Notification.permission === 'default') {
  Notification.requestPermission().then(permission => {
    console.log('Notification permission:', permission);
  });
}

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: payload.notification.icon,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
//redundant attempt to push notifs 
self.addEventListener('push', (event) => {
  const notif = event.data ? JSON.parse(event.data.text()) : {};

  if (!notif.notification || !notif.notification.title || !notif.notification.body) {
    console.error('Invalid payload: missing required fields');
    return;
  }

  event.waitUntil(
    self.registration.showNotification(notif.notification.title, {
      body: notif.notification.body,
      icon: notif.notification.icon || '/default-icon.png', // Fallback icon if not provided
      data: { url: notif.notification.click_action || '/' }, // Fallback click_action
    })
  );
});
    
// Push event listener to handle push notifications
self.addEventListener('push', (event) => {
  console.log('Push event received:', event);

  let notif = {
    title: 'Default Title',
    body: 'Default body',
    icon: '/default-icon.png',
    click_action: '/', // Default URL on click
  };

  try {
    if (event.data) {
      const pushData = event.data.json();
      console.log('Push data:', pushData);

      if (pushData && pushData.notification) {
        notif = {
          title: pushData.notification.title || notif.title,
          body: pushData.notification.body || notif.body,
          icon: pushData.notification.image || notif.icon,
          click_action: pushData.notification.click_action || notif.click_action,
        };
      }
    }
  } catch (err) {
    console.error('Error parsing push data:', err);
  }

  // Show the notification with the processed or default data
  event.waitUntil(
    self.registration.showNotification(notif.title, {
      body: notif.body,
      icon: notif.icon,
      data: { url: notif.click_action },
    })
  );
});

// Notification click event listener to open the URL when clicked
self.addEventListener("notificationclick", (event) => {
  // Close the notification
  event.notification.close();

  const url = event.notification.data.url;

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      // Check if the URL is already open, focus on it
      for (const client of clientList) {
        if (client.url === url && "focus" in client) {
          return client.focus();
        }
      }
      // Otherwise, open a new window
      if (clients.openWindow) {
        return clients.openWindow(url);
      }
    })
  );
});
