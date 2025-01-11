// Import Firebase SDK modules for App and Messaging

self.addEventListener("push", (event) => {
  let notif = {
      title: "Default Title",
      body: "Default body",
      icon: "/default-icon.png", // Default icon path
      click_action: "/" // Default click action URL
  };

  try {
      // Check if there is any push data in the event
      if (event.data) {
          // Attempt to parse the push event data as JSON
          const pushData = event.data.json();
          
          if (pushData && pushData.notification) {
              notif = {
                  title: pushData.notification.title || notif.title,
                  body: pushData.notification.body || notif.body,
                  icon: pushData.notification.image || notif.icon,
                  click_action: pushData.notification.click_action || notif.click_action
              };
          } else {
              // Handle case where no notification data is available
              console.warn("No notification data found in the push payload.");
          }
      } else {
          console.warn("No push data received.");
      }
  } catch (err) {
      // Log the error if JSON parsing fails
      console.error("Push message is not valid JSON:", err);

      // Check if the event data contains plain text (fallback)
      if (event.data && event.data.text()) {
          notif.body = event.data.text(); // Use raw text as the notification body
      } else {
          // Handle case where the data is neither valid JSON nor plain text
          console.warn("No valid JSON or text payload found.");
      }
  }

  // Show the notification with the processed or default data
  event.waitUntil(
      self.registration.showNotification(notif.title, {
          body: notif.body,
          icon: notif.icon,
          data: {
              url: notif.click_action
          }
      })
  );
});

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

// Firebase initialization (commented out as it may not be relevant here)
// import { initializeApp } from "firebase/app";
// import { getMessaging, onBackgroundMessage } from "firebase/messaging";

// const firebaseConfig = {
//   apiKey: "AIzaSyAd4mgByMtt2_s3Arxg_KWLxf9vUq6pZQI",
//   authDomain: "shieldlink-b052c.firebaseapp.com",
//   projectId: "shieldlink-b052c",
//   storageBucket: "shieldlink-b052c.firebasestorage.app",
//   messagingSenderId: "1004734408718",
//   appId: "1:1004734408718:web:a5b243f8749a8824a9745f",
//   measurementId: "G-3Y3BYT6G83"
// };

// const app = initializeApp(firebaseConfig);
// const messaging = getMessaging(app);

// onBackgroundMessage(messaging, (payload) => {
//   console.log('[firebase-messaging-sw.js] Received background message', payload);
//   const notificationTitle = payload.notification.title || 'Notification Title';
//   const notificationOptions = {
//     body: payload.notification.body || 'Notification Body',
//     icon: payload.notification.icon || '/default-icon.png'
//   };
//   self.registration.showNotification(notificationTitle, notificationOptions);
// });
