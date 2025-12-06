const { Client } = require('pg');

const config = {
    host: '192.168.6.146',
    port: 5432,
    database: 'mercados',
    user: 'refact',
    password: 'FF)-BQk2'
};

async function main() {
    const client = new Client(config);

    try {
        await client.connect();
        console.log('Conectado\n');

        // Ver estructura de ta_11_adeudo_local
        console.log('ESTRUCTURA DE publico.ta_11_adeudo_local:');
        console.log('='.repeat(60));

        const query = `
            SELECT
                column_name,
                data_type,
                character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'ta_11_adeudo_local'
            ORDER BY ordinal_position
        `;

        const result = await client.query(query);
        for (const row of result.rows) {
            let typeStr = row.data_type;
            if (row.character_maximum_length) {
                typeStr += `(${row.character_maximum_length})`;
            }
            console.log(`  ${row.column_name}: ${typeStr}`);
        }

        // Ver estructura de ta_11_cuo_locales
        console.log('\n\nESTRUCTURA DE publico.ta_11_cuo_locales:');
        console.log('='.repeat(60));

        const query2 = `
            SELECT
                column_name,
                data_type,
                character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'ta_11_cuo_locales'
            ORDER BY ordinal_position
        `;

        const result2 = await client.query(query2);
        for (const row of result2.rows) {
            let typeStr = row.data_type;
            if (row.character_maximum_length) {
                typeStr += `(${row.character_maximum_length})`;
            }
            console.log(`  ${row.column_name}: ${typeStr}`);
        }

    } catch (error) {
        console.error('ERROR:', error.message);
    } finally {
        await client.end();
    }
}

main();
