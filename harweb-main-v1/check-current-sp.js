const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function checkCurrentSP() {
  try {
    console.log('🔍 Checking current SP_CONSULTALICENCIA_LIST definition...');

    // Obtener la definición del stored procedure
    const spQuery = `
      SELECT pg_get_functiondef(oid) as definition
      FROM pg_proc
      WHERE proname = 'sp_consultalicencia_list'
      AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'informix');
    `;

    const result = await pool.query(spQuery);
    if (result.rows.length > 0) {
      console.log('📋 Current SP definition:');
      console.log(result.rows[0].definition);
    } else {
      console.log('❌ SP not found');
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkCurrentSP();