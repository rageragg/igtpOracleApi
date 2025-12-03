const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const db = require('./config/db');
const countriesRoutes = require('./routes/countries');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Routes
app.use('/api/countries', countriesRoutes);

// Start server
async function startServer() {
    try {
        await db.initialize();
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    } catch (err) {
        console.error('Failed to start server:', err);
        process.exit(1);
    }
}

startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('Closing server...');
    await db.close();
    process.exit(0);
});

process.on('SIGINT', async () => {
    console.log('Closing server...');
    await db.close();
    process.exit(0);
});
