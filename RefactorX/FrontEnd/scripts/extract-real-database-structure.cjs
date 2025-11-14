#!/usr/bin/env node

/**
 * Script para extraer la estructura REAL de la base de datos PostgreSQL
 * Genera un reporte JSON con la estructura exacta de todas las tablas
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Configuración de conexión
const config = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2'
};

async function extractDatabaseStructure() {
  const client = new Client(config);

  try {
    console.log('🔌 Conectando a PostgreSQL...');
    await client.connect();
    console.log('✅ Conectado exitosamente\n');

    const report = {
      timestamp: new Date().toISOString(),
      database: config.database,
      schemas: {}
    };

    // 1. Obtener todos los schemas
    console.log('📊 Obteniendo schemas...');
    const schemasResult = await client.query(`
      SELECT schema_name
      FROM information_schema.schemata
      WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast', 'pg_temp_1', 'pg_toast_temp_1')
      ORDER BY schema_name
    `);

    const schemas = schemasResult.rows.map(r => r.schema_name);
    console.log(`   Schemas encontrados: ${schemas.length}`);
    console.log(`   ${schemas.join(', ')}\n`);

    // 2. Para cada schema, obtener tablas
    for (const schema of schemas) {
      console.log(`\n📁 Procesando schema: ${schema}`);
      report.schemas[schema] = {
        tables: {},
        table_count: 0
      };

      // Obtener tablas del schema
      const tablesResult = await client.query(`
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = $1
          AND table_type = 'BASE TABLE'
        ORDER BY table_name
      `, [schema]);

      const tables = tablesResult.rows.map(r => r.table_name);
      report.schemas[schema].table_count = tables.length;
      console.log(`   Tablas encontradas: ${tables.length}`);

      // Para schemas con pocas tablas, obtener estructura completa
      // Para schemas grandes, solo obtener las primeras 50
      const tablesToAnalyze = schema === 'public' || schema === 'comun'
        ? tables.slice(0, 50)
        : tables.slice(0, 20);

      console.log(`   Analizando ${tablesToAnalyze.length} tablas...`);

      for (const table of tablesToAnalyze) {
        // Obtener columnas de la tabla
        const columnsResult = await client.query(`
          SELECT
            column_name,
            data_type,
            character_maximum_length,
            numeric_precision,
            numeric_scale,
            is_nullable,
            column_default
          FROM information_schema.columns
          WHERE table_schema = $1 AND table_name = $2
          ORDER BY ordinal_position
        `, [schema, table]);

        // Obtener constraints (PK, FK, UK)
        const constraintsResult = await client.query(`
          SELECT
            tc.constraint_name,
            tc.constraint_type,
            kcu.column_name,
            ccu.table_schema AS foreign_table_schema,
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name
          FROM information_schema.table_constraints AS tc
          LEFT JOIN information_schema.key_column_usage AS kcu
            ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
          LEFT JOIN information_schema.constraint_column_usage AS ccu
            ON ccu.constraint_name = tc.constraint_name
            AND ccu.table_schema = tc.table_schema
          WHERE tc.table_schema = $1 AND tc.table_name = $2
        `, [schema, table]);

        // Obtener índices
        const indexesResult = await client.query(`
          SELECT
            indexname,
            indexdef
          FROM pg_indexes
          WHERE schemaname = $1 AND tablename = $2
        `, [schema, table]);

        // Obtener tamaño de la tabla
        const sizeResult = await client.query(`
          SELECT pg_size_pretty(pg_total_relation_size($1)) as size
        `, [`${schema}.${table}`]);

        report.schemas[schema].tables[table] = {
          columns: columnsResult.rows,
          constraints: constraintsResult.rows,
          indexes: indexesResult.rows,
          size: sizeResult.rows[0]?.size || 'N/A'
        };

        process.stdout.write('.');
      }

      console.log(` ✓`);
    }

    // 3. Obtener lista completa de Stored Procedures
    console.log('\n\n🔧 Obteniendo Stored Procedures...');
    const spsResult = await client.query(`
      SELECT
        routine_schema,
        routine_name,
        routine_type,
        data_type as return_type
      FROM information_schema.routines
      WHERE routine_schema NOT IN ('information_schema', 'pg_catalog')
      ORDER BY routine_schema, routine_name
    `);

    report.stored_procedures = {
      total: spsResult.rows.length,
      by_schema: {}
    };

    spsResult.rows.forEach(sp => {
      if (!report.stored_procedures.by_schema[sp.routine_schema]) {
        report.stored_procedures.by_schema[sp.routine_schema] = [];
      }
      report.stored_procedures.by_schema[sp.routine_schema].push({
        name: sp.routine_name,
        type: sp.routine_type,
        return_type: sp.return_type
      });
    });

    console.log(`   Total SPs: ${report.stored_procedures.total}`);
    Object.keys(report.stored_procedures.by_schema).forEach(schema => {
      console.log(`   ${schema}: ${report.stored_procedures.by_schema[schema].length} SPs`);
    });

    // 4. Generar resumen
    console.log('\n\n📊 RESUMEN:');
    console.log('═══════════════════════════════════════════════════');
    console.log(`Base de Datos: ${config.database}`);
    console.log(`Schemas: ${Object.keys(report.schemas).length}`);

    let totalTables = 0;
    Object.keys(report.schemas).forEach(schema => {
      const count = report.schemas[schema].table_count;
      totalTables += count;
      console.log(`  - ${schema}: ${count} tablas`);
    });

    console.log(`\nTablas Totales: ${totalTables}`);
    console.log(`Stored Procedures: ${report.stored_procedures.total}`);
    console.log('═══════════════════════════════════════════════════\n');

    // 5. Guardar reporte
    const outputPath = path.join(__dirname, 'database-structure-real.json');
    fs.writeFileSync(outputPath, JSON.stringify(report, null, 2));
    console.log(`✅ Reporte guardado en: ${outputPath}`);

    // 6. Generar resumen en Markdown
    const mdPath = path.join(__dirname, '../../ESTRUCTURA_BD_REAL.md');
    let markdown = `# ESTRUCTURA REAL DE LA BASE DE DATOS\n\n`;
    markdown += `**Generado:** ${new Date().toLocaleString()}\n`;
    markdown += `**Base de Datos:** ${config.database}\n`;
    markdown += `**Servidor:** ${config.host}:${config.port}\n\n`;
    markdown += `---\n\n`;
    markdown += `## RESUMEN\n\n`;
    markdown += `- **Total de Schemas:** ${Object.keys(report.schemas).length}\n`;
    markdown += `- **Total de Tablas:** ${totalTables}\n`;
    markdown += `- **Total de SPs:** ${report.stored_procedures.total}\n\n`;
    markdown += `---\n\n`;
    markdown += `## SCHEMAS Y TABLAS\n\n`;

    Object.keys(report.schemas).forEach(schema => {
      markdown += `### Schema: \`${schema}\`\n\n`;
      markdown += `**Total de tablas:** ${report.schemas[schema].table_count}\n\n`;

      const tables = Object.keys(report.schemas[schema].tables);
      if (tables.length > 0) {
        markdown += `**Tablas analizadas (muestra):**\n\n`;
        markdown += `| Tabla | Columnas | Tamaño | PKs | FKs | Índices |\n`;
        markdown += `|-------|----------|--------|-----|-----|----------|\n`;

        tables.forEach(table => {
          const data = report.schemas[schema].tables[table];
          const pks = data.constraints.filter(c => c.constraint_type === 'PRIMARY KEY').length;
          const fks = data.constraints.filter(c => c.constraint_type === 'FOREIGN KEY').length;

          markdown += `| ${table} | ${data.columns.length} | ${data.size} | ${pks} | ${fks} | ${data.indexes.length} |\n`;
        });

        markdown += `\n`;
      }

      markdown += `---\n\n`;
    });

    markdown += `## STORED PROCEDURES POR SCHEMA\n\n`;
    Object.keys(report.stored_procedures.by_schema).forEach(schema => {
      const count = report.stored_procedures.by_schema[schema].length;
      markdown += `- **${schema}:** ${count} SPs\n`;
    });

    fs.writeFileSync(mdPath, markdown);
    console.log(`✅ Resumen MD guardado en: ${mdPath}\n`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
  } finally {
    await client.end();
    console.log('\n🔌 Conexión cerrada');
  }
}

// Ejecutar
extractDatabaseStructure().catch(console.error);
