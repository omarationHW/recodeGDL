// Test script para verificar la API de firmausuario
const fetch = require('node-fetch');

async function testFirmaUsuarioAPI() {
  console.log('=== PRUEBA DE API FIRMAUSUARIO ===\n');

  try {
    // 1. Probar sp_firmausuario_list
    console.log('1. Probando sp_firmausuario_list...');
    const listRequest = {
      Operacion: 'sp_firmausuario_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_usuario', valor: null },
        { nombre: 'p_estado', valor: null },
        { nombre: 'p_sesion_activa', valor: null },
        { nombre: 'p_limite', valor: 5 },
        { nombre: 'p_offset', valor: 0 }
      ],
      Tenant: 'informix'
    };

    const listResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: listRequest })
    });

    const listData = await listResponse.json();
    console.log('   Resultado sp_firmausuario_list:', {
      success: listData.success,
      count: listData.data?.length || 0,
      firstRecord: listData.data?.[0] || null
    });

    // 2. Probar sp_firmausuario_autenticar
    console.log('\n2. Probando sp_firmausuario_autenticar...');
    const authRequest = {
      Operacion: 'sp_firmausuario_autenticar',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_usuario', valor: 'cljara' },
        { nombre: 'p_pin', valor: 'cljara' }
      ],
      Tenant: 'informix'
    };

    const authResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: authRequest })
    });

    const authData = await authResponse.json();
    console.log('   Resultado sp_firmausuario_autenticar:', {
      success: authData.success,
      data: authData.data?.[0] || null
    });

    // 3. Probar sp_firmausuario_mantener (Insertar)
    console.log('\n3. Probando sp_firmausuario_mantener (Insertar)...');
    const createRequest = {
      Operacion: 'sp_firmausuario_mantener',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_operacion', valor: 'I' },
        { nombre: 'p_id', valor: null },
        { nombre: 'p_usuario', valor: 'cljara' },
        { nombre: 'p_pin', valor: '1234' },
        { nombre: 'p_estado', valor: 1 },
        { nombre: 'p_reset_intentos', valor: 0 },
        { nombre: 'p_observaciones', valor: 'Usuario de prueba API' }
      ],
      Tenant: 'informix'
    };

    const createResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: createRequest })
    });

    const createData = await createResponse.json();
    console.log('   Resultado sp_firmausuario_mantener:', {
      success: createData.success,
      data: createData.data?.[0] || null
    });

    // 4. Probar sp_firmausuario_sesiones (puede fallar por el error)
    console.log('\n4. Probando sp_firmausuario_sesiones...');
    try {
      const sessionRequest = {
        Operacion: 'sp_firmausuario_sesiones',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_usuario', valor: 'cljara' }
        ],
        Tenant: 'informix'
      };

      const sessionResponse = await fetch('http://localhost:8080/api/generic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: sessionRequest })
      });

      const sessionData = await sessionResponse.json();
      console.log('   Resultado sp_firmausuario_sesiones:', {
        success: sessionData.success,
        count: sessionData.data?.length || 0,
        error: sessionData.error || null
      });
    } catch (error) {
      console.log('   ⚠️ Error en sp_firmausuario_sesiones:', error.message);
    }

    console.log('\n✅ Pruebas de API firmausuario completadas');

  } catch (error) {
    console.log('❌ Error en las pruebas:', error.message);
  }
}

testFirmaUsuarioAPI();