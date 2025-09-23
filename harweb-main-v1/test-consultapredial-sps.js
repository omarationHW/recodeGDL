// Test script para verificar stored procedures de consultapredial
const fetch = require('node-fetch');

async function testConsultapredialSPs() {
  console.log('=== PRUEBA DE STORED PROCEDURES CONSULTAPREDIAL ===\n');

  // Test 1: Verificar sp_consultapredial_list
  console.log('1. PROBANDO sp_consultapredial_list...');
  try {
    const eRequest = {
      Operacion: 'sp_consultapredial_list',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_cuenta_predial', valor: null },
        { nombre: 'p_propietario', valor: null },
        { nombre: 'p_direccion', valor: null },
        { nombre: 'p_colonia', valor: null },
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
    console.log('Response:', JSON.stringify(data, null, 2));

    if (data.success && data.data) {
      console.log('✅ sp_consultapredial_list funciona correctamente');
      console.log(`   Predios encontrados: ${data.data.length}`);
      if (data.data.length > 0) {
        console.log(`   Primer predio: ${data.data[0].cuenta_predial || 'N/A'} - ${data.data[0].propietario || 'N/A'}`);
      }
    } else {
      console.log('❌ sp_consultapredial_list falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en sp_consultapredial_list:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 2: Verificar sp_consultapredial_create
  console.log('2. PROBANDO sp_consultapredial_create...');
  try {
    const testPredio = {
      cuenta_predial: 'TEST-001-001-01',
      propietario: 'PREDIO DE PRUEBA',
      direccion: 'DIRECCION DE PRUEBA #123',
      colonia: 'COLONIA DE PRUEBA'
    };

    const eRequest = {
      Operacion: 'sp_consultapredial_create',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_cuenta_predial', valor: testPredio.cuenta_predial },
        { nombre: 'p_propietario', valor: testPredio.propietario },
        { nombre: 'p_direccion', valor: testPredio.direccion },
        { nombre: 'p_colonia', valor: testPredio.colonia },
        { nombre: 'p_codigo_postal', valor: null },
        { nombre: 'p_superficie_terreno', valor: null },
        { nombre: 'p_superficie_construccion', valor: null },
        { nombre: 'p_uso_suelo', valor: null },
        { nombre: 'p_zona', valor: null },
        { nombre: 'p_valor_catastral', valor: null },
        { nombre: 'p_coordenada_x', valor: null },
        { nombre: 'p_coordenada_y', valor: null },
        { nombre: 'p_observaciones', valor: 'Predio de prueba - test' }
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
      console.log('✅ sp_consultapredial_create existe y responde');
    } else {
      console.log('❌ sp_consultapredial_create falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en sp_consultapredial_create:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 3: Verificar sp_consultapredial_update
  console.log('3. PROBANDO sp_consultapredial_update...');
  try {
    const eRequest = {
      Operacion: 'sp_consultapredial_update',
      Base: 'padron_licencias',
      Parametros: [
        { nombre: 'p_id', valor: 1 },
        { nombre: 'p_propietario', valor: 'PROPIETARIO ACTUALIZADO' },
        { nombre: 'p_direccion', valor: 'DIRECCION ACTUALIZADA' },
        { nombre: 'p_colonia', valor: 'COLONIA ACTUALIZADA' },
        { nombre: 'p_codigo_postal', valor: null },
        { nombre: 'p_superficie_terreno', valor: null },
        { nombre: 'p_superficie_construccion', valor: null },
        { nombre: 'p_uso_suelo', valor: null },
        { nombre: 'p_zona', valor: null },
        { nombre: 'p_valor_catastral', valor: null },
        { nombre: 'p_coordenada_x', valor: null },
        { nombre: 'p_coordenada_y', valor: null },
        { nombre: 'p_observaciones', valor: null }
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
      console.log('✅ sp_consultapredial_update existe y responde');
    } else {
      console.log('❌ sp_consultapredial_update falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en sp_consultapredial_update:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 4: Verificar si necesitamos crear los SPs
  console.log('4. VERIFICANDO SI EXISTEN LOS STORED PROCEDURES...');

  const procedures = [
    'sp_consultapredial_list',
    'sp_consultapredial_create',
    'sp_consultapredial_update'
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
  console.log('- El componente consultapredial ha sido actualizado con la configuración correcta');
}

testConsultapredialSPs();