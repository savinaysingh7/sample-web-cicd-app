const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('<h1>Sample Web App deployed via Jenkins CI/CD! (Webhook test: May 2026)</h1>');
});

app.listen(port, () => {
  console.log(`App running at http://localhost:${port}`);
});
