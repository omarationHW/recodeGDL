// Test script para verificar stored procedures de conslic400
const fetch = require('node-fetch');

async function testConslic400SPs() {
  console.log('=== PRUEBA DE STORED PROCEDURES CONSLIC400 ===\n');

  // Test 1: Verificar SP_CONSLIC400_GET
  console.log('1. PROBANDO SP_CONSLIC400_GET...');
  try {
    const testLicencia = 160107; // Usar una licencia que sabemos que existe

    const eRequest = {
      Operacion: 'sp_conslic400_get',
      Base: 'padron_licencias',
      Parametros: [
        {
          nombre: 'p_licencia',
          valor: testLicencia
        }
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
      console.log('✅ SP_CONSLIC400_GET funciona correctamente');
      console.log(`   Licencia encontrada: ${data.data[0]?.numlic || 'N/A'}`);
    } else {
      console.log('❌ SP_CONSLIC400_GET falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en SP_CONSLIC400_GET:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 2: Verificar SP_CONSLIC400_PAGOS
  console.log('2. PROBANDO SP_CONSLIC400_PAGOS...');
  try {
    const testLicencia = 160107;

    const eRequest = {
      Operacion: 'sp_conslic400_pagos',
      Base: 'padron_licencias',
      Parametros: [
        {
          nombre: 'p_licencia',
          valor: testLicencia
        }
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

    if (data.success) {
      console.log('✅ SP_CONSLIC400_PAGOS funciona correctamente');
      console.log(`   Pagos encontrados: ${data.data?.length || 0}`);
    } else {
      console.log('❌ SP_CONSLIC400_PAGOS falló:', data.error || 'Sin datos');
    }

  } catch (error) {
    console.log('❌ Error en SP_CONSLIC400_PAGOS:', error.message);
  }

  console.log('\n' + '='.repeat(60) + '\n');

  // Test 3: Verificar si necesitamos crear los SPs
  console.log('3. VERIFICANDO SI EXISTEN LOS STORED PROCEDURES...');

  const procedures = ['sp_conslic400_get', 'sp_conslic400_pagos'];

  for (const proc of procedures) {
    try {
      const eRequest = {
        Operacion: proc,
        Base: 'padron_licencias',
        Parametros: [{ nombre: 'p_licencia', valor: 1 }],
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
  console.log('- El componente consLic400frm ha sido actualizado con la configuración correcta');
}

testConslic400SPs();