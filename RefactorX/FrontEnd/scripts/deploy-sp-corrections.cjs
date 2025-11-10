#!/usr/bin/env node

/**
 * Script para Desplegar Correcciones de SPs
 * Divide el archivo SQL en funciones individuales y las despliega una por una
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function splitSQLIntoFunctions(sql) {
  // Dividir por CREATE OR REPLACE FUNCTION
  const functions = [];
  const regex = /(-- ============================================================\s+-- SP: ([^\n]+)\s+-- Correcciones:[^\n]+\s+-- ============================================================\s+CREATE OR REPLACE FUNCTION[\s\S]+?)\n\n/g;

  let match;
  while ((match = regex.exec(sql)) !== null) {
    functions.push({
      name: match[2].trim(),
      sql: match[1].trim()
    });
  }

  return functions;
}

async function main() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    log('\n✅ Conectado a la base de datos: padron_licencias\n', 'green');

    const sqlPath = path.join(
      __dirname,
      '..',
      '..',
      'Base',
      'padron_licencias',
      'database',
      'deploy',
      'FIX_SP_TABLE_REFERENCES.sql'
    );

    if (!fs.existsSync(sqlPath)) {
      throw new Error('Archivo de corrección no encontrado');
    }

    const sql = fs.readFileSync(sqlPath, 'utf8');
    const functions = splitSQLIntoFunctions(sql);

    log(`📊 Total de SPs a corregir: ${functions.length}\n`, 'blue');

    let successCount = 0;
    let errorCount = 0;
    const errors = [];

    for (let i = 0; i < functions.length; i++) {
      const func = functions[i];

      try {
        await client.query(func.sql);
        successCount++;
        process.stdout.write(`${colors.green}.${colors.reset}`);

        if ((i + 1) % 50 === 0) {
          log(` ${i + 1}/${functions.length}`, 'blue');
        }
      } catch (err) {
        errorCount++;
        process.stdout.write(`${colors.red}X${colors.reset}`);
        errors.push({
          sp: func.name,
          error: err.message
        });

        if ((i + 1) % 50 === 0) {
          log(` ${i + 1}/${functions.length}`, 'blue');
        }
      }
    }

    log(`\n\n✅ Exitosos: ${successCount}`, 'green');
    log(`❌ Errores: ${errorCount}`, errorCount > 0 ? 'red' : 'green');

    if (errors.length > 0 && errors.length < 20) {
      log('\n⚠️  ERRORES ENCONTRADOS:', 'yellow');
      errors.forEach(err => {
        log(`   ${err.sp}: ${err.error.substring(0, 100)}...`, 'red');
      });
    }

    // Conteo final
    const countQuery = `
      SELECT COUNT(*) as total
      FROM information_schema.routines
      WHERE routine_schema = 'public'
        AND routine_type = 'FUNCTION';
    `;

    const result = await client.query(countQuery);
    log(`\n📊 Total de SPs en BD: ${result.rows[0].total}`, 'blue');
    log('');

  } catch (error) {
    log(`\n❌ Error fatal: ${error.message}`, 'red');
    console.error(error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  main()
    .then(() => {
      log('✨ Despliegue completado\n', 'green');
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { main };
