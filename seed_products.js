const http = require('http');

const PRODUCTS_TO_CREATE = 30;

function createProduct(index) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      name: `Product ${index}`,
      price: Math.floor(Math.random() * 1000) + 10
    });

    const options = {
      hostname: 'localhost',
      port: 8000,
      path: '/api/products',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    const req = http.request(options, (res) => {
      let responseBody = '';
      res.on('data', (chunk) => responseBody += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log(`[SUCCESS] Created Product ${index}: ${res.statusCode}`);
          resolve();
        } else {
          console.error(`[FAILED] Product ${index}: ${res.statusCode} - ${responseBody}`);
          reject(new Error(`Status ${res.statusCode}`));
        }
      });
    });

    req.on('error', (error) => {
      console.error(`[ERROR] Product ${index}:`, error.message);
      reject(error);
    });

    req.write(data);
    req.end();
  });
}

async function seed() {
  console.log(`Starting seed of ${PRODUCTS_TO_CREATE} products...`);
  let successes = 0;
  
  for (let i = 1; i <= PRODUCTS_TO_CREATE; i++) {
    try {
      await createProduct(i);
      successes++;
      // Small delay to be nice to the event loop
      await new Promise(resolve => setTimeout(resolve, 50));
    } catch (e) {
      // Continue even if one fails
    }
  }
  
  console.log(`\nSeed completed. Successfully created ${successes}/${PRODUCTS_TO_CREATE} products.`);
}

seed();
