# Microservices E-commerce Platform with Monitoring

This project demonstrates a production-ready microservices architecture for an e-commerce platform. It features independent services for backend logic, analytics, and notifications, all orchestrated via Docker Compose and monitored using Prometheus and Grafana.

## 🏗 Architecture Overview

The system consists of the following components:

![Architecture Diagram](https://mermaid.ink/img/pako:eNptkU1PwzAMhv9K5BMo2924zQMS101C4oAQ4sKFi9usq01FkjpNo2n_nTRdQHDis-3Yj99X5z0qjQoUSftW8d6wBn2tLIOnR7AsX-BlsQSLoqJ3vEFP0N_d3oJ5s4Yv2-0W7jdbWKyW4K83MC8_wLw8gqfHB3h8eoTFcgGrt7fwerOGL9sP8P2z3YJ5swF_vYJ5eQTz8gOsyw9Yvy7B_LxE1_wA6_IDrF_esP64f4D1yxt4fnyA1dsbeH1cwbfPdhvmzRq-bd_Dt_fbLbzefoDvn210zW_Q392C_n4D_f1H_P_yA6zL98j6H8gGssF3ZAPZQDZ0A9nQDWSD78gGsoFs6AaywdcM3eDvBvpvDP5u8HcD2eDrBrLBHyD72w_w_bONrvkN-rtb8HcD2eDrBrLB1w3d4H8r6H8x-LuB_n4D2eDrBrLB1w1kg68byAZfN5ANvm4gG_zdQDb4uqEb_N1ANvi6oRv83UA2-LqBbPB1A9ng6waywdcNZIOvG8gGXzeQDb5uiP-_wXdkA9nQDWSDr8kG35ENZEM3kA3dQDb4jmzwh2zwHdlANnQD2eDrmqEb_AnZ4DuygWyIbPAd2UA2RDb4jmzwJ2SDP2eD78gGsiGywXdkA9kQ2eA7ssGfkA3-nA2-IxvIhsgG35ENZEM3kA3dQDb4jmzwJ2SD78hG1_wG_d0tdM1v0N_dQtf8Bv3dLXRN9j8y2eA7stE12f_IZIPvyEbXZP8jkw2-IxvIhm4gG7qBbPAd2eA7stE1f0L2PzLZ4DuygWyIbPAd2UA2RDb4jmzwh2wgG3xHNpANkQ2-IxvIhsgG35EN_pANZIPvyAayIbLBd2QD2RDZ4DuywR-yQa75E7LBn5ANZN-yIbLBd2QD2RDZ4DuywZ-QDWTfsiGywXdkA9kQ2eA7ssGfkA1k37LBNdkA2eA7soFsiGzwHdlANkQ2-I5s8Cf_A2SD78gGsiGywXdkA9kQ2eA7ssGf_A-QDb4jG8iGyAbfkQ1kQ2SD78gGf_I_QDb4jmzwh2zwJ2SDP2eD78gGsiGywXdkA9kQ2eA7ssGfkA2-Ixt8RzaQDZENVc3vX5dFrQ)

1.  **API Gateway (Port 8000)**: The single entry point for all client requests. It creates a unified API surface by routing requests to the appropriate backend service.
2.  **Backend Service (Port 5000)**: The core e-commerce application logic (products, orders, etc.) connected to MongoDB.
3.  **Analytics Service (Port 4001)**: A dedicated microservice that ingests event data (e.g., "user_login", "purchase") and exposes aggregated metrics.
4.  **Notification Service (Port 4002)**: Simulates sending emails or push notifications to users.
5.  **Prometheus (Port 9090)**: Pulls (scrapes) metrics from the Analytics Service every 15 seconds.
6.  **Grafana (Port 3000)**: Visualizes the data stored in Prometheus through customizable dashboards.

### 🔄 How It Works

1.  **Data Flow**:
    *   A user performs an action (e.g., clicks "Buy").
    *   The frontend (or curl command) sends a POST request to the **Analytics Service**.
    *   The Analytics Service updates an internal counter (e.g., `analytics_events_total`).

2.  **Monitoring Flow**:
    *   **Prometheus** wakes up every 15s and requests `http://analytics:4001/metrics`.
    *   The Analytics Service responds with the current counter values in a text format Prometheus understands.
    *   **Grafana** queries Prometheus to draw graphs of how these counters change over time.

---

## 🚀 Getting Started

### Prerequisites
*   [Docker](https://docs.docker.com/get-docker/) installed.
*   [Docker Compose](https://docs.docker.com/compose/install/) installed.

### Quick Start
To run the entire system:

```bash
# 1. Start the stack
docker-compose up --build

# 2. Access the services
# Gateway: http://localhost:8000
# Grafana: http://localhost:3000 (admin/admin)
```

---

## 🛠 Building From Scratch (Step-by-Step)

If you wanted to build this system yourself, here are the commands and steps you would follow.

### 1. Initialize Project Structure
Create folders for your microservices.
```bash
mkdir -p my-app/{backend,gateway,analytics,notification}
cd my-app
```

### 2. Create Analytics Service
This service calculates metrics.

**File:** `analytics/package.json`
```json
{
  "name": "analytics-service",
  "dependencies": {
    "express": "^4.18.2",
    "prom-client": "^15.0.0"
  }
}
```

**File:** `analytics/index.js`
```javascript
const express = require('express');
const client = require('prom-client');
const app = express();

const register = new client.Registry();
client.collectDefaultMetrics({ register });

const eventCounter = new client.Counter({
  name: 'analytics_events_total',
  help: 'Total events',
  labelNames: ['type']
});
register.registerMetric(eventCounter);

app.post('/event', express.json(), (req, res) => {
    eventCounter.inc({ type: req.body.type });
    res.send('Recorded');
});

app.get('/metrics', async (req, res) => {
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());
});

app.listen(4001);
```

### 3. Dockerize Services
Create a `Dockerfile` for each service.

**File:** `analytics/Dockerfile`
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD ["node", "index.js"]
```

### 4. Orchestrate with Docker Compose
Link everything together.

**File:** `docker-compose.yml`
```yaml
version: '3.8'
services:
  analytics:
    build: ./analytics
    ports: ["4001:4001"]
  
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports: ["9090:9090"]

  grafana:
    image: grafana/grafana
    ports: ["3000:3000"]
```

### 5. Configure Prometheus
Tell Prometheus where to find metrics.

**File:** `prometheus.yml`
```yaml
scrape_configs:
  - job_name: 'analytics'
    static_configs:
      - targets: ['analytics:4001']
```

---

## 🔮 Future Upgrades

Here is how you can take this architecture to the next level:

### 1. **Kubernetes (K8s) Migration**
*   **Why**: Self-healing, auto-scaling, and rolling updates.
*   **How**: Convert `docker-compose.yml` to K8s manifests (Deployments, Services, Ingress). Use Helm for package management.

### 2. **ELK Stack (Logging)**
*   **Why**: Centralized logging. Currently, you have to check logs for each container separately.
*   **How**: Add **Elasticsearch** (storage), **Logstash** (processing), and **Kibana** (visualization) to collect logs from all Docker containers.

### 3. **Service Mesh (Istio/Linkerd)**
*   **Why**: Advanced traffic management, security (mTLS), and observability without code changes.
*   **How**: Inject sidecar proxies into your pods to handle inter-service communication.

### 4. **Event-Driven Architecture (RabbitMQ/Kafka)**
*   **Why**: Decouple services. Instead of `POST /event`, services publish messages to a queue.
*   **How**: Introduce RabbitMQ. `Backend` publishes "OrderCreated", `Analytics` subcribes to it.
