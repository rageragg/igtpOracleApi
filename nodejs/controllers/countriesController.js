const oracledb = require('oracledb');

async function getAllCountries(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT * FROM COUNTRIES`,
            [],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}

async function getCountryById(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT * FROM COUNTRIES WHERE ID = :id`,
            [req.params.id],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Country not found" });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}

async function createCountry(req, res) {
    let connection;
    try {
        const { country_co, description, path_image, telephone_co, user_id, slug, uuid } = req.body;
        connection = await oracledb.getConnection();

        const result = await connection.execute(
            `INSERT INTO COUNTRIES (COUNTRY_CO, DESCRIPTION, PATH_IMAGE, TELEPHONE_CO, USER_ID, SLUG, UUID) 
       VALUES (:country_co, :description, :path_image, :telephone_co, :user_id, :slug, :uuid) 
       RETURNING ID INTO :id`,
            {
                country_co,
                description,
                path_image,
                telephone_co,
                user_id,
                slug,
                uuid,
                id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
            },
            { autoCommit: true } // Ensure commit
        );

        res.status(201).json({ id: result.outBinds.id[0], ...req.body });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}

async function updateCountry(req, res) {
    let connection;
    try {
        const { country_co, description, path_image, telephone_co, user_id, slug, uuid } = req.body;
        connection = await oracledb.getConnection();

        const result = await connection.execute(
            `UPDATE COUNTRIES 
       SET COUNTRY_CO = :country_co, 
           DESCRIPTION = :description, 
           PATH_IMAGE = :path_image, 
           TELEPHONE_CO = :telephone_co, 
           USER_ID = :user_id, 
           SLUG = :slug, 
           UUID = :uuid,
           UPDATED_AT = sysdate
       WHERE ID = :id`,
            {
                country_co,
                description,
                path_image,
                telephone_co,
                user_id,
                slug,
                uuid,
                id: req.params.id
            },
            { autoCommit: true }
        );

        if (result.rowsAffected === 0) {
            return res.status(404).json({ error: "Country not found" });
        }

        res.json({ id: req.params.id, ...req.body });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}

async function deleteCountry(req, res) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `DELETE FROM COUNTRIES WHERE ID = :id`,
            [req.params.id],
            { autoCommit: true }
        );

        if (result.rowsAffected === 0) {
            return res.status(404).json({ error: "Country not found" });
        }

        res.json({ message: "Country deleted successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}

module.exports = {
    getAllCountries,
    getCountryById,
    createCountry,
    updateCountry,
    deleteCountry
};
