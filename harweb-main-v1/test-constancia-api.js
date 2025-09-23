// Test script para verificar la API de constancias
const fetch = require('node-fetch');

async function testConstanciaAPI() {
  console.log('=== PRUEBA DE API CONSTANCIAS ===\n');

  try {
    const eRequest = {
      Operacion: 'sp_constancia_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_axo', valor: null },
        { nombre: 'p_folio', valor: null },
        { nombre: 'p_solicita', valor: null },
        { nombre: 'p_partidapago', valor: null },
        { nombre: 'p_vigente', valor: null },
        { nombre: 'p_limite', valor: 10 },
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
      console.log('✅ sp_constancia_list funciona correctamente');
      console.log(`   Constancias encontradas: ${data.data.length}`);
      if (data.data.length > 0) {
        console.log('   Primera constancia:', data.data[0]);
      }
    } else {
      console.log('❌ sp_constancia_list falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en la prueba:', error.message);
  }
}

testConstanciaAPI();