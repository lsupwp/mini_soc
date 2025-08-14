# Mini SOC – Open-Source Stack & React UI (Proposal Summary)

> โฟกัส: **โอเพนซอร์ส 100%**, ทำ **Real-time detection**, **Dashboard กราฟสวยปรับแต่งได้**, **Attack path tracing**, **GeoIP/Threat-Intel**, **Historical search/reporting**

---

## 1) High-Level Architecture

```
[Endpoints/Network]
   │            (SPAN/TAP / host)
   ├── Suricata (IDS, eve.json) ─┐
   ├── Zeek (L7 logs) ───────────┤
   │                              ├─► Shippers (Fluent Bit / Vector)
   │                              │        └─► Kafka (optional, buffer)
   │                              │
   │                              ├─► OpenSearch  (hot/warm/cold)  ──► Dashboards (OpenSearch Dashboards)
   │                              ├─► ClickHouse (optional cold-long retention)
   │                              ├─► PostgreSQL (+ TimescaleDB CE)  ──► Reporting & Incident Timeline API
   │                              ├─► Graph DB (JanusGraph / ArangoDB) ─► Attack Graph API
   │                              ├─► Redis (cache/rate-limit/state)
   │                              └─► MinIO (PCAP/Artifacts)
   │
   └── Threat Intel (MISP/OpenCTI) ─► Enricher (IOC/GeoIP/JA3/Whois) ─► Enriched indices
                                                           │
                                                   [FastAPI Backend + WS/Socket]
                                                           │
                                        ┌──────────────────┴───────────────────┐
                                        │                                      │
                              React UI Dashboard                    OpenSearch Dashboards (ready-made)
```

---

## 2) Core Components (ทั้งหมดเป็นโอเพนซอร์ส)

### Network Sensors
- **Suricata** (IDS): สร้างเหตุการณ์ `eve.json` (alerts/flows/http/dns/tls) จาก live traffic
- **Zeek**: L7 metadata ละเอียดยิบ (http/dns/conn/ssl…) ใช้คู่กับ Suricata เพื่อลด FP/เพิ่มบริบท

### Ingest & Buffer
- **Fluent Bit** / **Vector**: agent/daemon ส่ง log → OpenSearch/ClickHouse/Postgres
- **Kafka** (ทางเลือก): บัฟเฟอร์/สตรีมกรณี EPS สูง, ต่อยอด enrichment แบบแยก service

### Storage & Analytics
- **OpenSearch** + **OpenSearch Dashboards**: full-text + aggregations, alerting, anomaly detection,แดชบอร์ดสำเร็จรูป
- **PostgreSQL** (+ **TimescaleDB Community**): incident timeline, reporting/BI, SQL ง่าย, materialized views
- **Graph DB** (**JanusGraph** (Apache 2.0) หรือ **ArangoDB Community**): โหนด Host/Event/Edge ATTACKED → ใช้สอบย้อน “เส้นทางการโจมตี”
- **ClickHouse** (ตัวเลือก): เก็บ log ระยะยาวราคาถูก, คิวรี่เร็วมากสำหรับ cold data
- **Redis**: cache/rate-limit/cooldown state real-time alert
- **MinIO**: object storage สำหรับ PCAP/ไฟล์แนบ/รายงาน

### Threat Intelligence / Enrichment
- **MISP** หรือ **OpenCTI**: IOC feed (IP/domain/hash/TTPs) ผูก pipeline enrich log อัตโนมัติ
- **GeoIP**: MaxMind GeoLite2 (ฐานข้อมูลฟรี) แปะประเทศ/พิกัดให้ src/dst

### Observability
- **Prometheus** + **Grafana** + **Loki** (optional): metrics, health, infra dashboards

---

## 3) React UI (Custom Dashboard & Graph)

