// Script simple para verificar qué datos retorna la API
const fetch = require('node-fetch');

async function checkApiData() {
  console.log('=== VERIFICACIÓN: API RESPONSE ANALYSIS ===\n');

  try {
    // Simulamos exactamente lo que hace el componente Vue
    const apiRequest = {
      Base: 'padron_licencias',
      Tenant: 'informix',
      Operacion: 'SP_CONSULTALICENCIA_LIST',
      Parametros: [
        { nombre: 'p_limit', valor: 10 },
        { nombre: 'p_offset', valor: 0 }
      ]
    };

    console.log('🔄 Enviando request a la API...');
    console.log('Request body:');
    console.log(JSON.stringify({ eRequest: apiRequest }, null, 2));
    console.log('\n' + '='.repeat(80) + '\n');

    const response = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: apiRequest })
    });

    const apiData = await response.json();

    console.log('📥 RESPUESTA COMPLETA DE LA API:');
    console.log(JSON.stringify(apiData, null, 2));
    console.log('\n' + '='.repeat(80) + '\n');

    if (apiData.success && apiData.data && Array.isArray(apiData.data)) {
      console.log('✅ Datos encontrados:', apiData.data.length, 'registros');
      console.log('\n📋 PRIMEROS 3 REGISTROS DETALLADOS:\n');

      apiData.data.slice(0, 3).forEach((record, index) => {
        console.log(`📄 REGISTRO ${index + 1}:`);
        console.log(`   ID: ${record.id}`);
        console.log(`   Número Licencia: "${record.num_lic}"`);
        console.log(`   Razón Social: "${record.razon_social}"`);
        console.log(`   RFC: "${record.rfc}"`);
        console.log(`   Giro: "${record.nombre_giro}"`);
        console.log(`   Dirección: "${record.direccion}"`);
        console.log(`   Colonia: "${record.colonia}"`);
        console.log(`   Estado: "${record.status_lic}"`);
        console.log(`   Fecha Expedición: ${record.fecha_expedicion}`);
        console.log(`   Fecha Vencimiento: ${record.fecha_vencimiento}`);
        console.log(`   ` + '-'.repeat(60));
      });

      console.log('\n🔍 ANÁLISIS DE TIPOS DE DATOS:');
      const firstRecord = apiData.data[0];
      Object.keys(firstRecord).forEach(key => {
        const value = firstRecord[key];
        const type = typeof value;
        const isNull = value === null;
        const isEmpty = value === '';
        console.log(`   ${key}: ${type}${isNull ? ' (null)' : ''}${isEmpty ? ' (empty string)' : ''} = "${value}"`);
      });

      console.log('\n📊 VERIFICACIONES ESPECÍFICAS:');

      // Verificar si hay valores que podrían ser hardcodeados
      const suspiciousValues = [];
      apiData.data.forEach((record, index) => {
        if (record.razon_social === 'EMPRESA EJEMPLO' ||
            record.razon_social === 'DEMO COMPANY' ||
            record.num_lic === '12345' ||
            record.direccion === 'DIRECCION EJEMPLO') {
          suspiciousValues.push(`Registro ${index + 1}: ${record.razon_social} (${record.num_lic})`);
        }
      });

      if (suspiciousValues.length > 0) {
        console.log('⚠️  POSIBLES VALORES HARDCODEADOS ENCONTRADOS:');
        suspiciousValues.forEach(v => console.log(`   - ${v}`));
      } else {
        console.log('✅ No se detectaron valores hardcodeados obvios');
      }

      // Verificar espacios en blanco
      const recordsWithSpaces = [];
      apiData.data.forEach((record, index) => {
        Object.keys(record).forEach(key => {
          if (typeof record[key] === 'string' && record[key] !== record[key].trim()) {
            recordsWithSpaces.push(`Registro ${index + 1}: Campo "${key}" tiene espacios: "${record[key]}"`);
          }
        });
      });

      if (recordsWithSpaces.length > 0) {
        console.log('\n⚠️  CAMPOS CON ESPACIOS EN BLANCO DETECTADOS:');
        recordsWithSpaces.forEach(r => console.log(`   - ${r}`));
      } else {
        console.log('\n✅ No se detectaron espacios en blanco sin recortar');
      }

    } else {
      console.log('❌ Error: Respuesta inesperada de la API');
      console.log('Success:', apiData.success);
      console.log('Data type:', typeof apiData.data);
      console.log('Is array:', Array.isArray(apiData.data));
    }

  } catch (error) {
    console.log('❌ Error en la verificación:', error.message);
  }
}

checkApiData();