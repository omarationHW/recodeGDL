const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function checkLicenciasTables() {
  try {
    console.log('🔍 Buscando tablas relacionadas con licencias...');

    // Buscar todas las tablas que contengan 'licencia' en el nombre
    const tablesQuery = `
      SELECT
        schemaname,
        tablename,
        tableowner
      FROM pg_tables
      WHERE tablename ILIKE '%licencia%'
      OR tablename ILIKE '%lic%'
      ORDER BY schemaname, tablename;
    `;

    const tables = await pool.query(tablesQuery);
    console.log(`📋 Encontradas ${tables.rows.length} tablas relacionadas con licencias:`);

    for (const table of tables.rows) {
      console.log(`   ${table.schemaname}.${table.tablename}`);

      // Obtener estructura de cada tabla
      const columnsQuery = `
        SELECT
          column_name,
          data_type,
          is_nullable,
          character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = $1 AND table_name = $2
        ORDER BY ordinal_position;
      `;

      const columns = await pool.query(columnsQuery, [table.schemaname, table.tablename]);
      console.log(`     Columnas (${columns.rows.length}):`);

      columns.rows.forEach(col => {
        const maxLength = col.character_maximum_length ? `(${col.character_maximum_length})` : '';
        console.log(`       - ${col.column_name}: ${col.data_type}${maxLength} ${col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'}`);
      });

      // Contar registros
      const countQuery = `SELECT COUNT(*) as total FROM "${table.schemaname}"."${table.tablename}";`;
      try {
        const count = await pool.query(countQuery);
        console.log(`     Registros: ${count.rows[0].total}`);
      } catch (error) {
        console.log(`     Error contando registros: ${error.message}`);
      }

      console.log('');
    }

    // Buscar también en otros esquemas
    console.log('🔍 Buscando en todos los esquemas...');
    const allSchemasQuery = `
      SELECT DISTINCT schemaname
      FROM pg_tables
      WHERE schemaname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
      ORDER BY schemaname;
    `;

    const schemas = await pool.query(allSchemasQuery);
    console.log(`📂 Esquemas disponibles: ${schemas.rows.map(s => s.schemaname).join(', ')}`);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkLicenciasTables();