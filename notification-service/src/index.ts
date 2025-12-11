import express from 'express';

const app = express();
const port = 4002;

app.use(express.json());

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
