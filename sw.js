// Service worker: сохраняет приложение на устройстве, чтобы оно открывалось без интернета.
// При изменении файлов увеличьте номер версии — тогда устройства подтянут обновление.
const VERSION = "notes-v15";
const SHELL = [
  "./", "./index.html", "./config.js", "./manifest.webmanifest",
  "./icons/icon-192.png", "./icons/icon-512.png", "./icons/maskable-512.png", "./icons/apple-touch-icon.png",
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.min.js"
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  // Запросы к базе синхронизации никогда не кэшируем
  if (url.hostname.endsWith("supabase.co")) return;
  const cacheable = url.origin === location.origin ||
    url.hostname === "cdn.jsdelivr.net" ||
    url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com";
  if (!cacheable) return;

  // Сеть в приоритете (чтобы обновления доходили), при отсутствии сети — из кэша
  e.respondWith(
    fetch(req).then(res => {
      if (res && (res.ok || res.type === "opaque")) {
        const copy = res.clone();
        caches.open(VERSION).then(c => c.put(req, copy));
      }
      return res;
    }).catch(() => caches.match(req, { ignoreSearch: true }).then(r => r || caches.match("./index.html")))
  );
});
