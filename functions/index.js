const {onRequest} = require('firebase-functions/v2/https');

const UPSTREAM_ORIGIN = 'https://fasakhaninja.com';

exports.apiProxy = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 60,
  },
  async (req, res) => {
    try {
      let path = req.originalUrl || req.url || '/';
      if (!path.startsWith('/api/')) {
        path = `/api${path.startsWith('/') ? path : `/${path}`}`;
      }

      const target = new URL(path, UPSTREAM_ORIGIN);
      const headers = {};

      for (const name of ['accept', 'content-type', 'authorization', 'lang']) {
        const value = req.headers[name];
        if (value) headers[name] = value;
      }

      const method = req.method.toUpperCase();
      const requestInit = {
        method,
        headers,
        redirect: 'follow',
      };

      if (method !== 'GET' && method !== 'HEAD' && req.rawBody?.length) {
        requestInit.body = req.rawBody;
      }

      const upstream = await fetch(target, requestInit);

      res.status(upstream.status);
      const contentType = upstream.headers.get('content-type');
      if (contentType) res.set('content-type', contentType);
      res.set('cache-control', 'no-store');

      const buffer = Buffer.from(await upstream.arrayBuffer());
      res.send(buffer);
    } catch (error) {
      console.error('API proxy failed', error);
      res.status(502).json({
        message: 'API proxy failed',
      });
    }
  },
);
