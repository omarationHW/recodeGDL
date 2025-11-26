<?php
/**
 * Script para buscar datos REALES en la tabla reqmultas
 * y generar ejemplos que funcionen para BloqueoMulta.vue
 */

$url = 'http://127.0.0.1:8000/api/generic';

echo "=== BUSCANDO DATOS REALES EN LA BASE DE DATOS ===\n\n";

// Función para ejecutar el SP a través de la API
function ejecutarSP($operacion, $parametros) {
    global $url;

    $data = [
        'eRequest' => [
            'Operacion' => $operacion,
            'Base' => 'multas_reglamentos',
            'Parametros' => $parametros,
            'Tenant' => ''
        ]
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code === 200 && $response) {
        $json = json_decode($response, true);
        if ($json && isset($json['eResponse']['data']['result'])) {
            return $json['eResponse']['data']['result'];
        }
    }
    return [];
}

// Probar diferentes años (del más reciente al más antiguo)
$años_a_probar = [2025, 2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015];

echo "1. BUSCANDO AÑOS CON DATOS...\n";
$años_con_datos = [];

foreach ($años_a_probar as $año) {
    echo "   Probando año $año... ";

    $params = [
        ['nombre' => 'p_clave_cuenta', 'valor' => '', 'tipo' => 'string'],
        ['nombre' => 'p_ejercicio', 'valor' => $año, 'tipo' => 'int'],
        ['nombre' => 'p_offset', 'valor' => 0, 'tipo' => 'int'],
        ['nombre' => 'p_limit', 'valor' => 5, 'tipo' => 'int']
    ];

    $result = ejecutarSP('RECAUDADORA_BLOQUEO_MULTA', $params);

    if (!empty($result)) {
        $count = count($result);
        echo "✓ Encontrados $count registros\n";
        $años_con_datos[$año] = $result;

        // Solo necesitamos 3 años con datos para los ejemplos
        if (count($años_con_datos) >= 3) {
            break;
        }
    } else {
        echo "✗ Sin datos\n";
    }
}

if (empty($años_con_datos)) {
    echo "\n❌ NO SE ENCONTRARON DATOS EN NINGÚN AÑO\n";
    echo "La tabla catastro_gdl.reqmultas no tiene registros con vigencia 'V' o 'B'\n\n";
    echo "SOLUCIÓN:\n";
    echo "1. Ejecuta el script: temp/insertar_multas_prueba.sql\n";
    echo "2. O verifica que existan registros en la tabla con:\n";
    echo "   SELECT COUNT(*) FROM catastro_gdl.reqmultas WHERE vigencia IN ('V', 'B');\n";
    exit(1);
}

echo "\n2. GENERANDO EJEMPLOS CON DATOS REALES...\n\n";

