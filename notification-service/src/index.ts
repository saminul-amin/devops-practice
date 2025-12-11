import express from 'express';
import client from 'prom-client';

const app = express();
const port = 4002;

// Create a Registry which registers the metrics
const register = new client.Registry();

// Add a default label which is added to all metrics
client.collectDefaultMetrics({ register });

app.use(express.json());

// Expose metrics for Prometheus
app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

app.post('/notify', (req, res) => {
  const { message, recipient } = req.body;
  
  if (!message || !recipient) {
    return res.status(400).send('Message and recipient are required');
  }

  // Simulate sending a notification
  console.log(`Sending notification to ${recipient}: ${message}`);
  
  res.send('Notification sent');
});

app.get('/health', (req, res) => {
  res.send('OK');
});

app.listen(port, () => {
  console.log(`Notification service listening on port ${port}`);
});
