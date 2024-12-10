const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config(); // Load environment variables

const app = express();

// Middleware to parse JSON
app.use(bodyParser.json());

// CORS configuration: Allow only specific origins (for security)
const allowedOrigins = ['http://localhost:52727', 'http://localhost:49319']; // Add more origins as needed

// // CORS middleware setup
// app.use(cors({
//   origin: function (origin, callback) {
//     if (!origin || allowedOrigins.indexOf(origin) !== -1) {
//       callback(null, true);
//     } else {
//       callback(new Error('Not allowed by CORS'));
//     }
//   },
//   methods: ['GET', 'POST', 'PUT', 'DELETE'],
//   allowedHeaders: ['Content-Type', 'Authorization'],
//   preflightContinue: false,
//   optionsSuccessStatus: 200
// }));



// // Handling preflight (OPTIONS) requests explicitly if needed
// // This ensures CORS headers are sent on every OPTIONS request
// app.options('*', (req, res) => {
//   res.header('Access-Control-Allow-Origin', '*');  // Or specify allowed origin here
//   res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
//   res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
//   res.sendStatus(200);  // Respond with status 200 OK
// });
// CORS middleware allowing all origins
app.use(cors({
  origin: '*',  // Allow any origin
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Handle preflight (OPTIONS) request explicitly
app.options('*', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.sendStatus(200);
});


// Database Connection
const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USERNAME || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'test',
  port: process.env.DB_PORT || 3306,
  ssl: {
    ca: fs.readFileSync(path.join(__dirname, 'certs', 'ca-certificate.crt')),
  },
});

// Test database connection
connection.connect((err) => {
  if (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1); // Exit process if database connection fails
  }
  console.log('✅ Connected to DigitalOcean MySQL');
});

// Registration route
app.post('/api/register', async (req, res) => {
  const { organisation_name, email, password } = req.body;

  try {
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user into database
    connection.query(
      'INSERT INTO users (organisation_name, email, password) VALUES (?, ?, ?)',
      [organisation_name, email, hashedPassword],
      (err) => {
        if (err) {
          console.error('❌ Database error:', err.message);
          res.status(500).send('Database error: ' + err.message);
        } else {
          res.status(201).send('User registered successfully');
        }
      }
    );
  } catch (error) {
    console.error('❌ Error in registration:', error.message);
    res.status(500).send('Error in registration: ' + error.message);
  }
});

// Login route
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;

  connection.query(
    'SELECT * FROM users WHERE email = ?',
    [email],
    async (err, results) => {
      if (err) {
        console.error('❌ Database query error:', err.message);
        res.status(500).send('Database query error: ' + err.message);
      } else if (results.length === 0) {
        res.status(401).send('Invalid credentials');
      } else {
        try {
          // Compare the hashed password
          const isPasswordValid = await bcrypt.compare(password, results[0].password);

          if (isPasswordValid) {
            res.status(200).send('Login successful');
          } else {
            res.status(401).send('Invalid credentials');
          }
        } catch (error) {
          console.error('❌ Error validating password:', error.message);
          res.status(500).send('Error validating password');
        }
      }
    }
  );
});

// Test database query
app.get('/test-db', (req, res) => {
  connection.query('SELECT 1 + 1 AS result', (err, results) => {
    if (err) {
      console.error('❌ Database query error:', err.message);
      res.status(500).send('Database query error: ' + err.message);
    } else {
      res.send('✅ Database connected. Result: ' + results[0].result);
    }
  });
});

// Start server
const PORT = process.env.APP_PORT || 3000;
const HOST = process.env.APP_HOST || '0.0.0.0'; // Bind explicitly to localhost

app.listen(PORT, HOST, (err) => {
  if (err) {
    console.error(`❌ Failed to bind server: ${err.message}`);
  } else {
    console.log(`🚀 Server is running on http://${HOST}:${PORT}`);
    setInterval(() => console.log('Server is still running...'), 10000); // Keep logs active
  }
});

console.log('Absolute path to cert:', path.join(__dirname, 'certs', 'ca-certificate.crt'));
