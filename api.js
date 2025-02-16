const express = require('express');
const { PrismaClient } = require('@prisma/client');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

// Register user and create default settings
app.post('/api/register', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user with default settings in a transaction
    const result = await prisma.$transaction(async (prisma) => {
      // Create user
      const user = await prisma.user.create({
        data: {
          email,
          password: hashedPassword,
        },
      });

      // Create default settings
      const settings = await prisma.settings.create({
        data: {
          userId: user.id,
          responseTimeThreshold: 200,
          testFrequency: 5,
          emailNotifications: true,
          slackNotifications: false,
          notificationEmail: email, // Use registration email as default
          slackWebhookUrl: null,
        },
      });

      return { user, settings };
    });

    // Generate JWT token
    const token = jwt.sign(
      { userId: result.user.id, email: result.user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    res.json({
      message: 'User registered successfully',
      token,
      userId: result.user.id,
      settings: result.settings
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Login user
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user with their settings and endpoints
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        settings: true,
        endpoints: true,
      },
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    res.json({
      token,
      userId: user.id,
      settings: user.settings,
      endpoints: user.endpoints
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user settings
app.get('/api/settings/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const settings = await prisma.settings.findUnique({
      where: {
        userId
      }
    });

    if (!settings) {
      return res.status(404).json({ error: 'Settings not found' });
    }

    res.json(settings);
  } catch (error) {
    console.error('Error fetching settings:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update user settings
app.put('/api/settings/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const {
      responseTimeThreshold,
      testFrequency,
      emailNotifications,
      slackNotifications,
      notificationEmail,
      slackWebhookUrl
    } = req.body;

    const settings = await prisma.settings.update({
      where: {
        userId
      },
      data: {
        responseTimeThreshold,
        testFrequency,
        emailNotifications,
        slackNotifications,
        notificationEmail,
        slackWebhookUrl
      }
    });

    res.json({
      message: 'Settings updated successfully',
      settings
    });
  } catch (error) {
    console.error('Error updating settings:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user endpoints
app.get('/api/endpoints/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const endpoints = await prisma.endpoint.findMany({
      where: {
        userId
      }
    });

    res.json(endpoints);
  } catch (error) {
    console.error('Error fetching endpoints:', error);
    res.status(500).json({ error: error.message });
  }
});

// Add new endpoint
app.post('/api/endpoints', async (req, res) => {
  try {
    const { userId, name, url, method, headers, requestBody, expectedResponseTime } = req.body;

    const endpoint = await prisma.endpoint.create({
      data: {
        userId,
        name,
        url,
        method,
        headers,
        requestBody,
        expectedResponseTime
      }
    });

    res.json({
      message: 'Endpoint added successfully',
      endpoint
    });
  } catch (error) {
    console.error('Error adding endpoint:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete endpoint
app.delete('/api/endpoints/:id', async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.endpoint.delete({
      where: {
        id: parseInt(id)
      }
    });

    res.json({
      message: 'Endpoint deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting endpoint:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('Available endpoints:');
  console.log('- POST   /api/register');
  console.log('- POST   /api/login');
  console.log('- GET    /api/settings/:userId');
  console.log('- PUT    /api/settings/:userId');
  console.log('- GET    /api/endpoints/:userId');
  console.log('- POST   /api/endpoints');
  console.log('- DELETE /api/endpoints/:id');
  console.log('- GET    /health');
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('Shutting down server...');
  await prisma.$disconnect();
  process.exit(0);
});
