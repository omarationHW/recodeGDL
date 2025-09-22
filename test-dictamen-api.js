// Test script para verificar la API de dictámenes
const fetch = require('node-fetch');

async function testDictamenAPI() {
  console.log('=== PRUEBA DE API DICTÁMENES ===\n');

  try {
    const eRequest = {
      Operacion: 'sp_dictamen_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_anuncio', valor: null },
        { nombre: 'p_propietario', valor: null },
        { nombre: 'p_clasificacion', valor: null },
        { nombre: 'p_ubicacion', valor: null },
        { nombre: 'p_vigente', valor: null },
        { nombre: 'p_limite', valor: 5 },
        { nombre: 'p_offset', valor: 0 }
      ],
      Tenant: 'informix'
    };

    console.log('Request:', JSON.stringify({ eRequest }, null, 2));

    const response = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest })
    });

    const data = await response.json();
    console.log('Response structure:', {
      success: data.success,
      hasData: !!data.data,
      dataLength: data.data?.length || 0
    });

    if (data.success && data.data) {
      console.log('✅ sp_dictamen_list funciona correctamente');
      console.log(`   Dictámenes encontrados: ${data.data.length}`);
      if (data.data.length > 0) {
        console.log('   Primer dictamen:', data.data[0]);
        console.log('\n   Campos del primer dictamen:');
        Object.keys(data.data[0]).forEach(key => {
          console.log(`     ${key}: ${data.data[0][key]}`);
        });
      }
    } else {
      console.log('❌ sp_dictamen_list falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en la prueba:', error.message);
  }
}

testDictamenAPI();