### Tech Choices (OSS)
- **React + TypeScript + Vite** (หรือ Next.js – ถ้าต้อง SSR)
- **TailwindCSS** + **shadcn/ui**: UI Kit ปรับแต่งไว
- **TanStack Query**: data fetching + cache
- **State Mgmt**: **Zustand** (เบา) หรือ Redux Toolkit
- **Charts**: **Apache ECharts**, **Recharts**, หรือ **Nivo** (เลือกได้ 1)
- **Network Graph**: **Cytoscape.js** หรือ **vis-network** (วาด Attack Path/Session graph)
- **Map**: **MapLibre GL JS** (โอเพนซอร์สแท้) สำหรับ Geo heatmap / attack origin
- **Realtime**: WebSocket/Socket.IO จาก **FastAPI** (Python) หรือ Node (NestJS/Express)
- **Auth/SSO**: **Keycloak** (Open Source IdP)

### Main Screens
1) **Live Overview**  
   - KPI: EPS, Alerts by severity, Top talkers, Protocol mix  
   - Timeline (sparkline) + Quick filters (src/dst/sig)
2) **Alert Triage**  
   - Table (virtualized) + facets (signature, src/dst ASN/Geo, tag TI)  
   - Right panel: packet/flow context, correlated Zeek records
3) **Attack Graph**  
   - Graph view of `Host ↔ Event ↔ Host` + session grouping, เดินย้อนเส้นทาง/แสดง hop พร้อมเวลาที่เกิด
4) **Geo View**  
   - World/Thailand map: heat/bubble แหล่งโจมตี, คลิก drill-down
5) **Search & Reports**  
   - Query Builder (KQL/OpenSearch DSL) + export (CSV/JSON/NDJSON)  
   - Prebuilt reports: daily/weekly posture, rule efficacy, top signatures
6) **Settings & Integrations**  
   - TI feeds (MISP/OpenCTI) toggle, retention/ILM, webhook/Slack/Email/Telegram

---

## 4) Data Model & Indexing (เริ่มเร็วและคุมต้นทุน)

### OpenSearch (ตัวอย่าง Index)
- `suricata-*` (`eve.json`) – map ฟิลด์สำคัญเป็น `keyword`/`ip`/`date` (เปิด `doc_values` เฉพาะที่จะ aggregate)
- `zeek-*` – http/dns/conn/ssl แยก index ชัดเจน
- `enriched-*` – ผล enrichment (GeoIP/IOC/JA3 tags)
- **ILM**: hot 7–14 วัน → warm 30–90 วัน → cold/frozen หรือย้ายไป ClickHouse (roll-over by size/time)

### PostgreSQL
- `incident_timeline(ts timestamptz, flow_id text, src inet, dst inet, sig text, sid int, severity int, ctx jsonb)`
- `rule_effectiveness(day date, sid int, hits int, fp_est numeric, notes text)`  
  → สร้าง materialized views (รายชั่วโมง/รายวัน), index บน `(ts, src, dst)`

### Graph (JanusGraph/ArangoDB)
- Nodes: `Host{ip, asn, geo, tags}`, `Event{ts, sig, sid, severity, flow_id}`  
- Edges: `(:Host)-[:ATTACKED{port,proto,ts}]->(:Host)`, `(:Event)-[:INVOLVES]->(:Host)`  
- Queries: “ต้นทางการโจมตีมาจากไหน”, “เส้นทางจาก A→B ช่วงเวลา T”, “กลุ่มเหตุการณ์เดียวกัน (community)”

---

## 5) Real-Time Alerts & Enrichment

- **Alerting**: OpenSearch Alerting plugin (OSS) + webhook Slack/Teams/Telegram/Email  
- **Realtime push**: Backend (FastAPI) subscribe index tail → ส่ง WebSocket ให้ React (sub-second UX)  
- **De-noise & Cooldown**: ใช้ Redis เก็บ key-based cooldown (src/sig) กัน spam  
- **TI/GeoIP**: Enricher service (Python) ดึง IOC จาก MISP/OpenCTI, เติม geo/asn/ja3 → เขียนลง `enriched-*`

