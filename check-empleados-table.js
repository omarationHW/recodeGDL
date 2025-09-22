// Script para verificar la tabla de empleados
const { Client } = require('pg');

async function checkEmpleadosTable() {
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

    // Verificar qué tablas existen relacionadas con empleados
    console.log('🔍 Buscando tablas relacionadas con empleados...');
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (
        table_name LIKE '%empleado%' OR
        table_name LIKE '%user%' OR
        table_name LIKE '%usuario%' OR
        table_name LIKE '%personal%' OR
        table_name LIKE '%staff%' OR
        table_name LIKE '%capturist%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas encontradas:', tablesResult.rows.map(r => r.table_name));

    // Si existe una tabla de empleados, analizar su estructura
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

    // Si no hay tablas específicas de empleados, buscar en tablas que contengan campo 'capturista'
    if (tablesResult.rows.length === 0) {
      console.log('\n🔍 No se encontraron tablas específicas de empleados. Buscando tablas con campo capturista...');
      const capturistaTablesResult = await client.query(`
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'informix'
        AND column_name LIKE '%capturist%'
        ORDER BY table_name;
      `);

      console.log('📋 Tablas con campo capturista:');
      capturistaTablesResult.rows.forEach(table => {
        console.log(`  - ${table.table_name}`);
      });

      // Analizar valores únicos de capturistas en alguna de estas tablas
      if (capturistaTablesResult.rows.length > 0) {
        const firstTable = capturistaTablesResult.rows[0].table_name;
        console.log(`\n📊 Capturistas únicos en ${firstTable}:`);
        try {
          const capturistasResult = await client.query(`
            SELECT DISTINCT TRIM(capturista) as capturista, COUNT(*) as registros
            FROM informix.${firstTable}
            WHERE capturista IS NOT NULL AND TRIM(capturista) != ''
            GROUP BY TRIM(capturista)
            ORDER BY registros DESC
            LIMIT 10;
          `);

          capturistasResult.rows.forEach(cap => {
            console.log(`  ${cap.capturista}: ${cap.registros} registros`);
          });
        } catch (error) {
          console.log(`  ⚠️ Error obteniendo capturistas: ${error.message}`);
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

checkEmpleadosTable();