const CACHE_VERSION = 'roteiro-cuiaba-v8-auth';
const APP_SHELL = [
  './',
  './index.html',
  './dashboard.html',
  './agora.html',
  './clinicas.html',
  './editar.html',
  './login.html',
  './recuperar-senha.html',
  './nova-senha.html',
  './css/auth.css',
  './js/supabase-client.js',
  './js/auth-guard.js',
  './config/excel-online.js',
  './js/excel-online.js',
  './manifest.webmanifest',
  './offline.html',
  './icons/app-icon.svg',
  './icons/app-icon-192.png',
  './icons/app-icon-512.png',
  'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css',
  'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then(cache => Promise.allSettled(APP_SHELL.map(resource => cache.add(resource))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(key => key !== CACHE_VERSION).map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;

  const requestUrl = new URL(event.request.url);
  const isPrivateData = requestUrl.hostname.endsWith('.supabase.co') ||
    requestUrl.pathname.endsWith('/data/schedule-data.js') ||
    requestUrl.pathname.endsWith('/config/supabase.js');
  if (isPrivateData) {
    event.respondWith(fetch(event.request));
    return;
  }

  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          const copy = response.clone();
          caches.open(CACHE_VERSION).then(cache => cache.put(event.request, copy));
          return response;
        })
        .catch(() => caches.match(event.request).then(response => response || caches.match('./offline.html')))
    );
    return;
  }

  const isMapTile = event.request.url.includes('server.arcgisonline.com');
  event.respondWith(
    caches.match(event.request).then(cached => {
      const network = fetch(event.request).then(response => {
        if (response && (response.ok || response.type === 'opaque')) {
          const copy = response.clone();
          caches.open(CACHE_VERSION).then(cache => cache.put(event.request, copy));
        }
        return response;
      });
      return cached || network.catch(() => isMapTile ? new Response('', { status: 504 }) : cached);
    })
  );
});
