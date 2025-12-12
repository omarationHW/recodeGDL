<?php
// Script para actualizar multasfrmcalif - versión con DROP FUNCTION

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Eliminar la función existente si existe
    echo "1. Eliminando función existente si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_multasfrmcalif(VARCHAR, INTEGER, INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de calificación de multas
    echo "2. Recreando tabla publico.multas_calificacion...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.multas_calificacion CASCADE");

    $sql = "
    CREATE TABLE publico.multas_calificacion (
        id_multa SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        anio INTEGER NOT NULL,
        fecha_acta DATE NOT NULL,
        clave_cuenta VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        ley VARCHAR(50),
        infraccion VARCHAR(100),
        calificacion NUMERIC(12,2) NOT NULL,
        multa NUMERIC(12,2) NOT NULL,
        gastos NUMERIC(12,2) DEFAULT 0,
        total NUMERIC(12,2) NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 80 registros de prueba con diferentes cuentas
    echo "3. Insertando 80 registros de calificación de multas...\n";

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

    $leyes = [
        'LEY-001',
        'LEY-002',
        'LEY-003',
        'LEY-400',
        'LEY-500'
    ];

    $infracciones = [
        'Art. 23 Fracc. I',
        'Art. 45 Fracc. II',
        'Art. 67 Fracc. III',
        'Art. 89 Fracc. IV',
        'Art. 100 Fracc. V'
    ];

    $estados = ['PENDIENTE', 'PAGADA', 'CANCELADA'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.multas_calificacion
        (folio, anio, fecha_acta, clave_cuenta, contribuyente, ley, infraccion,
         calificacion, multa, gastos, total, estatus)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 80; $i++) {
        $folio = "CAL-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $anio = 2024;
        $fecha = date('Y-m-d', strtotime("2024-01-01 +{$i} days"));

        // Generar cuentas agrupadas para facilitar búsqueda
        if ($i <= 25) {
            $cuenta = "CTA-CALIF-001";
        } elseif ($i <= 50) {
            $cuenta = "CTA-CALIF-002";
        } elseif ($i <= 70) {
            $cuenta = "CTA-CALIF-003";
        } else {
            $cuenta = "CTA-CALIF-004";
        }

        $contribuyente = $contribuyentes[$i % 10];
        $ley = $leyes[$i % 5];
        $infraccion = $infracciones[$i % 5];

        $calificacion = 1000.00 + ($i * 50.00);
        $multa = $calificacion * 1.15; // 15% más
        $gastos = 200.00 + ($i * 10.00);
        $total = $multa + $gastos;
        $estatus = $estados[$i % 3];

        $stmt->execute([
            $folio,
            $anio,
            $fecha,
            $cuenta,
            $contribuyente,
            $ley,
            $infraccion,
            $calificacion,
            $multa,
            $gastos,
            $total,
            $estatus
        ]);
    }
    echo "   ✓ 80 registros insertados.\n";
    echo "   - CTA-CALIF-001: 25 registros\n";
    echo "   - CTA-CALIF-002: 25 registros\n";
    echo "   - CTA-CALIF-003: 20 registros\n";
    echo "   - CTA-CALIF-004: 10 registros\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_multas_calif_cuenta ON publico.multas_calificacion(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_multas_calif_folio ON publico.multas_calificacion(folio)");
    $pdo->exec("CREATE INDEX idx_multas_calif_contrib ON publico.multas_calificacion(contribuyente)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure con paginación server-side
    echo "5. Creando stored procedure publico.recaudadora_multasfrmcalif...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_multasfrmcalif(
        p_clave_cuenta VARCHAR,
        p_offset INTEGER,
        p_limit INTEGER
    )
    RETURNS TABLE (
        total_registros BIGINT,
        id_multa INTEGER,
        folio VARCHAR,
        anio INTEGER,
        fecha_acta DATE,
        contribuyente VARCHAR,
        ley VARCHAR,
        infraccion VARCHAR,
        calificacion NUMERIC,
        multa NUMERIC,
        gastos NUMERIC,
        total NUMERIC,
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
        FROM publico.multas_calificacion m
        WHERE
            CASE
                WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
                ELSE (
                    m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                    OR m.folio ILIKE '%' || p_clave_cuenta || '%'
                    OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
                )
            END;

        -- Luego devolver los registros paginados con el total incluido
        RETURN QUERY
        SELECT
            v_total_registros,
            m.id_multa,
            m.folio,
            m.anio,
            m.fecha_acta,
            m.contribuyente,
            m.ley,
            m.infraccion,
            m.calificacion,
            m.multa,
            m.gastos,
            m.total,
            m.estatus
        FROM publico.multas_calificacion m
        WHERE
            CASE
                WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
                ELSE (
                    m.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                    OR m.folio ILIKE '%' || p_clave_cuenta || '%'
                    OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
                )
            END
        ORDER BY m.fecha_acta DESC, m.id_multa DESC
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
            'nombre' => 'Primera página sin filtro (10 registros de 80 total)',
            'cuenta' => '',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta CTA-CALIF-001 (primera página, debe tener 25 total)',
            'cuenta' => 'CTA-CALIF-001',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta CTA-CALIF-002 (primera página, debe tener 25 total)',
            'cuenta' => 'CTA-CALIF-002',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta CTA-CALIF-003 (primera página, debe tener 20 total)',
            'cuenta' => 'CTA-CALIF-003',
            'offset' => 0,
            'limit' => 10
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrmcalif(?, ?, ?)");
        $stmt->execute([$test['cuenta'], $test['offset'], $test['limit']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total = $rows[0]['total_registros'] ?? 0;
        echo "   Total de registros que coinciden: {$total}\n";
        echo "   Registros devueltos en esta página: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "   Primeros 2 registros:\n";
            foreach (array_slice($rows, 0, 2) as $row) {
                echo "      - ID: " . $row['id_multa'] .
                     " - Folio: " . $row['folio'] .
                     " - " . $row['contribuyente'] .
                     " - Ley: " . $row['ley'] .
                     " - Total: $" . number_format($row['total'], 2) .
                     " - Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla multas_calificacion recreada con 80 registros\n";
    echo "   - Paginación server-side implementada (offset/limit)\n";
    echo "   - Campo total_registros incluido en cada fila\n";
    echo "   - Filtro busca en: clave_cuenta, folio y contribuyente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
