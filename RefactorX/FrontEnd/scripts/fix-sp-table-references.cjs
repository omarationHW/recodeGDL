#!/usr/bin/env node

/**
 * Script para Corregir Referencias de Tablas en SPs
 *
 * Analiza las tablas faltantes y las busca en los schemas correctos
 * Genera scripts SQL para corregir los SPs
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
  magenta: '\x1b[35m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function findTableInSchemas(client, tableName) {
  // Buscar tabla en todos los schemas
  const query = `
    SELECT
      table_schema,
      table_name,
      table_type
    FROM information_schema.tables
    WHERE table_name = $1
      AND table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY
      CASE table_schema
        WHEN 'public' THEN 1
        WHEN 'comun' THEN 2
        WHEN 'informix' THEN 3
        ELSE 4
      END;
  `;

  const result = await client.query(query, [tableName]);
  return result.rows;
}

async function getSPDefinition(client, spName) {
  const query = `
    SELECT
      pg_get_functiondef(p.oid) as definition
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname = $1
      AND n.nspname = 'public';
  `;

  const result = await client.query(query, [spName]);
  return result.rows[0]?.definition || null;
}

async function main() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    log('\n✅ Conectado a la base de datos: padron_licencias\n', 'green');

    // Leer reporte de verificación
    const reportPath = path.join(__dirname, 'verification-report.json');

    if (!fs.existsSync(reportPath)) {
      throw new Error('Primero ejecuta verify-database-integration.cjs para generar el reporte');
    }

    const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));

    log('═══════════════════════════════════════════════════════════', 'cyan');
    log('  ANÁLISIS DE TABLAS FALTANTES', 'cyan');
    log('═══════════════════════════════════════════════════════════\n', 'cyan');

    log(`📊 Total de tablas faltantes: ${report.missingTables.length}\n`, 'blue');

    // Agrupar por tabla
    const tableGroups = {};
    report.missingTables.forEach(item => {
      const tableName = item.table.split('.')[1]; // extraer solo el nombre sin schema
      if (!tableGroups[tableName]) {
        tableGroups[tableName] = {
          requested: item.table,
          sps: []
        };
      }
      tableGroups[tableName].sps.push(item.sp);
    });

    log(`📋 Tablas únicas faltantes: ${Object.keys(tableGroups).length}\n`, 'blue');

    // Buscar cada tabla en todos los schemas
    const corrections = [];
    let found = 0;
    let notFound = 0;

    for (const [tableName, info] of Object.entries(tableGroups)) {
      const locations = await findTableInSchemas(client, tableName);

      if (locations.length > 0) {
        found++;
        const actualLocation = `${locations[0].table_schema}.${locations[0].table_name}`;

        log(`✅ ${tableName.padEnd(40)} → ${actualLocation}`, 'green');

        corrections.push({
          tableName,
          requestedLocation: info.requested,
          actualLocation,
          affectedSPs: info.sps,
          schema: locations[0].table_schema
        });
      } else {
        notFound++;
        log(`❌ ${tableName.padEnd(40)} → NO ENCONTRADA`, 'red');
      }
    }

    log(`\n✅ Encontradas: ${found}`, 'green');
    log(`❌ No encontradas: ${notFound}`, notFound > 0 ? 'red' : 'green');

    // Generar script de corrección SQL
    log('\n═══════════════════════════════════════════════════════════', 'cyan');
    log('  GENERANDO SCRIPT DE CORRECCIÓN', 'cyan');
    log('═══════════════════════════════════════════════════════════\n', 'cyan');

    let sqlCorrections = `-- ============================================================
-- SCRIPT DE CORRECCIÓN DE REFERENCIAS DE TABLAS EN SPs
-- Base de datos: padron_licencias
-- Fecha: ${new Date().toISOString().split('T')[0]}
-- ============================================================
--
-- Este script corrige ${corrections.length} tablas mal referenciadas
-- que afectan a ${corrections.reduce((sum, c) => sum + c.affectedSPs.length, 0)} SPs
--
-- ============================================================

`;

    const spUpdates = new Map();

    // Agrupar correcciones por SP
    for (const correction of corrections) {
      for (const spName of correction.affectedSPs) {
        if (!spUpdates.has(spName)) {
          spUpdates.set(spName, []);
        }
        spUpdates.get(spName).push(correction);
      }
    }

    log(`📝 Generando correcciones para ${spUpdates.size} SPs...`, 'blue');

    let spsCorrected = 0;

    for (const [spName, corrections] of spUpdates) {
      const definition = await getSPDefinition(client, spName);

      if (!definition) {
        log(`   ⚠️  ${spName}: Definición no encontrada`, 'yellow');
        continue;
      }

      let correctedDefinition = definition;
      let changed = false;

      // Aplicar todas las correcciones
      for (const correction of corrections) {
        const wrongRef = correction.requestedLocation;
        const correctRef = correction.actualLocation;

        if (correctedDefinition.includes(wrongRef)) {
          correctedDefinition = correctedDefinition.replace(
            new RegExp(wrongRef.replace('.', '\\.'), 'g'),
            correctRef
          );
          changed = true;
        }
      }

      if (changed) {
        spsCorrected++;
        sqlCorrections += `\n-- ============================================================\n`;
        sqlCorrections += `-- SP: ${spName}\n`;
        sqlCorrections += `-- Correcciones: ${corrections.map(c => `${c.requestedLocation} → ${c.actualLocation}`).join(', ')}\n`;
        sqlCorrections += `-- ============================================================\n\n`;
        sqlCorrections += correctedDefinition + '\n\n';
      }
    }

    // Guardar script de corrección
    const correctionsPath = path.join(
      __dirname,
      '..',
      '..',
      'Base',
      'padron_licencias',
      'database',
      'deploy',
      'FIX_SP_TABLE_REFERENCES.sql'
    );

    fs.writeFileSync(correctionsPath, sqlCorrections, 'utf8');

    log(`\n✅ Script de corrección generado: FIX_SP_TABLE_REFERENCES.sql`, 'green');
    log(`📊 SPs a corregir: ${spsCorrected}`, 'blue');

    // Guardar reporte de correcciones
    const correctionsReport = {
      timestamp: new Date().toISOString(),
      database: 'padron_licencias',
      summary: {
        tablesAnalyzed: Object.keys(tableGroups).length,
        tablesFound: found,
        tablesNotFound: notFound,
        spsToCorrect: spsCorrected,
        totalCorrections: corrections.length
      },
      corrections,
      notFoundTables: Object.keys(tableGroups).filter(
        tableName => !corrections.find(c => c.tableName === tableName)
      )
    };

    const correctionsReportPath = path.join(__dirname, 'corrections-report.json');
    fs.writeFileSync(correctionsReportPath, JSON.stringify(correctionsReport, null, 2), 'utf8');

    log(`💾 Reporte de correcciones guardado: corrections-report.json`, 'cyan');

    // Mostrar tablas no encontradas
    if (correctionsReport.notFoundTables.length > 0) {
      log(`\n⚠️  TABLAS NO ENCONTRADAS (${correctionsReport.notFoundTables.length}):`, 'yellow');
      correctionsReport.notFoundTables.slice(0, 20).forEach(table => {
        log(`   - ${table}`, 'yellow');
      });
      if (correctionsReport.notFoundTables.length > 20) {
        log(`   ... y ${correctionsReport.notFoundTables.length - 20} más`, 'yellow');
      }
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
      log('✨ Análisis completado\n', 'green');
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { main };
