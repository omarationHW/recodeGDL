// Script para verificar discrepancia entre DOM y base de datos
const { Pool } = require('pg');

// Configuración de base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function checkDatabaseData() {
  console.log('=== VERIFICACIÓN: DOM vs BASE DE DATOS ===\n');

  try {
    // Simular la misma consulta que usa la aplicación
    const query = `
      SELECT
        l.id,
        COALESCE(TRIM(l.numeroLicencia), '')::VARCHAR(20) as num_lic,
        COALESCE(TRIM(l.propietario), '')::VARCHAR(255) as razon_social,
        COALESCE(TRIM(l.rfc), '')::VARCHAR(20) as rfc,
        COALESCE(TRIM(l.giro), '')::VARCHAR(255) as nombre_giro,
        COALESCE(TRIM(l.direccion), '')::VARCHAR(500) as direccion,
        COALESCE(TRIM(l.colonia), '')::VARCHAR(100) as colonia,
        COALESCE(TRIM(l.telefono), '')::VARCHAR(20) as telefono,
        COALESCE(TRIM(l.estado), 'ACTIVA')::VARCHAR(20) as status_lic,
        l.fecha_expedicion::DATE as fecha_expedicion,
        l.fecha_vencimiento::DATE as fecha_vencimiento,
        COALESCE(TRIM(l.observaciones), '')::TEXT as observaciones
      FROM informix.licenciasleyenda l
      WHERE l.numeroLicencia IS NOT NULL
        AND l.numeroLicencia != ''
        AND TRIM(l.numeroLicencia) != ''
      ORDER BY l.id DESC
      LIMIT 10;
    `;

    console.log('1. CONSULTA SQL EJECUTADA:');
    console.log(query);
    console.log('\n' + '='.repeat(80) + '\n');

    const result = await pool.query(query);

    console.log('2. DATOS DIRECTOS DE LA BASE DE DATOS:');
    console.log(`Total registros encontrados: ${result.rows.length}\n`);

    result.rows.forEach((row, index) => {
      console.log(`Registro ${index + 1}:`);
      console.log(`  ID: ${row.id}`);
      console.log(`  Número Licencia: "${row.num_lic}"`);
      console.log(`  Razón Social: "${row.razon_social}"`);
      console.log(`  RFC: "${row.rfc}"`);
      console.log(`  Giro: "${row.nombre_giro}"`);
      console.log(`  Dirección: "${row.direccion}"`);
      console.log(`  Colonia: "${row.colonia}"`);
      console.log(`  Estado: "${row.status_lic}"`);
      console.log(`  Fecha Expedición: ${row.fecha_expedicion}`);
      console.log(`  Fecha Vencimiento: ${row.fecha_vencimiento}`);
      console.log(`  ` + '-'.repeat(60));
    });

    console.log('\n' + '='.repeat(80) + '\n');

    // Ahora simular el llamado a la API
    console.log('3. SIMULANDO LLAMADA A LA API...\n');

    const fetch = require('node-fetch');

    const apiRequest = {
      Base: 'padron_licencias',
      Tenant: 'informix',
      StoreProcedure: 'SP_CONSULTALICENCIA_LIST',
      Parametros: [
        { nombre: 'p_limit', valor: 10 },
        { nombre: 'p_offset', valor: 0 }
      ]
    };

    console.log('Request enviado a API:');
    console.log(JSON.stringify(apiRequest, null, 2));
    console.log('\n');

    try {
      const response = await fetch('http://localhost:8080/api/generic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: apiRequest })
      });

      const apiData = await response.json();
      console.log('4. RESPUESTA DE LA API:');
      console.log(JSON.stringify(apiData, null, 2));

      if (apiData.success && apiData.data) {
        console.log('\n' + '='.repeat(80) + '\n');
        console.log('5. COMPARACIÓN DETALLADA:');

        const dbIds = result.rows.map(r => r.id).sort();
        const apiIds = apiData.data.map(r => r.id).sort();

        console.log(`DB IDs: [${dbIds.join(', ')}]`);
        console.log(`API IDs: [${apiIds.join(', ')}]`);

        const dbFirstRecord = result.rows[0];
        const apiFirstRecord = apiData.data.find(r => r.id === dbFirstRecord.id);

        if (apiFirstRecord) {
          console.log('\nComparación primer registro:');
          console.log(`DB  - ID: ${dbFirstRecord.id}, Licencia: "${dbFirstRecord.num_lic}", Razón: "${dbFirstRecord.razon_social}"`);
          console.log(`API - ID: ${apiFirstRecord.id}, Licencia: "${apiFirstRecord.num_lic}", Razón: "${apiFirstRecord.razon_social}"`);

          const fieldsToCompare = ['num_lic', 'razon_social', 'nombre_giro', 'direccion', 'colonia', 'status_lic'];
          let differences = [];

          fieldsToCompare.forEach(field => {
            const dbValue = String(dbFirstRecord[field] || '').trim();
            const apiValue = String(apiFirstRecord[field] || '').trim();

            if (dbValue !== apiValue) {
              differences.push({
                field,
                db: dbValue,
                api: apiValue
              });
            }
          });

          if (differences.length > 0) {
            console.log('\n⚠️  DIFERENCIAS ENCONTRADAS:');
            differences.forEach(diff => {
              console.log(`  ${diff.field}:`);
              console.log(`    DB:  "${diff.db}"`);
              console.log(`    API: "${diff.api}"`);
            });
          } else {
            console.log('\n✅ Los datos son idénticos entre DB y API');
          }
        }

      } else {
        console.log('❌ Error en respuesta de API o datos vacíos');
      }

    } catch (apiError) {
      console.log('❌ Error llamando a la API:', apiError.message);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkDatabaseData();