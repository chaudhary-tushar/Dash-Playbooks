/*
 * Flutbook service worker
 *
 * Provides offline support for the web build using a network-first strategy:
 *  - Navigations (app shell) are fetched from the network first and fall back
 *    to the cached index.html when offline.
 *  - Static assets are served stale-while-revalidate so they update in the
 *    background while remaining instantly available offline.
 *
 * Bump APP_SHELL_VERSION whenever you publish a new build to force the app
 * shell cache to refresh.
 */
'use strict';

const APP_SHELL_VERSION = 'flutbook-shell-v1';
const STATIC_VERSION = 'flutbook-static-v1';

const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(APP_SHELL_VERSION)
      .then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter(
              (key) =>
                key !== APP_SHELL_VERSION && key !== STATIC_VERSION,
            )
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);

  // Only handle same-origin requests; let cross-origin (e.g. CDNs, OAuth)
  // requests go straight to the network untouched.
  if (url.origin !== self.location.origin) return;

  // Network-first for navigations (the app shell), so offline loads serve the
  // last known-good app.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(APP_SHELL_VERSION).then((cache) => cache.put('./index.html', copy));
          return response;
        })
        .catch(() =>
          caches.match(request).then((cached) => cached || caches.match('./index.html')),
        ),
    );
    return;
  }

  // Static assets: stale-while-revalidate.
  event.respondWith(
    caches.match(request).then((cached) => {
      const network = fetch(request)
        .then((response) => {
          if (response && response.status === 200 && response.type === 'basic') {
            const copy = response.clone();
            caches.open(STATIC_VERSION).then((cache) => cache.put(request, copy));
          }
          return response;
        })
        .catch(() => cached);
      return cached || network;
    }),
  );
});
