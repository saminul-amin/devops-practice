import express from 'express';
import client from 'prom-client';

const app = express();
const port = 4001;

// Create a Registry which registers the metrics
const register = new client.Registry();

// Add a default label which is added to all metrics
client.collectDefaultMetrics({ register });

// Create a custom counter metric
const eventCounter = new client.Counter({
  name: 'analytics_events_total',
  help: 'Total number of analytics events received',
  labelNames: ['type'],
});

register.registerMetric(eventCounter);

app.use(express.json());

app.post('/event', (req, res) => {
  const { type } = req.body;
  if (!type) {
    return res.status(400).send('Event type is required');
  }
  
  // Increment the counter
  eventCounter.inc({ type });
  
  console.log(`Received event of type: ${type}`);
  res.send('Event recorded');
});

// Expose metrics for Prometheus
app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

app.get('/health', (req, res) => {
  res.send('OK');
});

app.listen(port, () => {
  console.log(`Analytics service listening on port ${port}`);
});
