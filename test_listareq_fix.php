<?php
// Script para crear tabla requerimientos y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listareq(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de requerimientos
    echo "2. Creando tabla publico.requerimientos...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.requerimientos CASCADE");

    $sql = "
    CREATE TABLE publico.requerimientos (
        id_requerimiento SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        clave_cuenta VARCHAR(50) NOT NULL,
        ejercicio INTEGER NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300) NOT NULL,
        concepto VARCHAR(200) NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        fecha_emision DATE NOT NULL,
        estado VARCHAR(30) NOT NULL,
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de requerimientos
    echo "3. Insertando 55 registros de requerimientos...\n";

    $contribuyentes = [
        'JUAN CARLOS MARTINEZ GARCIA',
        'MARIA GUADALUPE HERNANDEZ LOPEZ',
        'JOSE LUIS GONZALEZ RAMIREZ',
        'ANA PATRICIA RODRIGUEZ SANCHEZ',
        'ROBERTO CARLOS SANCHEZ MORALES',
        'LAURA ELENA JIMENEZ CRUZ',
        'FRANCISCO JAVIER PEREZ TORRES',
        'GABRIELA MENDEZ ORTIZ',
        'MIGUEL ANGEL VAZQUEZ RUIZ',
        'CARMEN ROSA LOPEZ FERNANDEZ',
        'PEDRO ANTONIO CASTRO REYES'
    ];

    $conceptos = [
        'PAGO DE IMPUESTO PREDIAL',
        'REQUERIMIENTO DE MULTA DE TRANSITO',
        'PAGO DE LICENCIA DE FUNCIONAMIENTO',
        'PAGO DE DERECHOS DE AGUA',
        'REQUERIMIENTO DE DERECHOS DE CONSTRUCCION',
        'PAGO DE LICENCIA DE ANUNCIO',
        'REQUERIMIENTO DE IMPUESTO PREDIAL ATRASADO',
        'PAGO DE DERECHOS POR USO DE SUELO',
        'REQUERIMIENTO DE PAGO DE SERVICIO DE LIMPIA',
        'PAGO DE DERECHOS DE MERCADO'
    ];

    $estados = ['PENDIENTE', 'NOTIFICADO', 'EN PROCESO', 'PAGADO', 'VENCIDO', 'CANCELADO'];

    $observaciones_list = [
        'Requerimiento emitido por falta de pago',
        'Notificación personal realizada',
        'Contribuyente solicita convenio de pago',
        'Domicilio no localizado',
        null,
        'Pago parcial recibido',
        'Se otorgó prórroga de 30 días',
        'Contribuyente presenta documentación'
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.requerimientos
        (folio, clave_cuenta, ejercicio, contribuyente, domicilio, concepto, monto, fecha_emision, estado, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 55; $i++) {
        $folio = "REQ-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $clave_cuenta = "CTA-" . str_pad(1000 + $i, 6, '0', STR_PAD_LEFT);

        // Ejercicio: distribuir entre 2022, 2023, 2024
        if ($i <= 15) {
            $ejercicio = 2024;
        } elseif ($i <= 35) {
            $ejercicio = 2023;
        } else {
            $ejercicio = 2022;
        }

        $contribuyente = $contribuyentes[$i % 11];
        $domicilio = "CALLE REVOLUCION #" . (200 + $i) . " COL CENTRO CP 44100";
        $concepto = $conceptos[$i % 10];

        // Monto entre 500 y 20000
        $monto = 500.00 + ($i * 350.50);
        if ($monto > 20000) $monto = 20000 - (($i % 15) * 200);

        // Fecha de emisión: últimos 180 días
        $fecha_emision = clone $hoy;
        $dias_atras = rand(1, 180);
        $fecha_emision->modify("-{$dias_atras} days");

        $estado = $estados[$i % 6];
        $observaciones = $observaciones_list[$i % 8];

        $stmt->execute([
            $folio,
            $clave_cuenta,
            $ejercicio,
            $contribuyente,
            $domicilio,
            $concepto,
            $monto,
            $fecha_emision->format('Y-m-d'),
            $estado,
            $observaciones
        ]);
    }
    echo "   ✓ 55 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Ejercicios: 2024 (15), 2023 (20), 2022 (20)\n";
    echo "   - Estados: PENDIENTE, NOTIFICADO, EN PROCESO, PAGADO, VENCIDO, CANCELADO\n";
    echo "   - Conceptos: 10 tipos diferentes de requerimientos\n";
    echo "   - Folios: REQ-" . date('Y') . "-00001 a REQ-" . date('Y') . "-00055\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_requerimientos_folio ON publico.requerimientos(folio)");
    $pdo->exec("CREATE INDEX idx_requerimientos_cuenta ON publico.requerimientos(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_requerimientos_contrib ON publico.requerimientos(contribuyente)");
    $pdo->exec("CREATE INDEX idx_requerimientos_fecha ON publico.requerimientos(fecha_emision DESC)");
    $pdo->exec("CREATE INDEX idx_requerimientos_ejercicio ON publico.requerimientos(ejercicio)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_listareq...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listareq(
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

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todos los requerimientos (búsqueda vacía)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Buscar por cuenta CTA-001005',
            'filtro' => 'CTA-001005'
        ],
        [
            'nombre' => 'Buscar por folio REQ-2025-00010',
            'filtro' => 'REQ-2025-00010'
        ],
        [
            'nombre' => 'Buscar por contribuyente MARIA',
            'filtro' => 'MARIA'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listareq(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " requerimiento(s)\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - Folio: " . $row['folio'] .
                     " | Cuenta: " . $row['clave_cuenta'] .
                     " | Ejercicio: " . $row['ejercicio'] .
                     " | " . $row['contribuyente'] .
                     " | Concepto: " . $row['concepto'] .
                     " | Monto: $" . number_format($row['monto'], 2) .
                     " | Estado: " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla requerimientos creada con 55 registros\n";
    echo "   - Ejercicios: 2024 (15), 2023 (20), 2022 (20)\n";
    echo "   - Estados: PENDIENTE, NOTIFICADO, EN PROCESO, PAGADO, VENCIDO, CANCELADO\n";
    echo "   - Conceptos: Predial, Multas, Licencias, Agua, Construcción, Anuncios, etc.\n";
    echo "   - Montos desde $850 hasta $20,000\n";
    echo "   - SP recaudadora_listareq creado\n";
    echo "   - Búsqueda por: clave cuenta, folio, o contribuyente\n";
    echo "   - Búsqueda vacía retorna todos los registros\n";
    echo "   - Ordenado por fecha de emisión y folio descendente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
