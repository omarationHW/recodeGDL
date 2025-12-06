<?php
/**
 * VERIFICAR TODOS LOS SPs DE LOS 3 COMPONENTES
 */

$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

$conn = pg_connect(sprintf(
    "host=%s port=%s dbname=%s user=%s password=%s",
    $config['host'], $config['port'], $config['dbname'], $config['user'], $config['password']
));

if (!$conn) {
    die("ERROR: No se pudo conectar a la BD\n");
}

echo "========================================================\n";
echo "VERIFICACIÓN COMPLETA DE LOS 3 COMPONENTES\n";
echo "========================================================\n\n";

$componentes = [
    'RptFacturaEmision' => [
        'sp_rpt_factura_emision',
        'sp_get_vencimiento_rec',
        'sp_get_recaudadoras',
        'sp_get_mercados_by_recaudadora'
    ],
    'RptFacturaEnergia' => [
        'rpt_factura_energia',
        'sp_get_recaudadoras',
        'sp_get_mercados_by_recaudadora'
    ],
    'RptIngresoZonificado' => [
        'sp_ingreso_zonificado'
    ]
];

$resumen = [];

foreach ($componentes as $componente => $sps) {
    echo "------------------------------------------------------\n";
    echo "$componente\n";
    echo "------------------------------------------------------\n";

    $found = 0;
    $missing = [];

    foreach ($sps as $sp) {
        $query = "
            SELECT proname, pg_get_function_identity_arguments(p.oid) as args
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public' AND p.proname = '$sp'
        ";

        $result = pg_query($conn, $query);

        if ($result && pg_num_rows($result) > 0) {
            $row = pg_fetch_assoc($result);
            echo "  ✓ $sp\n";
            if ($row['args']) {
                echo "    Args: {$row['args']}\n";
            }
            $found++;
        } else {
            echo "  ✗ $sp - NO EXISTE\n";
            $missing[] = $sp;
        }
    }

    $total = count($sps);
    $resumen[$componente] = [
        'found' => $found,
        'total' => $total,
        'missing' => $missing,
        'status' => ($found === $total) ? '✅ COMPLETO' : '⚠️ INCOMPLETO'
    ];

    echo "\n  Status: $found/$total SPs " . $resumen[$componente]['status'] . "\n\n";
}

pg_close($conn);

echo "========================================================\n";
echo "RESUMEN GENERAL\n";
echo "========================================================\n\n";

foreach ($resumen as $componente => $info) {
    echo "$componente: {$info['found']}/{$info['total']} {$info['status']}\n";
    if (count($info['missing']) > 0) {
        echo "  Faltantes:\n";
        foreach ($info['missing'] as $sp) {
            echo "    - $sp\n";
        }
    }
}

echo "\n========================================================\n";

// Verificar estado final
$todos_completos = true;
foreach ($resumen as $info) {
    if ($info['found'] !== $info['total']) {
        $todos_completos = false;
        break;
    }
}

if ($todos_completos) {
    echo "✅ TODOS LOS COMPONENTES TIENEN SUS SPs COMPLETOS\n";
} else {
    echo "⚠️ ALGUNOS COMPONENTES TIENEN SPs FALTANTES\n";
}

echo "========================================================\n";
