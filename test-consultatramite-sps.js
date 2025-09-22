// Test script para verificar stored procedures de consultatramite
const fetch = require('node-fetch');

async function testConsultaTramiteSPs() {
  console.log('=== PRUEBA DE STORED PROCEDURES CONSULTATRAMITE ===\n');

  // Test 1: Verificar sp_consultatramite_list
  console.log('1. PROBANDO sp_consultatramite_list...');
  try {
    const eRequest = {
      Operacion: 'sp_consultatramite_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_page', valor: 1 },
        { nombre: 'p_limit', valor: 10 },
        { nombre: 'p_search', valor: '' }
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
    console.log('Response:', JSON.stringify(data, null, 2));

    if (data.success && data.data) {
      console.log('✅ sp_consultatramite_list funciona correctamente');
      console.log(`   Trámites encontrados: ${data.data.length}`);
      if (data.data.length > 0) {
        console.log(`   Primer trámite: ID ${data.data[0].id_tramite} - ${data.data[0].propietario || 'N/A'}`);
      }
    } else {
      console.log('❌ sp_consultatramite_list falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en sp_consultatramite_list:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 2: Verificar sp_consultatramite_create
  console.log('2. PROBANDO sp_consultatramite_create...');
  try {
    const testTramite = {
      tipo_tramite: '1',
      propietario: 'TRAMITE DE PRUEBA WEB',
      rfc: 'PRUW800101',
      cvecuenta: null,
      ubicacion: 'DIRECCION DE PRUEBA #123',
      colonia_ubic: null,
      numext_ubic: null,
      actividad: 'ACTIVIDAD DE PRUEBA PARA TEST',
      estatus: 'A',
      capturista: 'webuser',
      observaciones: 'Trámite de prueba - test sistema web',
      inversion: 0,
      num_empleados: 0,
      sup_autorizada: 0,
      computer: 'web-app'
    };

    const eRequest = {
      Operacion: 'sp_consultatramite_create',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_tipo_tramite', valor: testTramite.tipo_tramite },
        { nombre: 'p_propietario', valor: testTramite.propietario },
        { nombre: 'p_rfc', valor: testTramite.rfc },
        { nombre: 'p_cvecuenta', valor: testTramite.cvecuenta },
        { nombre: 'p_ubicacion', valor: testTramite.ubicacion },
        { nombre: 'p_colonia_ubic', valor: testTramite.colonia_ubic },
        { nombre: 'p_numext_ubic', valor: testTramite.numext_ubic },
        { nombre: 'p_actividad', valor: testTramite.actividad },
        { nombre: 'p_estatus', valor: testTramite.estatus },
        { nombre: 'p_capturista', valor: testTramite.capturista },
        { nombre: 'p_observaciones', valor: testTramite.observaciones },
        { nombre: 'p_inversion', valor: testTramite.inversion },
        { nombre: 'p_num_empleados', valor: testTramite.num_empleados },
        { nombre: 'p_sup_autorizada', valor: testTramite.sup_autorizada },
        { nombre: 'p_computer', valor: testTramite.computer }
      ],
      Tenant: 'informix'
    };

    console.log('Request (sample):', JSON.stringify({ eRequest }, null, 2));

    const response = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest })
    });

    const data = await response.json();
    console.log('Response:', JSON.stringify(data, null, 2));

    if (data.success) {
      console.log('✅ sp_consultatramite_create existe y responde');
    } else {
      console.log('❌ sp_consultatramite_create falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en sp_consultatramite_create:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 3: Verificar sp_consultatramite_update
  console.log('3. PROBANDO sp_consultatramite_update...');
  try {
    const eRequest = {
      Operacion: 'sp_consultatramite_update',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_id_tramite', valor: 1 },
        { nombre: 'p_propietario', valor: 'PROPIETARIO ACTUALIZADO' },
        { nombre: 'p_rfc', valor: 'ACTU800101' },
        { nombre: 'p_cvecuenta', valor: null },
        { nombre: 'p_ubicacion', valor: 'DIRECCION ACTUALIZADA' },
        { nombre: 'p_actividad', valor: 'ACTIVIDAD ACTUALIZADA' },
        { nombre: 'p_estatus', valor: 'A' },
        { nombre: 'p_observaciones', valor: 'Observaciones actualizadas' }
      ],
      Tenant: 'informix'
    };

    console.log('Request (sample):', JSON.stringify({ eRequest }, null, 2));

    const response = await fetch('http://localhost:8080/api/generic', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eRequest })
    });

    const data = await response.json();
    console.log('Response:', JSON.stringify(data, null, 2));

    if (data.success) {
      console.log('✅ sp_consultatramite_update existe y responde');
    } else {
      console.log('❌ sp_consultatramite_update falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en sp_consultatramite_update:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 4: Verificar si necesitamos crear los SPs
  console.log('4. VERIFICANDO SI EXISTEN LOS STORED PROCEDURES...');

  const procedures = [
    'sp_consultatramite_list',
    'sp_consultatramite_create',
    'sp_consultatramite_update'
  ];

  for (const proc of procedures) {
    try {
      const eRequest = {
        Operacion: proc,
        Base: 'padron_licencias',
        Parametros: [{ nombre: 'p_test', valor: 1 }],
        Tenant: 'informix'
      };

      const response = await fetch('http://localhost:8080/api/generic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });

      const data = await response.json();

      if (data.error && data.error.includes('does not exist')) {
        console.log(`❌ ${proc.toUpperCase()} NO EXISTE - necesita ser creado`);
      } else {
        console.log(`✅ ${proc.toUpperCase()} existe`);
      }
    } catch (error) {
      console.log(`❌ Error verificando ${proc}:`, error.message);
    }
  }

  console.log('\n📋 CONCLUSIÓN:');
  console.log('- Si los SPs no existen, necesitamos crearlos');
  console.log('- Si existen pero fallan, verificar parámetros y estructura de datos');
  console.log('- El componente ConsultaTramitefrm ha sido actualizado con la configuración correcta');
}

testConsultaTramiteSPs();