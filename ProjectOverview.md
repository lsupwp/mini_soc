# Mini SOC – Proposal

## 1. เครื่องมือที่ต้องใช้
เพื่อให้ระบบ Mini SOC ทำงานได้ครบตามฟีเจอร์ที่ออกแบบไว้ จำเป็นต้องใช้เครื่องมือและเทคโนโลยีดังนี้:

### Core IDS/IPS Engine
- **Suricata** – ตรวจจับการโจมตีด้วย signature และ anomaly detection
- **Zeek** – วิเคราะห์พฤติกรรมเชิงลึกและตรวจจับเหตุการณ์ใน Layer 7

### Log Management & Storage
- **Elasticsearch** – จัดเก็บและค้นหา log ขนาดใหญ่
- **Logstash / Filebeat** – ส่ง log จาก sensor ไปยัง storage
- **Kibana** – แสดงข้อมูลในรูปแบบ dashboard

### Real-Time Alert & Notification
- **Alertmanager / ElastAlert** – จัดการการแจ้งเตือนตามเงื่อนไข
- Integration กับ **Telegram API / Slack API / Email SMTP** – ส่งแจ้งเตือนหลายช่องทาง

### GeoIP & Threat Intelligence
- **MaxMind GeoIP Database** – ระบุตำแหน่งทางภูมิศาสตร์ของ IP
- **AbuseIPDB API / AlienVault OTX API** – ตรวจสอบประวัติความเสี่ยงของ IP

### Incident Timeline & Reporting
- **Timesketch** – ใช้สร้างและจัดการ timeline ของเหตุการณ์
- **Grafana** – สร้าง dashboard และ report ประสิทธิภาพสูง

---

## 2. ข้อดีข้อเสียของระบบ (ในการใช้งานจริง)

### ข้อดี
1. **ครบวงจรในตัวเดียว** – มีทั้งตรวจจับ วิเคราะห์ และแสดงผลแบบ Dashboard
2. **รองรับหลายแหล่งข้อมูล** – สามารถดึงข้อมูลจาก sensor หลายจุดในเครือข่าย
3. **แจ้งเตือน Real-Time** – ผู้ดูแลรู้ปัญหาทันทีผ่านหลายช่องทาง
4. **มี Threat Intelligence** – ตรวจสอบและเชื่อมข้อมูลกับฐานข้อมูลภายนอกเพื่อเพิ่มความแม่นยำ
5. **เก็บข้อมูลย้อนหลังได้** – ค้นหาและทำ forensic ได้ในอนาคต

### ข้อเสีย
1. **ต้องการทรัพยากรเครื่องสูง** – โดยเฉพาะ CPU และ RAM ถ้า traffic มาก
2. **ต้องการการปรับแต่ง rule** – เพื่อให้ลด false positive
3. **ต้องบำรุงรักษา Database และ Dashboard** – เช่น การอัปเดต GeoIP และ Threat Intel
4. **การตั้งค่าเริ่มต้นซับซ้อน** – ต้องใช้ความรู้ด้าน network และ security

---

## 3. จุดเด่นของเราที่ดีกว่าระบบอื่น (ในการใช้งานจริง)

1. **การผสาน Suricata + Zeek** – ได้ทั้งการตรวจจับเชิง signature และพฤติกรรม ซึ่ง IDS ทั่วไปมักเลือกอย่างใดอย่างหนึ่ง
2. **มี Trace Route Attack Source** – สามารถย้อนรอยเส้นทางการโจมตีแบบ visual ซึ่งหลาย SOC ไม่มี
3. **Incident Timeline** – ช่วยให้ทีม Security เห็นภาพรวมการโจมตีแบบเรียงเหตุการณ์
4. **Threat Intelligence แบบ Real-Time** – ดึงข้อมูลจากหลายฐานพร้อม GeoIP ทำให้รู้ว่า IP นั้นมีประวัติหรือไม่
5. **ออกแบบมาให้ติดตั้งง่ายในเครือข่ายเล็ก-กลาง** – Mini SOC สามารถ deploy ในองค์กรขนาดเล็กได้โดยไม่ต้องลงทุนสูง
6. **Dashboard และ Alert ปรับแต่งได้เอง** – ผู้ใช้งานสามารถเลือกดูเฉพาะ metric ที่สนใจ

---

## 4. ฟีเจอร์ที่ระบบนี้มี
- Real-Time Alert + Multi-Channel Notification
- Incident Timeline & Attack Session Tracking
- GeoIP + Threat Intelligence Integration
- Historical Search & Reporting
- Attack Source Trace Routing
- Graph Dashboard Analytics

---

## 5. เป้าหมายการใช้งาน
- ใช้ในองค์กรขนาดเล็ก-กลางเพื่อเฝ้าระวังการโจมตี
- ช่วยทีม IT Security ตอบสนองต่อเหตุการณ์ได้เร็วขึ้น
- ลดต้นทุนในการจัดตั้ง SOC แบบเต็มรูปแบบ
