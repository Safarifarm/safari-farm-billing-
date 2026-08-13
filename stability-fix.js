// Stability mode: remove old offline workers/caches and stale remembered sessions.
localStorage.removeItem('safari_session');
sessionStorage.removeItem('safari_restore_attempted');
if('serviceWorker' in navigator){
  navigator.serviceWorker.getRegistrations().then(items=>items.forEach(item=>item.unregister()));
}
if('caches' in window){caches.keys().then(keys=>keys.forEach(key=>caches.delete(key)))}
