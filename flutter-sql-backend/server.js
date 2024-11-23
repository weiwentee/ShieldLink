const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');

const dotenv = require('dotenv');
dotenv.config(); // Load .env variables

const app = express();
app.use(bodyParser.json());

// Database Connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,      // Load from .env
    user: process.env.DB_USERNAME,      // Load from .env
    password: process.env.DB_PASSWORD, // Load from .env
    database: process.env.DB_NAME,  // Load from .env
    port: process.env.DB_PORT       // Load from .env
});

db.connect((err) => {
  if (err) {
    console.error('Database connection failed:', err);
    return;
  }
  console.log('Connected to DigitalOcean MySQL');
});

// Routes
app.post('/api/register', async (req, res) => {
  const { organisation_name, email, password } = req.body;

  // Hash password
  const hashedPassword = await bcrypt.hash(password, 10);

  db.query(
    'INSERT INTO users (organisation_name, email, password) VALUES (?, ?, ?)',
    [organisation_name, email, hashedPassword],
    (err) => {
      if (err) {
        res.status(500).send('Database error: ' + err.message);
      } else {
        res.status(201).send('User registered successfully');
      }
    }
  );
});

app.post('/api/login', (req, res) => {
  const { email, password } = req.body;

  db.query(
    'SELECT * FROM users WHERE email = ?',
    [email],
    async (err, results) => {
      if (err || results.length === 0) {
        res.status(401).send('Invalid credentials');
      } else {
        const isPasswordValid = await bcrypt.compare(password, results[0].password);
        if (isPasswordValid) {
          res.status(200).send('Login successful');
        } else {
          res.status(401).send('Invalid credentials');
        }
      }
    }
  );
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});

app.get('/test-db', (req, res) => {
  db.query('SELECT 1 + 1 AS result', (err, results) => {
    if (err) {
      res.status(500).send('Database query failed: ' + err.message);
    } else {
      res.send('Database connected. Result: ' + results[0].result);
    }
  });
});



