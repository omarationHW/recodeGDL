const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DB_CONFIG = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

const DATABASE_DIR = path.join(__dirname, 'database', 'database');
const REPORT_PATH = path.join(__dirname, 'database', 'sp-deployment-report.json');

async function getAllSqlFiles() {
  const files = fs.readdirSync(DATABASE_DIR)
    .filter(f => f.endsWith('.sql'))
    .sort();

  // Ordenar: archivos _all_procedures.sql primero, luego individuales
  const allProceduresFiles = files.filter(f => f.endsWith('_all_procedures.sql'));
  const individualFiles = files.filter(f => !f.endsWith('_all_procedures.sql'));

  return [...allProceduresFiles.sort(), ...individualFiles.sort()];
}

function extractProcedureName(sqlContent) {
  // Extraer nombre del SP de CREATE OR REPLACE FUNCTION
  const patterns = [
    /CREATE\s+OR\s+REPLACE\s+FUNCTION\s+(\w+)\s*\(/i,
    /CREATE\s+FUNCTION\s+(\w+)\s*\(/i,
    /CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+(\w+)\s*\(/i,
    /CREATE\s+PROCEDURE\s+(\w+)\s*\(/i,
  ];

  for (const pattern of patterns) {
    const match = sqlContent.match(pattern);
    if (match) return match[1];
  }

  return null;
}

async function deployStoredProcedure(client, filePath, fileName) {
  const result = {
    archivo: fileName,
    sp_nombre: null,
    estado: 'error',
    mensaje_error: null,
    probado: false,
    funciona: false,
    sql_content_length: 0,
  };

  try {
    const sqlContent = fs.readFileSync(filePath, 'utf8');
    result.sql_content_length = sqlContent.length;

    // Extraer nombre del SP
    result.sp_nombre = extractProcedureName(sqlContent);

    if (!result.sp_nombre) {
      result.mensaje_error = 'No se pudo extraer el nombre del procedimiento';
      return result;
    }

    // Ejecutar el SQL
    await client.query(sqlContent);
    result.estado = 'exitoso';

    // Verificar que el SP existe
    const checkQuery = `
      SELECT proname, pronargs
      FROM pg_proc
      WHERE proname = $1
    `;
    const checkResult = await client.query(checkQuery, [result.sp_nombre]);

    if (checkResult.rows.length > 0) {
      result.probado = true;
      result.funciona = true;
    } else {
      result.probado = true;
      result.funciona = false;
      result.mensaje_error = 'SP no encontrado después de ejecutar';
    }

  } catch (error) {
    result.estado = 'error';
    result.mensaje_error = error.message;

    // Si el error es que ya existe, intentar DROP y recrear
    if (error.message.includes('already exists')) {
      try {
        if (result.sp_nombre) {
          // Intentar obtener la firma completa
          const dropQuery = `DROP FUNCTION IF EXISTS ${result.sp_nombre} CASCADE`;
          await client.query(dropQuery);

          // Reintentar crear
          const sqlContent = fs.readFileSync(filePath, 'utf8');
          await client.query(sqlContent);

          result.estado = 'exitoso';
          result.mensaje_error = 'Recreado después de DROP';
          result.probado = true;
          result.funciona = true;
        }
      } catch (retryError) {
        result.mensaje_error = `Error al recrear: ${retryError.message}`;
      }
    }
  }

  return result;
}

async function main() {
  const client = new Client(DB_CONFIG);
  const startTime = Date.now();

  console.log('🚀 Iniciando despliegue de SPs...');
  console.log(`📂 Directorio: ${DATABASE_DIR}`);

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL');

    const sqlFiles = getAllSqlFiles();
    console.log(`📊 Total de archivos SQL: ${sqlFiles.length}`);

    const report = {
      fecha: new Date().toISOString().split('T')[0],
      hora_inicio: new Date(startTime).toISOString(),
      total_archivos: sqlFiles.length,
      archivos_procesados: 0,
      sps_ingresados: 0,
      sps_exitosos: 0,
      sps_con_errores: 0,
      detalle: {},
      errores: [],
    };

    let counter = 0;
    for (const fileName of sqlFiles) {
      counter++;
      const filePath = path.join(DATABASE_DIR, fileName);

      console.log(`\n[${counter}/${sqlFiles.length}] Procesando: ${fileName}`);

      const result = await deployStoredProcedure(client, filePath, fileName);

      report.archivos_procesados++;
      report.detalle[fileName] = result;

      if (result.sp_nombre) {
        report.sps_ingresados++;
      }

      if (result.estado === 'exitoso') {
        report.sps_exitosos++;
        console.log(`  ✅ ${result.sp_nombre} - EXITOSO`);
      } else {
        report.sps_con_errores++;
        report.errores.push({
          archivo: fileName,
          sp: result.sp_nombre,
          error: result.mensaje_error,
        });
        console.log(`  ❌ ${result.sp_nombre || 'N/A'} - ERROR: ${result.mensaje_error}`);
      }
    }

    const endTime = Date.now();
    report.hora_fin = new Date(endTime).toISOString();
    report.duracion_segundos = Math.round((endTime - startTime) / 1000);

    // Guardar reporte
    fs.writeFileSync(REPORT_PATH, JSON.stringify(report, null, 2), 'utf8');

    console.log('\n' + '='.repeat(80));
    console.log('📊 REPORTE FINAL');
    console.log('='.repeat(80));
    console.log(`Total archivos procesados: ${report.archivos_procesados}`);
    console.log(`SPs ingresados: ${report.sps_ingresados}`);
    console.log(`SPs exitosos: ${report.sps_exitosos} ✅`);
    console.log(`SPs con errores: ${report.sps_con_errores} ❌`);
    console.log(`Duración: ${report.duracion_segundos} segundos`);
    console.log(`\n📄 Reporte guardado en: ${REPORT_PATH}`);

    if (report.errores.length > 0) {
      console.log('\n⚠️  ERRORES ENCONTRADOS:');
      report.errores.slice(0, 10).forEach((err, idx) => {
        console.log(`  ${idx + 1}. ${err.archivo} (${err.sp}): ${err.error.substring(0, 100)}`);
      });
      if (report.errores.length > 10) {
        console.log(`  ... y ${report.errores.length - 10} errores más`);
      }
    }

  } catch (error) {
    console.error('❌ Error fatal:', error.message);
    process.exit(1);
  } finally {
    await client.end();
    console.log('\n✅ Conexión cerrada');
  }
}

main().catch(console.error);