$ejemplo_num = 1;
foreach ($años_con_datos as $año => $registros) {
    foreach ($registros as $idx => $registro) {
        echo "═══════════════════════════════════════════════════\n";
        echo "EJEMPLO #$ejemplo_num: Buscar por Folio y Año\n";
        echo "═══════════════════════════════════════════════════\n\n";

        echo "📋 Datos del registro:\n";
        echo "   Folio: {$registro['folio']}\n";
        echo "   Año: {$registro['ejercicio']}\n";
        echo "   CVEReq: {$registro['cvereq']}\n";
        echo "   Estatus: {$registro['estatus']}\n";
        echo "   Bloqueado: " . ($registro['bloqueado'] ? 'SÍ' : 'NO') . "\n";
        echo "   Multa: $" . number_format($registro['multas'], 2) . "\n";
        echo "   Total: $" . number_format($registro['total'], 2) . "\n";
        if (!empty($registro['observaciones'])) {
            echo "   Observaciones: {$registro['observaciones']}\n";
        }

        echo "\n🎯 Cómo probar en el navegador:\n";
        echo "   1. Abre: http://localhost:3000/multas_reglamentos/bloqueo-multa\n";
        echo "   2. En 'Cuenta' escribe: {$registro['folio']}\n";
        echo "   3. En 'Año' escribe: {$registro['ejercicio']}\n";
        echo "   4. Haz clic en 'Buscar'\n";
        echo "   5. Deberías ver este registro en la tabla\n";

        if (!$registro['bloqueado']) {
            echo "\n🔒 Para probar BLOQUEO:\n";
            echo "   1. Busca el registro como se indica arriba\n";
            echo "   2. Haz clic en el botón amarillo de bloquear (candado)\n";
            echo "   3. Escribe un motivo: 'Prueba de bloqueo - bajo revisión'\n";
            echo "   4. Confirma\n";
            echo "   5. El registro debe cambiar a 'Bloqueado' (badge rojo)\n";
        } else {
            echo "\n🔓 Para probar DESBLOQUEO:\n";
            echo "   1. Busca el registro como se indica arriba\n";
            echo "   2. Haz clic en el botón verde de desbloquear (candado abierto)\n";
            echo "   3. Escribe un motivo: 'Prueba de desbloqueo - revisión completada'\n";
            echo "   4. Confirma\n";
            echo "   5. El registro debe cambiar a 'Vigente' (badge verde)\n";
        }

        echo "\n📞 Llamada a la API (formato cURL):\n";
        echo "curl -X POST http://127.0.0.1:8000/api/generic \\\n";
        echo "  -H 'Content-Type: application/json' \\\n";
        echo "  -d '{\n";
        echo "  \"eRequest\": {\n";
        echo "    \"Operacion\": \"RECAUDADORA_BLOQUEO_MULTA\",\n";
        echo "    \"Base\": \"multas_reglamentos\",\n";
        echo "    \"Parametros\": [\n";
        echo "      {\"nombre\": \"p_clave_cuenta\", \"valor\": \"{$registro['folio']}\", \"tipo\": \"string\"},\n";
        echo "      {\"nombre\": \"p_ejercicio\", \"valor\": {$registro['ejercicio']}, \"tipo\": \"int\"},\n";
        echo "      {\"nombre\": \"p_offset\", \"valor\": 0, \"tipo\": \"int\"},\n";
        echo "      {\"nombre\": \"p_limit\", \"valor\": 10, \"tipo\": \"int\"}\n";
        echo "    ],\n";
        echo "    \"Tenant\": \"\"\n";
        echo "  }\n";
        echo "}'\n";

        echo "\n";
        $ejemplo_num++;

        // Solo mostrar 2 ejemplos por año
        if ($idx >= 1) break;
    }

    // Solo mostrar ejemplos de 2 años
    if ($ejemplo_num > 4) break;
}

echo "\n═══════════════════════════════════════════════════\n";
echo "EJEMPLO RÁPIDO: Buscar SIN filtro de cuenta\n";
echo "═══════════════════════════════════════════════════\n\n";

$primer_año = array_key_first($años_con_datos);
$cantidad = count($años_con_datos[$primer_año]);

echo "📋 Ver todas las multas de un año:\n";
echo "   1. Abre: http://localhost:3000/multas_reglamentos/bloqueo-multa\n";
echo "   2. En 'Cuenta' deja VACÍO\n";
echo "   3. En 'Año' escribe: $primer_año\n";
echo "   4. Haz clic en 'Buscar'\n";
echo "   5. Deberías ver al menos $cantidad registros\n";

echo "\n✅ RESUMEN:\n";
echo "   - Años con datos encontrados: " . count($años_con_datos) . "\n";
foreach ($años_con_datos as $año => $regs) {
    $vigentes = array_filter($regs, fn($r) => !$r['bloqueado']);
    $bloqueados = array_filter($regs, fn($r) => $r['bloqueado']);
    echo "   - Año $año: " . count($regs) . " registros ";
    echo "(" . count($vigentes) . " vigentes, " . count($bloqueados) . " bloqueados)\n";
}

echo "\n🔍 Para ver QUÉ está pasando en el frontend:\n";
echo "   1. Abre DevTools (F12) en el navegador\n";
echo "   2. Ve a la pestaña 'Console'\n";
echo "   3. Haz una búsqueda\n";
echo "   4. Verás logs como:\n";
echo "      🔍 Buscando multas con parámetros: [...]\n";
echo "      📦 Respuesta recibida: {...}\n";
echo "      ✅ Datos asignados: X registros\n";

echo "\n✅ Script completado.\n";
