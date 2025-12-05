#!/usr/bin/env node

const { Client } = require('pg');
const fs = require('fs');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

async function main() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    console.log('✓ Conectado a PostgreSQL\n');

    // Deploy SP
    const sqlFile = 'C:/recodeGDL/RefactorX/Base/multas_reglamentos/database/generated/recaudadora_consescrit400.sql';
    const sql = fs.readFileSync(sqlFile, 'utf8');

    console.log('Desplegando SP recaudadora_consescrit400...');
    await client.query(sql);
    console.log('✓ SP desplegado exitosamente\n');

    // Get sample accounts
    console.log('=== Buscando cuentas con requerimientos ===');
    const accountsResult = await client.query(`
      SELECT cvecuenta, COUNT(*) as total
      FROM catastro_gdl.reqdiftransmision
      GROUP BY cvecuenta
      ORDER BY total DESC
      LIMIT 5
    `);

    if (accountsResult.rows.length === 0) {
      console.log('No se encontraron registros. Insertando datos de prueba...\n');

      // Insert test data
      const testData = [
        { cuenta: 100001, folio: 1, axo: 2024, total: 1400.00 },
        { cuenta: 100002, folio: 2, axo: 2024, total: 2100.00 },
        { cuenta: 100003, folio: 3, axo: 2023, total: 1800.00 },
      ];

      for (const data of testData) {
        try {
          await client.query(`
            INSERT INTO catastro_gdl.reqdiftransmision
            (cvereq, axoreq, folioreq, cvecuenta, total, vigencia, fecemi, feccap)
            VALUES
            (
              (SELECT COALESCE(MAX(cvereq), 0) + 1 FROM catastro_gdl.reqdiftransmision),
              $1, $2, $3, $4, 'V', CURRENT_DATE, CURRENT_DATE
            )
          `, [data.axo, data.folio, data.cuenta, data.total]);
          console.log(`  Insertado registro para cuenta ${data.cuenta}`);
        } catch (e) {
          console.log(`  Cuenta ${data.cuenta} ya existe o error: ${e.message}`);
        }
      }

      // Re-query accounts
      const newAccountsResult = await client.query(`
        SELECT cvecuenta, COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        GROUP BY cvecuenta
        ORDER BY total DESC
        LIMIT 5
      `);
      accountsResult.rows = newAccountsResult.rows;
    }

    console.log('\nCuentas disponibles:');
    accountsResult.rows.forEach(account => {
      console.log(`  Cuenta ${account.cvecuenta}: ${account.total} requerimientos`);
    });

    // Test examples
    console.log('\n=== EJEMPLOS DE PRUEBA ===\n');
    const testAccounts = accountsResult.rows.slice(0, 3);

    for (let i = 0; i < testAccounts.length; i++) {
      const account = testAccounts[i];
      console.log(`EJEMPLO ${i + 1}: Cuenta ${account.cvecuenta}`);

      const result = await client.query(
        'SELECT * FROM public.recaudadora_consescrit400($1)',
        [String(account.cvecuenta)]
      );

      if (result.rows.length === 0) {
        console.log('Sin registros encontrados\n');
      } else {
        console.log(`Registros encontrados: ${result.rows.length}`);
        console.log(JSON.stringify(result.rows[0], null, 2));
        console.log('');
      }
    }

    console.log('✓ Todas las pruebas completadas');

  } catch (error) {
    console.error('✗ Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();
