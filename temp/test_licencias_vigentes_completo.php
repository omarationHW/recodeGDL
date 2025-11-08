<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST COMPLETO LICENCIAS VIGENTES\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    $tests = [
        [
            'nombre' => 'Sin filtros (strings vacíos)',
            'params' => [1, 10, '', '', '', '', '', '']
        ],
        [
            'nombre' => 'Sin filtros (NULL)',
            'params' => [1, 10, null, null, null, null, null, null]
        ],
        [
            'nombre' => 'Filtro estado VIGENTE',
            'params' => [1, 10, '', '', 'VIGENTE', '', '', '']
        ],
        [
            'nombre' => 'Filtro zona 1',
            'params' => [1, 10, '', '1', '', '', '', '']
        ],
        [
            'nombre' => 'Filtro fecha desde (2023-01-01)',
            'params' => [1, 10, '', '', '', '2023-01-01', '', '']
        ],
        [
            'nombre' => 'Filtro rango fechas (2023-01-01 a 2023-12-31)',
            'params' => [1, 10, '', '', '', '2023-01-01', '2023-12-31', '']
        ],
        [
            'nombre' => 'Paginación página 2',
            'params' => [2, 10, '', '', '', '', '', '']
        ],
        [
            'nombre' => 'Límite 25 registros',
            'params' => [1, 25, '', '', '', '', '', '']
        ]
    ];

    $allPassed = true;

    foreach ($tests as $index => $test) {
        echo "========================================\n";
        echo "TEST " . ($index + 1) . ": " . $test['nombre'] . "\n";
        echo "========================================\n";

        try {
            $start = microtime(true);

            $stmt = $pdo->prepare("
                SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
                    ?, ?, ?, ?, ?, ?, ?, ?
                )
            ");

            $stmt->execute($test['params']);
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $duration = round((microtime(true) - $start) * 1000, 2);

            echo "✓ Consulta ejecutada ({$duration}ms)\n";
            echo "  Registros obtenidos: " . count($results) . "\n";

            if (count($results) > 0) {
                echo "  Total en BD: " . number_format($results[0]['total_records']) . "\n";

                // Mostrar primer registro como ejemplo
                $registro = $results[0];
                echo "\n  Ejemplo de registro:\n";
                echo "    Número: " . $registro['numero'] . "\n";
                echo "    Propietario: " . substr($registro['propietario'], 0, 30) . (strlen($registro['propietario']) > 30 ? '...' : '') . "\n";
                echo "    Giro: " . substr($registro['giro'], 0, 30) . (strlen($registro['giro']) > 30 ? '...' : '') . "\n";
                echo "    Estado: " . $registro['estado'] . "\n";
                echo "    Zona: " . $registro['zona'] . "\n";
                echo "    Fecha: " . $registro['fecha_otorgamiento'] . "\n";
            }

            echo "\n✅ TEST PASADO\n\n";

        } catch (Exception $e) {
            echo "\n❌ TEST FALLADO\n";
            echo "Error: " . $e->getMessage() . "\n\n";
            $allPassed = false;
        }
    }

    echo "========================================\n";
    if ($allPassed) {
        echo "✅ TODOS LOS TESTS PASARON\n";
    } else {
        echo "⚠ ALGUNOS TESTS FALLARON\n";
    }
    echo "========================================\n";

} catch (Exception $e) {
    echo "\n✗ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
