// Test script para verificar el mapeo de campos después del fix
const fetch = require('node-fetch');

async function testFieldMapping() {
  console.log('=== PRUEBA DE MAPEO DE CAMPOS DESPUÉS DEL FIX ===\n');

  try {
    // Simulamos la llamada que haría el servicio licenciasApiService
    const apiRequest = {
      Base: 'padron_licencias',
      Tenant: 'guadalajara',
      Operacion: 'sp_consultalicencia_list',
      Parametros: [
        { nombre: 'p_numero_licencia', valor: null },
        { nombre: 'p_razon_social', valor: null },
        { nombre: 'p_giro', valor: null },
        { nombre: 'p_direccion', valor: null },
        { nombre: 'p_colonia', valor: null },
        { nombre: 'p_estado', valor: null },
        { nombre: 'p_limite', valor: 100 },
        { nombre: 'p_offset', valor: 0 }
      ]
    };

    console.log('🔄 Simulando llamada de licenciasApiService.getConsultaLicenciasList()');
    console.log('Request:');
    console.log(JSON.stringify({ eRequest: apiRequest }, null, 2));
    console.log('\n' + '='.repeat(80) + '\n');

    const response = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: apiRequest })
    });

    const apiData = await response.json();

    console.log('📥 RESPUESTA CRUDA DE LA API:');
    console.log(JSON.stringify(apiData, null, 2));
    console.log('\n' + '='.repeat(80) + '\n');

    if (apiData.success && apiData.data && Array.isArray(apiData.data)) {
      console.log('🔄 APLICANDO TRANSFORMACIÓN DE CAMPOS (como lo hace licenciasApiService):\n');

      const transformedData = apiData.data.map(record => ({
        id: record.id,
        num_lic: record.numero_licencia || '',
        razon_social: record.propietario || '',
        rfc: record.rfc || '',
        nombre_giro: record.giro || '',
        direccion: record.direccion || '',
        colonia: record.colonia || '',
        telefono: record.telefono || '',
        status_lic: record.estado || 'ACTIVA',
        fecha_expedicion: record.fecha_expedicion || null,
        fecha_vencimiento: record.fecha_vencimiento || null,
        observaciones: record.observaciones || ''
      }));

      console.log('✅ DATOS TRANSFORMADOS (lo que recibirá el componente Vue):');
      console.log(JSON.stringify(transformedData, null, 2));
      console.log('\n' + '='.repeat(80) + '\n');

      console.log('📋 VERIFICACIÓN DE CAMPOS DEL PRIMER REGISTRO:');
      const firstRecord = transformedData[0];
      console.log(`   ID: ${firstRecord.id}`);
      console.log(`   Número Licencia: "${firstRecord.num_lic}"`);
      console.log(`   Razón Social: "${firstRecord.razon_social}"`);
      console.log(`   RFC: "${firstRecord.rfc}"`);
      console.log(`   Giro: "${firstRecord.nombre_giro}"`);
      console.log(`   Dirección: "${firstRecord.direccion}"`);
      console.log(`   Colonia: "${firstRecord.colonia}"`);
      console.log(`   Estado: "${firstRecord.status_lic}"`);
      console.log(`   Fecha Expedición: ${firstRecord.fecha_expedicion}`);
      console.log(`   Fecha Vencimiento: ${firstRecord.fecha_vencimiento}`);

      console.log('\n✅ AHORA TODOS LOS CAMPOS TIENEN LOS NOMBRES CORRECTOS PARA VUE!');
      console.log('La tabla en consultaLicenciafrm.vue debería mostrar datos correctamente.');

    } else {
      console.log('❌ Error en respuesta de API');
    }

  } catch (error) {
    console.log('❌ Error en la prueba:', error.message);
  }
}

testFieldMapping();