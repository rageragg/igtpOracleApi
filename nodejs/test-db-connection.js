const oracledb = require('oracledb');

const configs = [
    { user: "IGTP", password: "IGTP", connectString: "localhost:1521/XE", name: "IGTP/IGTP @ localhost" },
    { user: "igtp", password: "igtp", connectString: "localhost:1521/XE", name: "igtp/igtp @ localhost" },
    { user: "IGTP", password: "igtp", connectString: "localhost:1521/XE", name: "IGTP/igtp @ localhost" },
    { user: "igtp", password: "IGTP", connectString: "localhost:1521/XE", name: "igtp/IGTP @ localhost" },
    { user: "IGTP", password: "IGTP", connectString: "127.0.0.1:1521/XE", name: "IGTP/IGTP @ 127.0.0.1" },
];

async function test() {
    for (const config of configs) {
        console.log(`Testing ${config.name}...`);
        let connection;
        try {
            connection = await oracledb.getConnection(config);
            console.log(`  SUCCESS! Connected.`);
            await connection.close();
            return; // Stop after first success
        } catch (err) {
            console.log(`  FAILED: ${err.message}`);
        }
    }
    console.log("All attempts failed.");
}

test();
