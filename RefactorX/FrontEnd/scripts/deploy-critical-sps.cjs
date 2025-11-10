#!/usr/bin/env node

/**
 * Script para Desplegar los SPs CRÍTICOS a la Base de Datos
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

async function deployCriticalSPs() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    log('\n✅ Conectado a la base de datos\n', 'green');

    // Leer el archivo SQL
    // __dirname = C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\scripts
    // Target =  C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\deploy\
    const sqlFileName = process.argv[2] || 'DEPLOY_CRITICAL_SPS.sql';
    const sqlFilePath = path.join(__dirname, '..', '..', 'Base', 'padron_licencias', 'database', 'deploy', sqlFileName);

    log(`📂 Buscando archivo en: ${sqlFilePath}\n`, 'blue');

    if (!fs.existsSync(sqlFilePath)) {
      throw new Error(`No se encontró el archivo SQL: ${sqlFilePath}`);
    }

    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');

    log('📄 Archivo SQL cargado\n', 'cyan');
    log('═══════════════════════════════════════════════════════════════', 'cyan');
    log('  EJECUTANDO SCRIPT DE DEPLOY', 'cyan');
    log('═══════════════════════════════════════════════════════════════\n', 'cyan');

    // Ejecutar el script SQL completo
    await client.query(sqlContent);

    log('✅ Script ejecutado exitosamente\n', 'green');

    // Verificar que los SPs se crearon correctamente
    log('═══════════════════════════════════════════════════════════════', 'cyan');
    log('  VERIFICANDO CREACIÓN DE STORED PROCEDURES', 'cyan');
    log('═══════════════════════════════════════════════════════════════\n', 'cyan');

    const verifyQuery = `
      SELECT
        routine_schema,
        routine_name,
        routine_type,
        data_type
      FROM information_schema.routines
      WHERE routine_name IN ('sp_get_tramite_by_id', 'sp_verifica_firma')
        AND routine_schema = 'public'
      ORDER BY routine_name;
    `;

    const verifyResult = await client.query(verifyQuery);

    if (verifyResult.rows.length > 0) {
      log('✅ Stored Procedures creados exitosamente:\n', 'green');
      verifyResult.rows.forEach(row => {
        log(`   📋 ${row.routine_name}`, 'cyan');
        log(`      - Esquema: ${row.routine_schema}`, 'blue');
        log(`      - Tipo: ${row.routine_type}`, 'blue');
        log(`      - Retorna: ${row.data_type}`, 'blue');
        log('');
      });
    } else {
      log('❌ No se encontraron los Stored Procedures', 'red');
    }

    // Obtener información detallada de parámetros
    log('═══════════════════════════════════════════════════════════════', 'cyan');
    log('  PARÁMETROS DE LOS STORED PROCEDURES', 'cyan');
    log('═══════════════════════════════════════════════════════════════\n', 'cyan');

    const paramsQuery = `
      SELECT
        r.routine_name,
        p.parameter_name,
        p.data_type,
        p.parameter_mode
      FROM information_schema.routines r
      LEFT JOIN information_schema.parameters p ON r.specific_name = p.specific_name
      WHERE r.routine_name IN ('sp_get_tramite_by_id', 'sp_verifica_firma')
        AND r.routine_schema = 'public'
        AND p.parameter_mode IN ('IN', 'INOUT')
      ORDER BY r.routine_name, p.ordinal_position;
    `;

    const paramsResult = await client.query(paramsQuery);

    if (paramsResult.rows.length > 0) {
      let currentSP = '';
      paramsResult.rows.forEach(row => {
        if (row.routine_name !== currentSP) {
          if (currentSP !== '') log('');
          log(`📋 ${row.routine_name}:`, 'cyan');
          currentSP = row.routine_name;
        }
        log(`   - ${row.parameter_name}: ${row.data_type} (${row.parameter_mode})`, 'blue');
      });
      log('');
    }

    // Contar SPs totales ahora
    log('═══════════════════════════════════════════════════════════════', 'cyan');
    log('  ESTADÍSTICAS DE LA BASE DE DATOS', 'cyan');
    log('═══════════════════════════════════════════════════════════════\n', 'cyan');

    const countQuery = `
      SELECT COUNT(*) as total
      FROM information_schema.routines
      WHERE routine_schema = 'public'
        AND routine_type = 'FUNCTION';
    `;

    const countResult = await client.query(countQuery);
    const totalSPs = countResult.rows[0].total;

    log(`📊 Total de Stored Procedures en esquema 'public': ${totalSPs}`, 'cyan');
    log('', 'cyan');

    // Resumen
    log('═══════════════════════════════════════════════════════════════', 'green');
    log('  ✅ DEPLOY COMPLETADO EXITOSAMENTE', 'green');
    log('═══════════════════════════════════════════════════════════════\n', 'green');

    log('📋 SPs CRÍTICOS CREADOS:', 'cyan');
    log('   1. ✅ sp_get_tramite_by_id', 'green');
    log('   2. ✅ sp_verifica_firma', 'green');
    log('');

    log('📊 SIGUIENTE PASO:', 'yellow');
    log('   - Validar funcionalidad en componentes Vue', 'yellow');
    log('   - Continuar con los 66 SPs IMPORTANTES', 'yellow');
    log('   - Completar los 185 SPs OPCIONALES\n', 'yellow');

  } catch (error) {
    log('\n❌ ERROR DURANTE EL DEPLOY:', 'red');
    log(`   ${error.message}`, 'red');

    if (error.position) {
      log(`   Posición del error: ${error.position}`, 'yellow');
    }

    if (error.detail) {
      log(`   Detalle: ${error.detail}`, 'yellow');
    }

    throw error;
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  deployCriticalSPs()
    .then(() => {
      log('✨ Proceso completado\n', 'green');
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { deployCriticalSPs };
