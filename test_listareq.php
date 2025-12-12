<?php
// Script para crear el SP listareq con filtrado correcto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear tabla para requerimientos si no existe
    echo "1. Creando tabla publico.requerimientos...\n";
    $sql = "
    CREATE TABLE IF NOT EXISTS publico.requerimientos (
        id SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        clave_cuenta VARCHAR(50) NOT NULL,
        ejercicio INTEGER NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        concepto VARCHAR(200) NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        fecha_emision DATE NOT NULL,
        estado VARCHAR(20) NOT NULL,
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada o ya existe.\n\n";

    // 2. Insertar datos de prueba (100 registros con diferentes cuentas)
    echo "2. Insertando 100 registros de prueba...\n";
    $pdo->exec("DELETE FROM publico.requerimientos");

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

    $conceptos = [
        'Predial',
        'Agua',
        'Licencia Comercial',
        'Multa de Tránsito',
        'Derechos de Construcción'
    ];

    $estados = ['PENDIENTE', 'PAGADO', 'VENCIDO', 'CANCELADO'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.requerimientos
        (folio, clave_cuenta, ejercicio, contribuyente, domicilio, concepto, monto, fecha_emision, estado, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 100; $i++) {
        $year = 2024;
        $folio = "REQ-{$year}-" . str_pad($i, 4, '0', STR_PAD_LEFT);

        // Generar diferentes patrones de cuentas para facilitar el filtrado
        if ($i <= 20) {
            $cuenta = "CTA-001-" . str_pad($i, 3, '0', STR_PAD_LEFT); // Cuentas del 001
        } elseif ($i <= 40) {
            $cuenta = "CTA-002-" . str_pad($i - 20, 3, '0', STR_PAD_LEFT); // Cuentas del 002
        } elseif ($i <= 60) {
            $cuenta = "CTA-003-" . str_pad($i - 40, 3, '0', STR_PAD_LEFT); // Cuentas del 003
        } elseif ($i <= 80) {
            $cuenta = "CTA-004-" . str_pad($i - 60, 3, '0', STR_PAD_LEFT); // Cuentas del 004
        } else {
            $cuenta = "CTA-005-" . str_pad($i - 80, 3, '0', STR_PAD_LEFT); // Cuentas del 005
        }

        $contribuyente = $contribuyentes[$i % 10];
        $domicilio = "AV PRINCIPAL #" . (100 + $i) . " COL CENTRO";
        $concepto = $conceptos[$i % 5];
        $monto = 1000.00 + ($i * 50.00);
        $fecha = date('Y-m-d', strtotime("2024-01-01 +{$i} days"));
        $estado = $estados[$i % 4];
        $obs = "Observación del requerimiento " . $folio;

        $stmt->execute([
            $folio,
            $cuenta,
            $year,
            $contribuyente,
            $domicilio,
            $concepto,
            $monto,
            $fecha,
            $estado,
            $obs
        ]);
    }
    echo "   ✓ 100 registros insertados.\n\n";

    // 3. Crear o reemplazar el stored procedure con filtrado correcto
    echo "3. Creando stored procedure publico.recaudadora_listareq...\n";
    $sql = "
    CREATE OR REPLACE FUNCTION publico.recaudadora_listareq(
        p_clave_cuenta VARCHAR
    )
    RETURNS TABLE (
        folio VARCHAR,
        clave_cuenta VARCHAR,
        ejercicio INTEGER,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        concepto VARCHAR,
        monto NUMERIC,
        fecha_emision DATE,
        estado VARCHAR,
        observaciones TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        -- Si p_clave_cuenta está vacío o es NULL, devolver todos los registros
        -- Si tiene valor, filtrar por clave_cuenta, folio o contribuyente
        RETURN QUERY
        SELECT
            r.folio,
            r.clave_cuenta,
            r.ejercicio,
            r.contribuyente,
            r.domicilio,
            r.concepto,
            r.monto,
            r.fecha_emision,
            r.estado,
            r.observaciones
        FROM publico.requerimientos r
        WHERE
            CASE
                WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
                ELSE (
                    r.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                    OR r.folio ILIKE '%' || p_clave_cuenta || '%'
                    OR r.contribuyente ILIKE '%' || p_clave_cuenta || '%'
                )
            END
        ORDER BY r.fecha_emision DESC, r.folio DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 4. Probar el SP con varios ejemplos
    echo "4. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Sin filtro (debe traer todos los 100 registros)',
            'param' => ''
        ],
        [
            'nombre' => 'Filtrar por cuenta CTA-001 (debe traer 20 registros)',
            'param' => 'CTA-001'
        ],
        [
            'nombre' => 'Filtrar por cuenta CTA-003 (debe traer 20 registros)',
            'param' => 'CTA-003'
        ],
        [
            'nombre' => 'Filtrar por folio REQ-2024-0050 (debe traer 1 registro)',
            'param' => 'REQ-2024-0050'
        ],
        [
            'nombre' => 'Filtrar por contribuyente MARIA (debe traer ~10 registros)',
            'param' => 'MARIA'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?)");
        $stmt->execute([$test['param']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   Resultados: " . count($rows) . " registros\n";
        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - " . $row['folio'] .
                     " - Cuenta: " . $row['clave_cuenta'] .
                     " - " . $row['contribuyente'] .
                     " - " . $row['concepto'] .
                     " - $" . number_format($row['monto'], 2) .
                     " - " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 NOTA: Ahora el filtro funciona correctamente:\n";
    echo "   - Campo vacío: trae TODOS los registros (100)\n";
    echo "   - Con valor: filtra por clave_cuenta, folio o contribuyente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
