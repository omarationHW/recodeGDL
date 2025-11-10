#!/usr/bin/env node

/**
 * Script para Analizar el Esquema de la Base de Datos
 * Conecta a PostgreSQL y extrae información sobre tablas y columnas
 */

const { Client } = require('pg');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

async function analyzeSchema() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    console.log('\n✅ Conectado a la base de datos\n');

    // Obtener todas las tablas
    const tablesQuery = `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
      ORDER BY table_name;
    `;

    const tablesResult = await client.query(tablesQuery);
    console.log(`📊 Total de tablas encontradas: ${tablesResult.rows.length}\n`);

    const schemaInfo = {};

    // Para cada tabla, obtener sus columnas
    for (const table of tablesResult.rows) {
      const tableName = table.table_name;

      const columnsQuery = `
        SELECT
          column_name,
          data_type,
          character_maximum_length,
          is_nullable,
          column_default
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = $1
        ORDER BY ordinal_position;
      `;

      const columnsResult = await client.query(columnsQuery, [tableName]);

      schemaInfo[tableName] = columnsResult.rows.map(col => ({
        name: col.column_name,
        type: col.data_type,
        maxLength: col.character_maximum_length,
        nullable: col.is_nullable === 'YES',
        default: col.column_default
      }));

      console.log(`\n📋 Tabla: ${tableName} (${columnsResult.rows.length} columnas)`);
      columnsResult.rows.forEach(col => {
        const nullInfo = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
        const typeInfo = col.character_maximum_length
          ? `${col.data_type}(${col.character_maximum_length})`
          : col.data_type;
        console.log(`   - ${col.column_name}: ${typeInfo} ${nullInfo}`);
      });
    }

    // Buscar tablas relacionadas con trámites
    console.log('\n\n🔍 TABLAS RELACIONADAS CON TRÁMITES:\n');
    const tramiteTables = tablesResult.rows.filter(t =>
      t.table_name.toLowerCase().includes('tramite')
    );

    if (tramiteTables.length > 0) {
      tramiteTables.forEach(t => console.log(`   - ${t.table_name}`));
    } else {
      console.log('   ⚠️  No se encontraron tablas con "tramite" en el nombre');
    }

    // Buscar tablas relacionadas con usuarios/firma
    console.log('\n🔍 TABLAS RELACIONADAS CON USUARIOS/FIRMA:\n');
    const userTables = tablesResult.rows.filter(t =>
      t.table_name.toLowerCase().includes('usuario') ||
      t.table_name.toLowerCase().includes('user') ||
      t.table_name.toLowerCase().includes('firma')
    );

    if (userTables.length > 0) {
      userTables.forEach(t => console.log(`   - ${t.table_name}`));
    } else {
      console.log('   ⚠️  No se encontraron tablas con "usuario" o "firma" en el nombre');
    }

    // Guardar esquema completo en JSON
    const fs = require('fs');
    const path = require('path');
    const outputPath = path.join(__dirname, 'database-schema.json');

    fs.writeFileSync(
      outputPath,
      JSON.stringify({
        database: dbConfig.database,
        totalTables: tablesResult.rows.length,
        tables: schemaInfo,
        generatedAt: new Date().toISOString()
      }, null, 2),
      'utf8'
    );

    console.log(`\n\n📄 Esquema completo guardado en: ${outputPath}\n`);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  analyzeSchema()
    .then(() => {
      console.log('\n✅ Análisis completado\n');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n❌ Error fatal:', error);
      process.exit(1);
    });
}

module.exports = { analyzeSchema };
