const CACHE='safari-farm-v2'; const ASSETS=['./','./index.html','./styles.css','./app.js','./config.js','./logo-source.png'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('fetch',e=>e.respondWith(fetch(e.request).catch(()=>caches.match(e.request))));
