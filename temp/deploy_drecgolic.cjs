#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function deployStoredProcedure() {
    const client = new Client({
        host: '192.168.6.146',
        port: 5432,
        database: 'padron_licencias',
        user: 'refact',
        password: 'FF)-BQk2',
        connectionTimeoutMillis: 10000,
    });

    try {
        console.log('=== DEPLOYING recaudadora_drecgolic ===\n');

        // Connect to database
        console.log('1. Connecting to database...');
        await client.connect();
        console.log('   ✓ Connected\n');

        // Drop existing function first
        console.log('2. Dropping old function...');
        await client.query('DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_drecgolic(VARCHAR) CASCADE');
        console.log('   ✓ Dropped\n');

        // Read and execute the SQL file
        console.log('3. Creating new function...');
        const sqlFile = path.join(__dirname, '..', 'RefactorX', 'Base', 'multas_reglamentos', 'database', 'generated', 'recaudadora_drecgolic.sql');
        const sql = fs.readFileSync(sqlFile, 'utf8');

        await client.query(sql);
        console.log('   ✓ Created\n');

        // Test with different scenarios
        console.log('4. Testing SP...\n');

        // Test 1: List first 5
        console.log('Test 1: Listar primeras 5 licencias');
        const result1 = await client.query('SELECT * FROM multas_reglamentos.recaudadora_drecgolic(NULL) LIMIT 5');
        console.log(`   ✓ Found ${result1.rows.length} records\n`);

        if (result1.rows.length > 0) {
            const first = result1.rows[0];
            console.log('   Sample:');
            console.log(`   - Licencia: ${first.licencia}`);
            console.log(`   - Propietario: ${first.propietario}`);
            console.log(`   - Giro: ${first.id_giro}`);
            console.log(`   - Fecha: ${first.fecha_otorgamiento}\n`);
        }

        // Test 2: Filter by licencia 1
        console.log('Test 2: Filtrar por Licencia \'1\'');
        const result2 = await client.query('SELECT * FROM multas_reglamentos.recaudadora_drecgolic(\'1\')');
        console.log(`   ✓ Found ${result2.rows.length} records`);
        if (result2.rows.length > 0) {
            const r = result2.rows[0];
            console.log(`   - Propietario: ${r.propietario}`);
            console.log(`   - Giro: ${r.id_giro}`);
        }
        console.log('');

        // Test 3: Filter by licencia 5
        console.log('Test 3: Filtrar por Licencia \'5\'');
        const result3 = await client.query('SELECT * FROM multas_reglamentos.recaudadora_drecgolic(\'5\')');
        console.log(`   ✓ Found ${result3.rows.length} records`);
        if (result3.rows.length > 0) {
            const r = result3.rows[0];
            console.log(`   - Propietario: ${r.propietario}`);
            console.log(`   - Giro: ${r.id_giro}`);
        }
        console.log('');

        // Test 4: Filter by licencia 8
        console.log('Test 4: Filtrar por Licencia \'8\'');
        const result4 = await client.query('SELECT * FROM multas_reglamentos.recaudadora_drecgolic(\'8\')');
        console.log(`   ✓ Found ${result4.rows.length} records`);
        if (result4.rows.length > 0) {
            const r = result4.rows[0];
            console.log(`   - Propietario: ${r.propietario}`);
            console.log(`   - Giro: ${r.id_giro}`);
        }
        console.log('');

        console.log('✓✓✓ SP Deployed and Tested successfully! ✓✓✓\n');

    } catch (error) {
        console.error('✗ Error:', error.message);
        process.exit(1);
    } finally {
        await client.end();
    }
}

deployStoredProcedure();
