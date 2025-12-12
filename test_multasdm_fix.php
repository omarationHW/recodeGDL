<?php
// Script para crear multas_dm con más registros y paginación server-side

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Eliminar función existente si existe
    echo "1. Eliminando función existente si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_multas_dm(VARCHAR, INTEGER, INTEGER, INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de multas DM
    echo "2. Recreando tabla publico.multas_dm...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.multas_dm CASCADE");

    $sql = "
    CREATE TABLE publico.multas_dm (
        id_multa SERIAL PRIMARY KEY,
        clave_cuenta VARCHAR(50) NOT NULL,
        folio VARCHAR(50) NOT NULL,
        ejercicio INTEGER NOT NULL,
        importe NUMERIC(12,2) NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        fecha_registro DATE NOT NULL,
        contribuyente VARCHAR(200),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 70 registros de prueba distribuidos en diferentes cuentas y años
    echo "3. Insertando 70 registros de multas DM...\n";

    $contribuyentes = [
        'MARIA GUADALUPE HERNANDEZ LOPEZ',
        'JUAN CARLOS MARTINEZ GARCIA',
        'ANA PATRICIA RODRIGUEZ SANCHEZ',
        'JOSE LUIS GONZALEZ RAMIREZ',
        'CARMEN ROSA LOPEZ FERNANDEZ',
        'FRANCISCO JAVIER PEREZ TORRES',
        'LAURA ELENA JIMENEZ CRUZ',
        'ROBERTO CARLOS SANCHEZ MORALES',
        'GABRIELA MENDEZ ORTIZ',
        'MIGUEL ANGEL VAZQUEZ RUIZ'
    ];

    $estados = ['PENDIENTE', 'PAGADA', 'CANCELADA', 'EN PROCESO'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.multas_dm
        (clave_cuenta, folio, ejercicio, importe, estatus, fecha_registro, contribuyente)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 70; $i++) {
        // Generar cuentas agrupadas
        if ($i <= 20) {
            $cuenta = "DM-CTA-001";
            $ejercicio = 2024;
        } elseif ($i <= 40) {
            $cuenta = "DM-CTA-002";
            $ejercicio = 2024;
        } elseif ($i <= 55) {
            $cuenta = "DM-CTA-003";
            $ejercicio = 2023;
        } else {
            $cuenta = "DM-CTA-004";
            $ejercicio = 2023;
        }

        $folio = "FOL-DM-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $importe = 1500.00 + ($i * 85.50);
        $estatus = $estados[$i % 4];
        $fecha = date('Y-m-d', strtotime("{$ejercicio}-01-01 +{$i} days"));
        $contribuyente = $contribuyentes[$i % 10];

        $stmt->execute([
            $cuenta,
            $folio,
            $ejercicio,
            $importe,
            $estatus,
            $fecha,
            $contribuyente
        ]);
    }
    echo "   ✓ 70 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - DM-CTA-001 (2024): 20 registros\n";
    echo "   - DM-CTA-002 (2024): 20 registros\n";
    echo "   - DM-CTA-003 (2023): 15 registros\n";
    echo "   - DM-CTA-004 (2023): 15 registros\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_multas_dm_cuenta ON publico.multas_dm(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_multas_dm_ejercicio ON publico.multas_dm(ejercicio)");
    $pdo->exec("CREATE INDEX idx_multas_dm_folio ON publico.multas_dm(folio)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure con paginación server-side
    echo "5. Creando stored procedure publico.recaudadora_multas_dm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_multas_dm(
        p_clave_cuenta VARCHAR,
        p_ejercicio INTEGER,
        p_offset INTEGER,
        p_limit INTEGER
    )
    RETURNS TABLE (
        total_registros BIGINT,
        clave_cuenta VARCHAR,
        folio VARCHAR,
        ejercicio INTEGER,
        importe NUMERIC,
        estatus VARCHAR
    )
    LANGUAGE plpgsql
    AS \$\$
    DECLARE
        v_total_registros BIGINT;
    BEGIN
        -- Primero calcular el total de registros que coinciden
        SELECT COUNT(*)
        INTO v_total_registros
        FROM publico.multas_dm m
        WHERE
            (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
            AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR m.ejercicio = p_ejercicio);

        -- Luego devolver los registros paginados con el total incluido
        RETURN QUERY
        SELECT
            v_total_registros,
            m.clave_cuenta,
            m.folio,
            m.ejercicio,
            m.importe,
            m.estatus
        FROM publico.multas_dm m
        WHERE
            (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
            AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR m.ejercicio = p_ejercicio)
        ORDER BY m.ejercicio DESC, m.fecha_registro DESC, m.id_multa DESC
        LIMIT p_limit
        OFFSET p_offset;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todas las multas del año 2024 (primera página)',
            'cuenta' => '',
            'ejercicio' => 2024,
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta DM-CTA-001 en 2024 (debe tener 20 total)',
            'cuenta' => 'DM-CTA-001',
            'ejercicio' => 2024,
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta DM-CTA-003 en 2023 (debe tener 15 total)',
            'cuenta' => 'DM-CTA-003',
            'ejercicio' => 2023,
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Todas las cuentas en 2023 (primera página)',
            'cuenta' => '',
            'ejercicio' => 2023,
            'offset' => 0,
            'limit' => 10
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm(?, ?, ?, ?)");
        $stmt->execute([$test['cuenta'], $test['ejercicio'], $test['offset'], $test['limit']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total = $rows[0]['total_registros'] ?? 0;
        echo "   Total de registros que coinciden: {$total}\n";
        echo "   Registros devueltos en esta página: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "   Primeros 2 registros:\n";
            foreach (array_slice($rows, 0, 2) as $row) {
                echo "      - Cuenta: " . $row['clave_cuenta'] .
                     " - Folio: " . $row['folio'] .
                     " - Ejercicio: " . $row['ejercicio'] .
                     " - Importe: $" . number_format($row['importe'], 2) .
                     " - Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla multas_dm recreada con 70 registros\n";
    echo "   - Paginación server-side implementada (offset/limit)\n";
    echo "   - Campo total_registros incluido en cada fila\n";
    echo "   - Filtro por cuenta y ejercicio (año)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
