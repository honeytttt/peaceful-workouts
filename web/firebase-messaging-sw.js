// Minimal firebase-messaging-sw.js to avoid registration error
// Push won't work until full config + VAPID key, but app loads fine
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Use your config from index.html
firebase.initializeApp({
  apiKey: "AIzaSyC5hHDwu9o46O42C_k8ZnnT50gW7ygmFs4",
  authDomain: "peacefulworkouts.firebaseapp.com",
  projectId: "peacefulworkouts",
  storageBucket: "peacefulworkouts.appspot.com",
  messagingSenderId: "1008908513514",
  appId: "1:1008908513514:web:f2b4969b4c7a691a3f2793"
});

const messaging = firebase.messaging();