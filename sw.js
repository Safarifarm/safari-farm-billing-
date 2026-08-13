const CACHE='safari-farm-v8'; const ASSETS=['./','./index.html','./styles.css','./app.js','./config.js','./login-fix.js','./invoice-inline.js','./remember-login.js','./logo-source.png'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('fetch',e=>e.respondWith(fetch(e.request).catch(()=>caches.match(e.request))));
