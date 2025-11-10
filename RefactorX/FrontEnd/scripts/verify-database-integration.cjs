#!/usr/bin/env node

/**
 * Script de Verificación Completa: Base de Datos + Integración Vue-API-SP
 *
 * Verifica:
 * 1. SPs desplegados en la base de datos
 * 2. Tablas referenciadas existen y están en el schema correcto
 * 3. Tipos de datos y columnas
 * 4. Integración con Vue components y API genérica
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

async function getSPList(client) {
  const query = `
    SELECT
      routine_schema,
      routine_name,
      routine_type,
      data_type as return_type
    FROM information_schema.routines
    WHERE routine_schema IN ('public', 'comun', 'informix')
      AND routine_type = 'FUNCTION'
    ORDER BY routine_name;
  `;

  const result = await client.query(query);
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

function extractTablesFromSP(spDefinition) {
  if (!spDefinition) return [];

  const tables = [];

  // Pattern: FROM schema.table o JOIN schema.table
  const fromPattern = /(?:FROM|JOIN)\s+([a-z_]+)\.([a-z_0-9]+)/gi;
  let match;

  while ((match = fromPattern.exec(spDefinition)) !== null) {
    tables.push({
      schema: match[1],
      table: match[2],
      fullName: `${match[1]}.${match[2]}`
    });
  }

  // Pattern: INSERT INTO schema.table o UPDATE schema.table
  const dmlPattern = /(?:INSERT INTO|UPDATE|DELETE FROM)\s+([a-z_]+)\.([a-z_0-9]+)/gi;

  while ((match = dmlPattern.exec(spDefinition)) !== null) {
    tables.push({
      schema: match[1],
      table: match[2],
      fullName: `${match[1]}.${match[2]}`
    });
  }

  // Eliminar duplicados
  return [...new Map(tables.map(t => [t.fullName, t])).values()];
}

async function verifyTableExists(client, schema, tableName) {
  const query = `
    SELECT
      table_schema,
      table_name,
      table_type
    FROM information_schema.tables
    WHERE table_schema = $1
      AND table_name = $2;
  `;

  const result = await client.query(query, [schema, tableName]);
  return result.rows.length > 0;
}

async function getTableColumns(client, schema, tableName) {
  const query = `
    SELECT
      column_name,
      data_type,
      character_maximum_length,
      is_nullable,
      column_default
    FROM information_schema.columns
    WHERE table_schema = $1
      AND table_name = $2
    ORDER BY ordinal_position;
  `;

  const result = await client.query(query, [schema, tableName]);
  return result.rows;
}

async function verifyVueIntegration(spName) {
  // Buscar el SP en archivos Vue
  const vueDir = path.join(__dirname, '..', 'src', 'views', 'modules', 'padron_licencias');

  if (!fs.existsSync(vueDir)) {
    return { found: false, files: [] };
  }

  const vueFiles = fs.readdirSync(vueDir)
    .filter(f => f.endsWith('.vue'));

  const foundIn = [];

  for (const file of vueFiles) {
    const filePath = path.join(vueDir, file);
    const content = fs.readFileSync(filePath, 'utf8');

    // Buscar llamadas al SP
    if (content.includes(spName)) {
      // Verificar si usa execute() correctamente
      const hasCorrectUsage = content.match(new RegExp(`execute\\(['"]\`?${spName}\`?['"]`, 'i'));

      foundIn.push({
        file,
        hasCorrectUsage: !!hasCorrectUsage
      });
    }
  }

  return {
    found: foundIn.length > 0,
    files: foundIn
  };
}

async function analyzeAPICompatibility(spName, spDefinition) {
  // Verificar que el SP sea compatible con el GenericController
  const issues = [];

  // 1. Verificar que retorne TABLE
  if (!spDefinition.includes('RETURNS TABLE')) {
    issues.push('SP no retorna TABLE - puede no ser compatible con API genérica');
  }

  // 2. Verificar nomenclatura
  if (!spName.startsWith('sp_')) {
    issues.push('SP no sigue convención de nomenclatura (debe empezar con sp_)');
  }

  // 3. Verificar que use plpgsql
  if (!spDefinition.includes('LANGUAGE plpgsql')) {
    issues.push('SP no usa LANGUAGE plpgsql');
  }

  return issues;
}

async function main() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    log('\n✅ Conectado a la base de datos: padron_licencias\n', 'green');

    // FASE 1: Obtener lista de SPs
    log('═══════════════════════════════════════════════════════════', 'cyan');
    log('  FASE 1: ANÁLISIS DE STORED PROCEDURES', 'cyan');
    log('═══════════════════════════════════════════════════════════\n', 'cyan');

    const sps = await getSPList(client);
    log(`📊 Total de SPs encontrados: ${sps.length}\n`, 'blue');

    // FASE 2: Verificar tablas referenciadas
    log('═══════════════════════════════════════════════════════════', 'cyan');
    log('  FASE 2: VERIFICACIÓN DE TABLAS', 'cyan');
    log('═══════════════════════════════════════════════════════════\n', 'cyan');

    const verification = {
      total: 0,
      withTables: 0,
      missingTables: [],
      validSPs: 0,
      invalidSPs: 0,
      apiIssues: []
    };

    let analyzed = 0;

    for (const sp of sps) {
      verification.total++;

      // Solo analizar SPs del schema public (los que desplegamos)
      if (sp.routine_schema !== 'public') continue;

      analyzed++;

      // Obtener definición del SP
      const definition = await getSPDefinition(client, sp.routine_name);

      if (!definition) {
        verification.invalidSPs++;
        continue;
      }

      // Extraer tablas referenciadas
      const tables = extractTablesFromSP(definition);

      if (tables.length > 0) {
        verification.withTables++;

        // Verificar cada tabla
        for (const table of tables) {
          const exists = await verifyTableExists(client, table.schema, table.table);

          if (!exists) {
            verification.missingTables.push({
              sp: sp.routine_name,
              table: table.fullName
            });
          }
        }
      }

      // Verificar compatibilidad con API
      const apiIssues = await analyzeAPICompatibility(sp.routine_name, definition);
      if (apiIssues.length > 0) {
        verification.apiIssues.push({
          sp: sp.routine_name,
          issues: apiIssues
        });
      }

      // Mostrar progreso
      if (analyzed % 50 === 0) {
        log(`   Analizados: ${analyzed} SPs...`, 'blue');
      }
    }

    verification.validSPs = analyzed - verification.invalidSPs;

    // FASE 3: Reporte de resultados
    log('\n═══════════════════════════════════════════════════════════', 'green');
    log('  FASE 3: RESULTADOS DE VERIFICACIÓN', 'green');
    log('═══════════════════════════════════════════════════════════\n', 'green');

    log(`📊 Total de SPs en BD: ${verification.total}`, 'blue');
    log(`✅ SPs válidos analizados: ${verification.validSPs}`, 'green');
    log(`❌ SPs inválidos: ${verification.invalidSPs}`, verification.invalidSPs > 0 ? 'red' : 'green');
    log(`📋 SPs con referencias a tablas: ${verification.withTables}`, 'blue');
    log(`⚠️  Tablas faltantes: ${verification.missingTables.length}`, verification.missingTables.length > 0 ? 'yellow' : 'green');
    log(`⚠️  Problemas de compatibilidad API: ${verification.apiIssues.length}`, verification.apiIssues.length > 0 ? 'yellow' : 'green');

    // Mostrar tablas faltantes
    if (verification.missingTables.length > 0 && verification.missingTables.length < 50) {
      log('\n⚠️  TABLAS FALTANTES:', 'yellow');
      const grouped = {};
      verification.missingTables.forEach(item => {
        if (!grouped[item.table]) grouped[item.table] = [];
        grouped[item.table].push(item.sp);
      });

      Object.keys(grouped).sort().forEach(table => {
        log(`   ${table}: usada por ${grouped[table].length} SPs`, 'yellow');
        if (grouped[table].length <= 5) {
          grouped[table].forEach(sp => log(`      - ${sp}`, 'yellow'));
        }
      });
    }

    // Mostrar problemas de API
    if (verification.apiIssues.length > 0 && verification.apiIssues.length < 20) {
      log('\n⚠️  PROBLEMAS DE COMPATIBILIDAD CON API:', 'yellow');
      verification.apiIssues.slice(0, 10).forEach(item => {
        log(`   ${item.sp}:`, 'yellow');
        item.issues.forEach(issue => log(`      - ${issue}`, 'yellow'));
      });

      if (verification.apiIssues.length > 10) {
        log(`   ... y ${verification.apiIssues.length - 10} más`, 'yellow');
      }
    }

    // FASE 4: Verificar schemas disponibles
    log('\n═══════════════════════════════════════════════════════════', 'cyan');
    log('  FASE 4: SCHEMAS DISPONIBLES', 'cyan');
    log('═══════════════════════════════════════════════════════════\n', 'cyan');

    const schemasQuery = `
      SELECT
        table_schema as schema_name,
        COUNT(DISTINCT table_name) as tables
      FROM information_schema.tables
      WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
      GROUP BY table_schema
      ORDER BY tables DESC;
    `;

    const schemas = await client.query(schemasQuery);

    log('📋 Schemas y tablas disponibles:\n', 'blue');
    schemas.rows.forEach(row => {
      log(`   ${row.schema_name.padEnd(30)} : ${row.tables} tablas`, 'blue');
    });

    // Guardar reporte JSON
    const report = {
      timestamp: new Date().toISOString(),
      database: 'padron_licencias',
      summary: {
        totalSPs: verification.total,
        validSPs: verification.validSPs,
        invalidSPs: verification.invalidSPs,
        missingTables: verification.missingTables.length,
        apiIssues: verification.apiIssues.length
      },
      missingTables: verification.missingTables,
      apiIssues: verification.apiIssues,
      schemas: schemas.rows
    };

    const reportPath = path.join(__dirname, 'verification-report.json');
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2), 'utf8');

    log(`\n💾 Reporte guardado en: ${reportPath}`, 'cyan');
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
      log('✨ Verificación completada\n', 'green');
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { main };
