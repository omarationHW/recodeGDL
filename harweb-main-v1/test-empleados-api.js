// Test script para verificar la API de empleados
const fetch = require('node-fetch');

async function testEmpleadosAPI() {
  console.log('=== PRUEBA DE API EMPLEADOS ===\n');

  try {
    const eRequest = {
      Operacion: 'sp_empleados_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_nombre', valor: null },
        { nombre: 'p_correo', valor: null },
        { nombre: 'p_activo', valor: null },
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
      console.log('✅ sp_empleados_list funciona correctamente');
      console.log(`   Empleados encontrados: ${data.data.length}`);
      if (data.data.length > 0) {
        console.log('   Primer empleado:', data.data[0]);
        console.log('\n   Campos del primer empleado:');
        Object.keys(data.data[0]).forEach(key => {
          console.log(`     ${key}: ${data.data[0][key]}`);
        });
      }
    } else {
      console.log('❌ sp_empleados_list falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en la prueba:', error.message);
  }
}

testEmpleadosAPI();