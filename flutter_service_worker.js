'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "212e33efadd661de163c79419106997f",
"assets/AssetManifest.bin.json": "7cafde4869aa7f6a3748ced324857ad1",
"assets/AssetManifest.json": "d01c93039aafeabf0e0f91638f77a826",
"assets/assets/application.env": "11b60fd9379897b26e1fadb80c964915",
"assets/FontManifest.json": "1c42579d5aff402a532cb77e5f83cf1a",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/fonts/NanumGothic.ttf": "77c9de73515a7120ac94e052eaa9218e",
"assets/fonts/NanumGothicBold.ttf": "0c2ca147bcb8d81b0c38f7a321dda093",
"assets/fonts/NanumGothicExtraBold.ttf": "7fd24002cc6fd468acb094a4708023e9",
"assets/fonts/NanumGothicLight.ttf": "5db59e927b2a6739d004c9c291233e5b",
"assets/image/markers/marker_black.png": "23470ae3800573c1f82aaa09172c5c2c",
"assets/image/markers/marker_blue1.png": "66e077cb0cbe6f97b39469a988d93a25",
"assets/image/markers/marker_blue2.png": "cce2f504966c01dd6c4a2737ee016edd",
"assets/image/markers/marker_blue3.png": "23648cadf961ada9cedd3bc0f74c06f5",
"assets/image/markers/marker_cyan.png": "d6e5e9e405a74d8b9bf1a6ed8a8ec0f7",
"assets/image/markers/marker_green1.png": "1d0a968fcff875456ca76160ed630a04",
"assets/image/markers/marker_green2.png": "b77a0245ad9b7e0fbd196cb4fec7876c",
"assets/image/markers/marker_pink1.png": "35f45c0a6a6bcc7dac81acb9ad634354",
"assets/image/markers/marker_pink2.png": "a297351196ea68df7a8522b795bd9ab0",
"assets/image/markers/marker_purple1.png": "4d1bbdcb2db151fc9deb84cc3a1d8c1f",
"assets/image/markers/marker_purple2.png": "5010fdf653484cac49f1bd8b2d48893f",
"assets/image/markers/marker_red1.png": "daec9537cabf5ee0ff06e1238448fad2",
"assets/image/markers/marker_red2.png": "f64fe9293da66ce4729d2c0caa78f871",
"assets/image/markers/marker_red3.png": "52a1a888de0493433ff0080d3645c312",
"assets/image/markers/marker_teal.png": "cfc934c2632d31091697118ccbcb6bdb",
"assets/image/markers/marker_yellow.png": "6f0c7222d053462a285855c5f86d79b3",
"assets/image/marker_blue.png": "f429578fcc9e93320164e4f3f8b9f971",
"assets/image/marker_green.png": "b8d1277dc3896d860a785b8d09fe8bb8",
"assets/image/marker_purple.png": "05b3e3fd90d4c174d481a1ba07ac7af4",
"assets/image/marker_red.png": "050c02ec76891a1667608d6d9cdbe82c",
"assets/image/pin_black.png": "d92e0226c1effdcab39e8acf69dbc5e2",
"assets/image/pin_blue.png": "ea822fa856abe2aeab54ad2b6f3ee2e5",
"assets/image/pin_cyan.png": "e29f281f1e3e37a98565928121f170af",
"assets/image/pin_green.png": "15567f0154cb5bfa39b83a0b6d0d4469",
"assets/image/pin_grey.png": "73758350faeedebbb366e73b95b90f0f",
"assets/image/pin_pink.png": "3a531d296b100165763bbca0db81c634",
"assets/image/pin_purple.png": "2d530a143ebf152579bf919ff0449bbb",
"assets/image/pin_red.png": "2331019dca357bea1b9e1d1b12284d14",
"assets/image/pin_yellow.png": "13492a3b3286bda6a975698af7a3ce04",
"assets/image/smile.jpg": "39b09d453f51e5ab698e17b1baa6825c",
"assets/NOTICES": "33b341ba8ded91f02fb1e9df5b56cf1b",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/kakao_map_plugin/assets/images/marker.png": "12bf67c50646e79b2efb6246b3631612",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "a5f1940ee8a0944b2fba4cc3daea11ef",
"/": "a5f1940ee8a0944b2fba4cc3daea11ef",
"main.dart.js": "ed2564d5907f7d75a84e18ac29f557c0",
"manifest.json": "cdac920e092974e26d0a19f7c7402efa",
"version.json": "4178b17a8253f1ed6c293e10aea5754a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
