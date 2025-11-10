#!/usr/bin/env node

/**
 * Script para Desplegar SPs EXISTENTES desde Base/padron_licencias/database
 * Lee los archivos SQL ya creados y los despliega a PostgreSQL
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

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
  magenta: '\x1b[35m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function deploySQLFile(client, filePath, fileName) {
  try {
    const sqlContent = fs.readFileSync(filePath, 'utf8');

    // Ejecutar el SQL
    await client.query(sqlContent);

    return { success: true, file: fileName };
  } catch (error) {
    return { success: false, file: fileName, error: error.message };
  }
}

async function deployMainFiles(client, baseDir) {
  log('\n═══════════════════════════════════════════════════════════', 'cyan');
  log('  FASE 1: DESPLEGANDO ARCHIVOS PRINCIPALES', 'cyan');
  log('═══════════════════════════════════════════════════════════\n', 'cyan');

  const mainFiles = [
    '01_catalogs.sql',
    '02_crud.sql',
    '03_reports.sql'
  ];

  const results = [];

  for (const file of mainFiles) {
    const filePath = path.join(baseDir, file);

    if (!fs.existsSync(filePath)) {
      log(`⚠️  ${file} no encontrado`, 'yellow');
      continue;
    }

    log(`🔄 Desplegando ${file}...`, 'cyan');

    const result = await deploySQLFile(client, filePath, file);

    if (result.success) {
      log(`✅ ${file} desplegado exitosamente`, 'green');
      results.push(result);
    } else {
      log(`❌ Error en ${file}: ${result.error}`, 'red');
      results.push(result);
    }
  }

  return results;
}

async function deployComponentSPs(client, baseDir) {
  log('\n═══════════════════════════════════════════════════════════', 'cyan');
  log('  FASE 2: DESPLEGANDO SPs POR COMPONENTE', 'cyan');
  log('═══════════════════════════════════════════════════════════\n', 'cyan');

  // Obtener todos los archivos SQL (excluyendo los principales y _all_procedures)
  const files = fs.readdirSync(baseDir)
    .filter(f => f.endsWith('.sql'))
    .filter(f => !f.startsWith('01_') && !f.startsWith('02_') && !f.startsWith('03_'))
    .filter(f => !f.includes('_all_procedures'))
    .sort();

  log(`📊 Total de archivos SP: ${files.length}\n`, 'blue');

  const results = [];
  let successCount = 0;
  let errorCount = 0;

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const filePath = path.join(baseDir, file);

    if (i % 50 === 0) {
      log(`\n📦 Procesando archivos ${i + 1}-${Math.min(i + 50, files.length)} de ${files.length}...`, 'cyan');
    }

    const result = await deploySQLFile(client, filePath, file);

    if (result.success) {
      successCount++;
      process.stdout.write(`${colors.green}.${colors.reset}`);
    } else {
      errorCount++;
      process.stdout.write(`${colors.red}X${colors.reset}`);
      results.push(result);
    }

    // Cada 50 archivos, mostrar progreso
    if ((i + 1) % 50 === 0 || i === files.length - 1) {
      const pct = (((i + 1) / files.length) * 100).toFixed(1);
      log(`  ${pct}% (${i + 1}/${files.length})`, 'blue');
    }
  }

  log(`\n\n✅ Exitosos: ${successCount}`, 'green');
  log(`❌ Errores: ${errorCount}`, errorCount > 0 ? 'red' : 'green');

  return { successCount, errorCount, errors: results };
}

async function getSpCount(client) {
  const query = `
    SELECT COUNT(*) as total
    FROM information_schema.routines
    WHERE routine_schema = 'public'
      AND routine_type = 'FUNCTION';
  `;

  const result = await client.query(query);
  return result.rows[0].total;
}

async function main() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    log('\n✅ Conectado a la base de datos: padron_licencias\n', 'green');

    const initialCount = await getSpCount(client);
    log(`📊 SPs iniciales en BD: ${initialCount}`, 'blue');

    const baseDir = path.join(__dirname, '..', '..', 'Base', 'padron_licencias', 'database', 'database');

    if (!fs.existsSync(baseDir)) {
      throw new Error(`Directorio no encontrado: ${baseDir}`);
    }

    log(`📂 Directorio base: ${baseDir}\n`, 'blue');

    // Fase 1: Archivos principales
    const mainResults = await deployMainFiles(client, baseDir);

    // Fase 2: SPs individuales
    const componentResults = await deployComponentSPs(client, baseDir);

    // Conteo final
    const finalCount = await getSpCount(client);
    const added = finalCount - initialCount;

    log('\n═══════════════════════════════════════════════════════════', 'green');
    log('  RESUMEN FINAL', 'green');
    log('═══════════════════════════════════════════════════════════\n', 'green');

    log(`📊 SPs iniciales: ${initialCount}`, 'blue');
    log(`📊 SPs finales: ${finalCount}`, 'green');
    log(`➕ SPs agregados: ${added}`, 'cyan');
    log(`✅ Archivos exitosos: ${componentResults.successCount}`, 'green');
    log(`❌ Archivos con error: ${componentResults.errorCount}`, componentResults.errorCount > 0 ? 'red' : 'green');

    if (componentResults.errors.length > 0 && componentResults.errorCount < 20) {
      log('\n⚠️  ERRORES ENCONTRADOS:', 'yellow');
      componentResults.errors.forEach(err => {
        log(`   ${err.file}: ${err.error.substring(0, 100)}...`, 'red');
      });
    }

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
      log('✨ Proceso completado\n', 'green');
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { main };
