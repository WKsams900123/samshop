// 会员店优选代购 - Service Worker
const CACHE_NAME = 'vipshop-v2';
const ASSETS = [
  './',
  './index.html',
  './manifest.json'
];

// 安装：预缓存核心资源
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(ASSETS).catch(() => {});
    })
  );
  self.skipWaiting();
});

// 激活：清理旧缓存
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

// 拦截请求：网络优先，失败时用缓存
self.addEventListener('fetch', event => {
  // 跳过 Supabase API 请求（让它们直连）
  if (event.request.url.includes('supabase.co')) {
    return;
  }
  // 跳过 POST 请求
  if (event.request.method !== 'GET') {
    return;
  }
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // 缓存成功的响应
        const clone = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        return response;
      })
      .catch(() => {
        return caches.match(event.request).then(cached => {
          return cached || new Response('网络不可用，请稍后重试', {
            status: 503,
            headers: { 'Content-Type': 'text/plain; charset=utf-8' }
          });
        });
      })
  );
});
