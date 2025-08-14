import express from 'express';
import { Client } from '@elastic/elasticsearch';
import maxmind from 'maxmind';

const app = express();
const port = 8080;

const ELASTIC_URL = process.env.ELASTIC_URL || 'http://localhost:9200';
const ELASTIC_USER = process.env.ELASTIC_USER || 'elastic';
const ELASTIC_PASS = process.env.ELASTIC_PASS || 'changeme';
const GEO_CITY_DB = process.env.GEO_CITY_DB || '/geoip/GeoLite2-City.mmdb';
const GEO_ASN_DB = process.env.GEO_ASN_DB || '/geoip/GeoLite2-ASN.mmdb';

const es = new Client({ node: ELASTIC_URL, auth: { username: ELASTIC_USER, password: ELASTIC_PASS } });

let cityReader = null;
let asnReader = null;

(async () => {
  try {
    cityReader = await maxmind.open(GEO_CITY_DB);
  } catch (e) { console.warn('City DB not loaded:', e.message); }
  try {
    asnReader = await maxmind.open(GEO_ASN_DB);
  } catch (e) { console.warn('ASN DB not loaded:', e.message); }
})();

app.get('/api/health', (req, res) => {
  res.json({ ok: true, elastic: ELASTIC_URL });
});

app.get('/api/events', async (req, res) => {
  const { since = 'now-1h', until = 'now', severity = 0, size = 200 } = req.query;
  try {
    const resp = await es.search({
      index: ['filebeat-*','suricata-*','zeek-*','*'],
      size: Math.min(parseInt(size, 10) || 200, 1000),
      sort: [{ "@timestamp": { "order": "desc" } }],
      query: {
        bool: {
          filter: [
            { range: { "@timestamp": { gte: since, lte: until } } },
            { range: { "alert.severity": { gte: Number(severity) } } }
          ]
        }
      }
    });
    const items = resp.hits.hits.map(h => {
      const s = h._source || {};
      const src = s.src_ip || s["id.orig_h"];
      const dst = s.dest_ip || s["id.resp_h"];
      const geo = cityReader && src ? cityReader.get(src) : null;
      const asn = asnReader && src ? asnReader.get(src) : null;
      return {
        ts: s['@timestamp'],
        src_ip: src,
        dest_ip: dst,
        signature: s.alert?.signature || s['note'] || null,
        severity: s.alert?.severity ?? s.severity ?? null,
        http: s.http || null,
        dns: s.dns || null,
        geo: geo ? { country: geo.country?.iso_code, city: geo.city?.names?.en, location: geo.location } : null,
        asn: asn ? { num: asn.autonomous_system_number, org: asn.autonomous_system_organization } : null
      };
    });
    res.json({ items });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

// Simple static demo page with Leaflet map (proxy-less)
app.get('/', (req, res) => {
  res.setHeader('content-type', 'text/html; charset=utf-8');
  res.end(`<!DOCTYPE html>
<html><head>
<meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css"/>
<title>MiniSOC GeoTrace</title>
<style>html,body,#map{height:100%;margin:0;padding:0}</style>
</head>
<body>
<div id="map"></div>
<script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
<script>
  const map = L.map('map').setView([13.736717, 100.523186], 3);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
  async function load() {
    const r = await fetch('/api/events?severity=1&size=300');
    const { items } = await r.json();
    items.forEach(ev => {
      const loc = ev.geo && ev.geo.location;
      if (loc && loc.latitude && loc.longitude) {
        const m = L.marker([loc.latitude, loc.longitude]).addTo(map);
        m.bindPopup(\`
          <b>\${ev.signature || 'event'}</b><br/>
          \${ev.src_ip} → \${ev.dest_ip}<br/>
          \${ev.ts}
        \`);
      }
    });
  }
  load();
</script>
</body></html>`);
});

app.listen(port, () => console.log(`MiniSOC API on :${port}`));
