// Script para verificar tablas con RFC y datos de empresas
const { Client } = require('pg');

async function checkRfcTables() {
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

    // Buscar tablas con campos de RFC
    console.log('🔍 Buscando tablas con campos de RFC...');
    const rfcTablesResult = await client.query(`
      SELECT DISTINCT table_name
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND (
        column_name LIKE '%rfc%' OR
        column_name LIKE '%razon%' OR
        column_name LIKE '%social%' OR
        column_name LIKE '%propietario%' OR
        column_name LIKE '%solicitante%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas con campos de RFC/empresa:');
    rfcTablesResult.rows.forEach(table => {
      console.log(`  - ${table.table_name}`);
    });

    // Analizar las primeras 3 tablas
    for (let i = 0; i < Math.min(3, rfcTablesResult.rows.length); i++) {
      const tableName = rfcTablesResult.rows[i].table_name;
      console.log(`\n🔧 Analizando estructura de ${tableName}:`);

      const columnsResult = await client.query(`
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'informix' AND table_name = $1
        AND (
          column_name LIKE '%rfc%' OR
          column_name LIKE '%razon%' OR
          column_name LIKE '%social%' OR
          column_name LIKE '%propietario%' OR
          column_name LIKE '%solicitante%' OR
          column_name LIKE '%nombre%' OR
          column_name LIKE '%comercial%' OR
          column_name LIKE '%telefono%' OR
          column_name LIKE '%email%' OR
          column_name LIKE '%direccion%' OR
          column_name LIKE '%genero%' OR
          column_name LIKE '%activo%'
        )
        ORDER BY ordinal_position;
      `, [tableName]);

      columnsResult.rows.forEach(col => {
        console.log(`  ${col.column_name}: ${col.data_type}`);
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
        console.log(`  ⚠️ Error obteniendo datos: ${error.message}`);
      }
    }

    // Buscar específicamente en licencias o anuncios que pueden tener datos de empresas
    console.log('\n🔍 Verificando tablas de licencias y anuncios...');
    const licenciasTablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (
        table_name LIKE '%licencia%' OR
        table_name LIKE '%anuncio%' OR
        table_name LIKE '%solicitud%' OR
        table_name LIKE '%tramite%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas de licencias/anuncios:');
    licenciasTablesResult.rows.forEach(table => {
      console.log(`  - ${table.table_name}`);
    });

    // Ver estructura de la primera tabla de licencias
    if (licenciasTablesResult.rows.length > 0) {
      const tableName = licenciasTablesResult.rows[0].table_name;
      console.log(`\n🔧 Estructura de ${tableName}:`);

      const columnsResult = await client.query(`
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'informix' AND table_name = $1
        ORDER BY ordinal_position;
      `, [tableName]);

      columnsResult.rows.forEach(col => {
        console.log(`  ${col.column_name}: ${col.data_type}`);
      });

      // Mostrar algunos datos
      try {
        const sampleResult = await client.query(`SELECT * FROM informix.${tableName} LIMIT 2`);
        if (sampleResult.rows.length > 0) {
          console.log(`\n📊 Datos de ejemplo de ${tableName}:`);
          sampleResult.rows.forEach((row, idx) => {
            console.log(`  Registro ${idx + 1}:`, row);
          });
        }
      } catch (error) {
        console.log(`  ⚠️ Error obteniendo datos: ${error.message}`);
      }
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkRfcTables();