const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function checkCatalogTables() {
  try {
    console.log('🔍 Buscando tablas de catálogos...');

    // Buscar tablas que contengan 'tipo', 'estado', 'catalogo', 'cat_'
    const catalogQuery = `
      SELECT
        schemaname,
        tablename,
        tableowner
      FROM pg_tables
      WHERE (tablename ILIKE '%tipo%'
         OR tablename ILIKE '%estado%'
         OR tablename ILIKE '%catalogo%'
         OR tablename ILIKE '%cat_%'
         OR tablename ILIKE '%c_%'
         OR tablename ILIKE '%vigente%'
         OR tablename ILIKE '%status%')
      AND schemaname = 'informix'
      ORDER BY tablename;
    `;

    const tables = await pool.query(catalogQuery);
    console.log(`📋 Encontradas ${tables.rows.length} tablas de catálogos:`);

    for (const table of tables.rows) {
      console.log(`\n   📂 ${table.schemaname}.${table.tablename}`);

      // Obtener estructura de cada tabla
      const columnsQuery = `
        SELECT
          column_name,
          data_type,
          is_nullable
        FROM information_schema.columns
        WHERE table_schema = $1 AND table_name = $2
        ORDER BY ordinal_position
        LIMIT 5;
      `;

      const columns = await pool.query(columnsQuery, [table.schemaname, table.tablename]);
      console.log(`     Columnas: ${columns.rows.map(c => c.column_name).join(', ')}`);

      // Contar registros
      try {
        const countQuery = `SELECT COUNT(*) as total FROM "${table.schemaname}"."${table.tablename}";`;
        const count = await pool.query(countQuery);
        console.log(`     Registros: ${count.rows[0].total}`);

        // Mostrar algunos datos de ejemplo si hay registros
        if (parseInt(count.rows[0].total) > 0) {
          const sampleQuery = `SELECT * FROM "${table.schemaname}"."${table.tablename}" LIMIT 3;`;
          const sample = await pool.query(sampleQuery);
          console.log(`     Ejemplo: ${JSON.stringify(sample.rows[0])}`);
        }
      } catch (error) {
        console.log(`     Error: ${error.message}`);
      }
    }

    // Buscar también en licenciasleyenda los valores únicos de tipo_registro y vigente
    console.log('\n🔍 Valores únicos en licenciasleyenda:');

    const tiposQuery = `SELECT DISTINCT tipo_registro, COUNT(*) as cantidad FROM informix.licenciasleyenda WHERE tipo_registro IS NOT NULL GROUP BY tipo_registro ORDER BY cantidad DESC;`;
    const tipos = await pool.query(tiposQuery);
    console.log('   Tipos de registro:', tipos.rows);

    const vigentesQuery = `SELECT DISTINCT vigente, COUNT(*) as cantidad FROM informix.licenciasleyenda WHERE vigente IS NOT NULL GROUP BY vigente ORDER BY cantidad DESC;`;
    const vigentes = await pool.query(vigentesQuery);
    console.log('   Estados vigente:', vigentes.rows);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkCatalogTables();