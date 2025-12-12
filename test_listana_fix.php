<?php
// Script para crear tabla listado_analitico y su stored procedure con paginación

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listana(VARCHAR, INTEGER, INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de listado analítico
    echo "2. Creando tabla publico.listado_analitico...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.listado_analitico CASCADE");

    $sql = "
    CREATE TABLE publico.listado_analitico (
        id_registro SERIAL PRIMARY KEY,
        clave_cuenta VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        concepto VARCHAR(200) NOT NULL,
        folio VARCHAR(50) NOT NULL,
        fecha_operacion DATE NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        estado VARCHAR(30) NOT NULL,
        ejercicio INTEGER NOT NULL,
        recaudadora VARCHAR(50),
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de listado analítico
    echo "3. Insertando 100 registros para probar paginación...\n";

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
        'CARMEN ROSA LOPEZ FERNANDEZ'
    ];

    $conceptos = [
        'PAGO DE IMPUESTO PREDIAL',
        'PAGO DE MULTA DE TRANSITO',
        'LICENCIA DE FUNCIONAMIENTO',
        'DERECHOS DE AGUA',
        'DERECHOS DE CONSTRUCCION',
        'LICENCIA DE ANUNCIO',
        'IMPUESTO PREDIAL COMPLEMENTARIO',
        'DERECHOS POR USO DE SUELO',
        'SERVICIO DE LIMPIA',
        'DERECHOS DE MERCADO',
        'PAGO DE ESTACIONAMIENTO',
        'LICENCIA ALCOHOLES'
    ];

    $estados = ['ACTIVO', 'PAGADO', 'PENDIENTE', 'VENCIDO', 'CANCELADO', 'EN PROCESO'];
    $recaudadoras = ['RECAUDADORA-01', 'RECAUDADORA-02', 'RECAUDADORA-03', 'RECAUDADORA-04', 'RECAUDADORA-05'];

    $observaciones_list = [
        'Pago realizado en ventanilla',
        'Pago con descuento por pronto pago',
        'Pagado mediante convenio',
        'Requiere seguimiento',
        null,
        'Contribuyente moroso',
        'Actualización catastral pendiente',
        'Verificar datos del contribuyente'
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.listado_analitico
        (clave_cuenta, contribuyente, concepto, folio, fecha_operacion, monto, estado, ejercicio, recaudadora, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 100; $i++) {
        $clave_cuenta = "CTA-" . str_pad(5000 + $i, 6, '0', STR_PAD_LEFT);
        $contribuyente = $contribuyentes[$i % 10];
        $concepto = $conceptos[$i % 12];
        $folio = "FOL-ANA-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);

        // Fecha: últimos 365 días
        $fecha_operacion = clone $hoy;
        $dias_atras = rand(1, 365);
        $fecha_operacion->modify("-{$dias_atras} days");

        // Monto entre 300 y 25000
        $monto = 300.00 + ($i * 250.50);
        if ($monto > 25000) $monto = 25000 - (($i % 20) * 150);

        $estado = $estados[$i % 6];

        // Ejercicio basado en la fecha
        $ejercicio = ($i <= 35) ? 2024 : (($i <= 70) ? 2023 : 2022);

        $recaudadora = $recaudadoras[$i % 5];
        $observaciones = $observaciones_list[$i % 8];

        $stmt->execute([
            $clave_cuenta,
            $contribuyente,
            $concepto,
            $folio,
            $fecha_operacion->format('Y-m-d'),
            $monto,
            $estado,
            $ejercicio,
            $recaudadora,
            $observaciones
        ]);
    }
    echo "   ✓ 100 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Ejercicios: 2024 (35), 2023 (35), 2022 (30)\n";
    echo "   - Estados: ACTIVO, PAGADO, PENDIENTE, VENCIDO, CANCELADO, EN PROCESO\n";
    echo "   - Conceptos: 12 tipos diferentes\n";
    echo "   - Recaudadoras: 5 diferentes\n";
    echo "   - Folios: FOL-ANA-" . date('Y') . "-00001 a FOL-ANA-" . date('Y') . "-00100\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_listana_cuenta ON publico.listado_analitico(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_listana_contrib ON publico.listado_analitico(contribuyente)");
    $pdo->exec("CREATE INDEX idx_listana_concepto ON publico.listado_analitico(concepto)");
    $pdo->exec("CREATE INDEX idx_listana_estado ON publico.listado_analitico(estado)");
    $pdo->exec("CREATE INDEX idx_listana_fecha ON publico.listado_analitico(fecha_operacion DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure con paginación
    echo "5. Creando stored procedure publico.recaudadora_listana...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listana(
        p_filtro VARCHAR,
        p_offset INTEGER,
        p_limit INTEGER
    )
    RETURNS TABLE (
        clave_cuenta VARCHAR,
        contribuyente VARCHAR,
        concepto VARCHAR,
        folio VARCHAR,
        fecha_operacion DATE,
        monto NUMERIC,
        estado VARCHAR,
        ejercicio INTEGER,
        recaudadora VARCHAR,
        observaciones TEXT,
        total_count BIGINT
    )
    LANGUAGE plpgsql
    AS \$\$
    DECLARE
        v_total_count BIGINT;
    BEGIN
        -- Primero calculamos el total de registros que cumplen el filtro
        SELECT COUNT(*)
        INTO v_total_count
        FROM publico.listado_analitico l
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    l.clave_cuenta ILIKE '%' || p_filtro || '%'
                    OR l.contribuyente ILIKE '%' || p_filtro || '%'
                    OR l.concepto ILIKE '%' || p_filtro || '%'
                    OR l.estado ILIKE '%' || p_filtro || '%'
                )
            END;

        -- Retornamos los registros paginados con el total_count
        RETURN QUERY
        SELECT
            l.clave_cuenta,
            l.contribuyente,
            l.concepto,
            l.folio,
            l.fecha_operacion,
            l.monto,
            l.estado,
            l.ejercicio,
            l.recaudadora,
            l.observaciones,
            v_total_count AS total_count
        FROM publico.listado_analitico l
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    l.clave_cuenta ILIKE '%' || p_filtro || '%'
                    OR l.contribuyente ILIKE '%' || p_filtro || '%'
                    OR l.concepto ILIKE '%' || p_filtro || '%'
                    OR l.estado ILIKE '%' || p_filtro || '%'
                )
            END
        ORDER BY l.fecha_operacion DESC, l.id_registro DESC
        LIMIT p_limit
        OFFSET p_offset;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos de paginación
    echo "6. Probando el stored procedure con paginación:\n\n";

    $tests = [
        [
            'nombre' => 'Primera página (10 registros, sin filtro)',
            'filtro' => '',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Segunda página (10 registros, sin filtro)',
            'filtro' => '',
            'offset' => 10,
            'limit' => 10
        ],
        [
            'nombre' => 'Filtrar por estado PAGADO (primera página)',
            'filtro' => 'PAGADO',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Filtrar por contribuyente MARIA (primera página)',
            'filtro' => 'MARIA',
            'offset' => 0,
            'limit' => 10
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listana(?, ?, ?)");
        $stmt->execute([$test['filtro'], $test['offset'], $test['limit']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_count = count($rows) > 0 ? $rows[0]['total_count'] : 0;
        echo "   Resultados: " . count($rows) . " de " . $total_count . " total\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros de esta página:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - Cuenta: " . $row['clave_cuenta'] .
                     " | " . $row['contribuyente'] .
                     " | Concepto: " . $row['concepto'] .
                     " | Monto: $" . number_format($row['monto'], 2) .
                     " | Estado: " . $row['estado'] .
                     " | Ejercicio: " . $row['ejercicio'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla listado_analitico creada con 100 registros\n";
    echo "   - Ejercicios: 2024 (35), 2023 (35), 2022 (30)\n";
    echo "   - Estados: ACTIVO, PAGADO, PENDIENTE, VENCIDO, CANCELADO, EN PROCESO\n";
    echo "   - Conceptos: 12 tipos diferentes\n";
    echo "   - Recaudadoras: 5 diferentes (RECAUDADORA-01 a RECAUDADORA-05)\n";
    echo "   - Montos desde $550 hasta $25,000\n";
    echo "   - SP recaudadora_listana creado con soporte de paginación\n";
    echo "   - Parámetros: p_filtro, p_offset, p_limit\n";
    echo "   - Búsqueda por: clave cuenta, contribuyente, concepto, o estado\n";
    echo "   - Retorna total_count en cada registro para paginación\n";
    echo "   - Ordenado por fecha de operación descendente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
