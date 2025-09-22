// Script para verificar las tablas relacionadas con empresas
const { Client } = require('pg');

async function checkEmpresasTable() {
  const client = new Client({
    host: '192.168.6.146',
    port: 5432,
    database: 'padron_licencias',
    user: 'refact',
    password: 'FF)-BQk2'
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL');

    // Verificar qué tablas existen relacionadas con empresas
    console.log('🔍 Buscando tablas relacionadas con empresas...');
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (
        table_name LIKE '%empresa%' OR
        table_name LIKE '%comercio%' OR
        table_name LIKE '%negocio%' OR
        table_name LIKE '%contribuyente%' OR
        table_name LIKE '%patron%' OR
        table_name LIKE '%establ%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas encontradas:', tablesResult.rows.map(r => r.table_name));

    // Si existe una tabla de empresas, analizar su estructura
    for (const table of tablesResult.rows) {
      const tableName = table.table_name;
      console.log(`\n🔧 Analizando estructura de ${tableName}:`);

      const columnsResult = await client.query(`
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'informix' AND table_name = $1
        ORDER BY ordinal_position;
      `, [tableName]);

      columnsResult.rows.forEach(col => {
        console.log(`  ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? 'NOT NULL' : 'NULL'} ${col.column_default ? `DEFAULT ${col.column_default}` : ''}`);
      });

      // Mostrar algunos datos de ejemplo
      try {
        const sampleResult = await client.query(`SELECT * FROM informix.${tableName} LIMIT 3`);
        if (sampleResult.rows.length > 0) {
          console.log(`\n📊 Datos de ejemplo de ${tableName}:`);
          sampleResult.rows.forEach((row, idx) => {
            console.log(`  Registro ${idx + 1}:`, row);
          });
        }
      } catch (error) {
        console.log(`  ⚠️ No se pudieron obtener datos de ejemplo: ${error.message}`);
      }
    }

    // Si no hay tablas específicas de empresas, buscar en tablas que contengan campos de RFC, razón social
    if (tablesResult.rows.length === 0) {
      console.log('\n🔍 No se encontraron tablas específicas de empresas. Buscando tablas con campos de RFC...');
      const rfcTablesResult = await client.query(`
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'informix'
        AND (
          column_name LIKE '%rfc%' OR
          column_name LIKE '%razon%' OR
          column_name LIKE '%social%' OR
          column_name LIKE '%nombre%' OR
          column_name LIKE '%comercial%'
        )
        ORDER BY table_name;
      `);

      console.log('📋 Tablas con campos de empresa:');
      rfcTablesResult.rows.forEach(table => {
        console.log(`  - ${table.table_name}`);
      });

      // Analizar la primera tabla para ver qué datos tiene
      if (rfcTablesResult.rows.length > 0) {
        const firstTable = rfcTablesResult.rows[0].table_name;
        console.log(`\n📊 Estructura y datos de ${firstTable}:`);

        const columnsResult = await client.query(`
          SELECT column_name, data_type, is_nullable
          FROM information_schema.columns
          WHERE table_schema = 'informix' AND table_name = $1
          ORDER BY ordinal_position;
        `, [firstTable]);

        columnsResult.rows.forEach(col => {
          console.log(`  ${col.column_name}: ${col.data_type}`);
        });

        try {
          const sampleResult = await client.query(`SELECT * FROM informix.${firstTable} LIMIT 3`);
          if (sampleResult.rows.length > 0) {
            console.log(`\n📊 Datos de ejemplo de ${firstTable}:`);
            sampleResult.rows.forEach((row, idx) => {
              console.log(`  Registro ${idx + 1}:`, row);
            });
          }
        } catch (error) {
          console.log(`  ⚠️ Error obteniendo datos: ${error.message}`);
        }
      }
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkEmpresasTable();