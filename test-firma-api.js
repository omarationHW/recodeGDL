// Test script para verificar la API de firma
const fetch = require('node-fetch');

async function testFirmaAPI() {
  console.log('=== PRUEBA DE API FIRMA ===\n');

  try {
    // 1. Probar sp_firma_list
    console.log('1. Probando sp_firma_list...');
    const listRequest = {
      Operacion: 'sp_firma_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_usuario', valor: null },
        { nombre: 'p_estado', valor: null },
        { nombre: 'p_nivel', valor: null },
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
    console.log('   Resultado sp_firma_list:', {
      success: listData.success,
      count: listData.data?.length || 0,
      firstRecord: listData.data?.[0] || null
    });

    // 2. Probar sp_firma_verificar
    console.log('\n2. Probando sp_firma_verificar...');
    const verifyRequest = {
      Operacion: 'sp_firma_verificar',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_usuario', valor: 'cljara' },
        { nombre: 'p_clave', valor: 'cljara' }
      ],
      Tenant: 'informix'
    };

    const verifyResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: verifyRequest })
    });

    const verifyData = await verifyResponse.json();
    console.log('   Resultado sp_firma_verificar:', {
      success: verifyData.success,
      data: verifyData.data?.[0] || null
    });

    // 3. Probar sp_firma_create
    console.log('\n3. Probando sp_firma_create...');
    const createRequest = {
      Operacion: 'sp_firma_create',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_usuario', valor: 'cljara' },
        { nombre: 'p_firma_digital', valor: 'firma_digital_test_123' },
        { nombre: 'p_nivel_seguridad', valor: 2 },
        { nombre: 'p_estado', valor: 1 },
        { nombre: 'p_observaciones', valor: 'Firma de prueba API' }
      ],
      Tenant: 'informix'
    };

    const createResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: createRequest })
    });

    const createData = await createResponse.json();
    console.log('   Resultado sp_firma_create:', {
      success: createData.success,
      data: createData.data?.[0] || null
    });

    // 4. Probar sp_firma_update
    console.log('\n4. Probando sp_firma_update...');
    const updateRequest = {
      Operacion: 'sp_firma_update',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_id', valor: 'cljara' },
        { nombre: 'p_usuario', valor: 'cljara' },
        { nombre: 'p_firma_digital', valor: 'firma_digital_updated_456' },
        { nombre: 'p_nivel_seguridad', valor: 3 },
        { nombre: 'p_estado', valor: 1 },
        { nombre: 'p_observaciones', valor: 'Firma actualizada via API' }
      ],
      Tenant: 'informix'
    };

    const updateResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: updateRequest })
    });

    const updateData = await updateResponse.json();
    console.log('   Resultado sp_firma_update:', {
      success: updateData.success,
      data: updateData.data?.[0] || null
    });

    // 5. Probar sp_firma_delete
    console.log('\n5. Probando sp_firma_delete...');
    const deleteRequest = {
      Operacion: 'sp_firma_delete',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_id', valor: 'cljara' }
      ],
      Tenant: 'informix'
    };

    const deleteResponse = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest: deleteRequest })
    });

    const deleteData = await deleteResponse.json();
    console.log('   Resultado sp_firma_delete:', {
      success: deleteData.success,
      data: deleteData.data?.[0] || null
    });

    console.log('\n✅ Todas las pruebas de API firma completadas');

  } catch (error) {
    console.log('❌ Error en las pruebas:', error.message);
  }
}

testFirmaAPI();