---

## 6) Deployment (เริ่มด้วย Docker Compose, ขยายเป็น K8s ได้)

- **dev/PoC**: single host compose (OpenSearch+Dashboards, Postgres, Redis, MinIO, Suricata/Zeek, FastAPI, React)  
- **prod (กลาง)**: OpenSearch 3 โหนด, Postgres แยกเครื่อง, GraphDB แยก, Kafka (ถ้าปริมาณสูง), MinIO 3–4 โหนด  
- **observability**: Prometheus/Grafana/Loki + alert node down/disk/heap

---

## 7) ทำไมสแต็กนี้ดีสำหรับงานจริง (และยังเป็น OSS)

- **ครบเส้นทาง**: จาก packet → alert → enrich → search → timeline → graph → report  
- **คุมต้นทุน**: ใช้ OpenSearch + (ClickHouse optional) ทำ hot/cold ได้, MinIO เก็บ PCAP ยาว ๆ  
- **ยืดหยุ่น**: React UI ปรับแดชบอร์ด/กราฟ/แผนที่ได้เอง, ไม่ล็อก vendor  
- **ขยายได้**: เพิ่มโหนด/ชั้น warm/cold, เติม Kafka/stream processor ได้ภายหลัง  
- **ชุมชนเข้มแข็ง**: ทุกตัวมี community/เอกสารเยอะ, ไลเซนส์ชัดเจน

---

## 8) Suggested Tooling Checklist (OSS)

- Sensors: **Suricata**, **Zeek**  
- Shippers: **Fluent Bit** / **Vector**  
- Bus (opt): **Kafka**  
- Stores: **OpenSearch**, **PostgreSQL** (+ **TimescaleDB CE**), **JanusGraph/ArangoDB**, **Redis**, **MinIO**, **ClickHouse** (opt)  
- TI: **MISP** / **OpenCTI** + **GeoLite2**  
- Backend: **FastAPI** (+ Uvicorn, Pydantic) + **Socket.IO/WebSocket**  
- Frontend: **React + TS + Vite**, **Tailwind + shadcn/ui**, **TanStack Query**, **Cytoscape.js/vis-network**, **ECharts/Recharts**, **MapLibre GL**  
- Auth: **Keycloak**  
- Observability: **Prometheus**, **Grafana**, **Loki**

---

## 9) Roadmap (ย่อ)
- **M1**: Ingest Suricata/Zeek → OpenSearch; React UI (Overview, Alert table); GeoIP enrich  
- **M2**: Incident timeline (Postgres), WebSocket live feed, Notifications multi-channel  
- **M3**: Attack Graph (Graph DB), TI integration (MISP/OpenCTI), Reports export  
- **M4**: ILM/Retention + (optional) ClickHouse cold tier, HA hardening

---

## 10) โครงสร้างโค้ด (ตัวอย่าง)
```
mini-soc/
├─ sensors/              # suricata, zeek configs
├─ ingest/               # fluent-bit / vector configs
├─ backend/              # FastAPI (REST+WS), enricher, graph service
├─ ui/                   # React app (Vite), components, pages
├─ deploy/
│  ├─ docker-compose/    # PoC compose stacks
│  └─ k8s/               # manifests/helm (ภายหลัง)
└─ docs/                 # runbook, playbook, dashboards json
```

---

### หมายเหตุไลเซนส์
- OpenSearch/ClickHouse/JanusGraph/ArangoDB/Fluent Bit/Vector/Prometheus/FastAPI (Apache-2.0 หรือเทียบเท่า)  
- PostgreSQL (PostgreSQL License), Redis (BSD-3-Clause), Grafana/Loki/MapLibre/Cytoscape (AGPL/MIT/BSD ตามโปรเจกต์)  
- ทุกตัว **โอเพนซอร์ส** ใช้งานได้ฟรี; ตรวจสอบไลเซนส์ก่อนแจกจ่ายแบบ commercial bundle หากจำเป็น
