const oracledb = require('oracledb');
require('dotenv').config();

// Enable AutoCommit by default for this simple CRUD app
oracledb.autoCommit = true;

const dbConfig = {
  user: process.env.DB_USER || "igtp",
  password: process.env.DB_PASSWORD || "igtp",
  connectString: process.env.DB_CONNECT_STRING || "localhost:1521/XE",
};

async function initialize() {
  try {
    await oracledb.createPool({
      user: dbConfig.user,
      password: dbConfig.password,
      connectString: dbConfig.connectString,
      poolMin: 1,
      poolMax: 10,
      poolIncrement: 1
    });
    console.log('Connection pool started');
  } catch (err) {
    console.error('init() error: ' + err.message);
    process.exit(1);
  }
}

async function close() {
  try {
    await oracledb.getPool().close(10);
    console.log('Pool closed');
  } catch (err) {
    console.error('close() error: ' + err.message);
  }
}

module.exports = {
  initialize,
  close
};
