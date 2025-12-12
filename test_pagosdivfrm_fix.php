<?php
// Script para crear pagosdivfrm con más registros

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_pagosdivfrm(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de pagos diversos
    echo "2. Recreando tabla publico.pagos_diversos...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.pagos_diversos CASCADE");

    $sql = "
    CREATE TABLE publico.pagos_diversos (
        id_pago SERIAL PRIMARY KEY,
        clave_cuenta VARCHAR(50) NOT NULL,
        folio_pago VARCHAR(50) NOT NULL,
        fecha_pago DATE NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        concepto VARCHAR(200) NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        forma_pago VARCHAR(50) NOT NULL,
        referencia VARCHAR(100),
        cajero VARCHAR(100) NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 65 registros de pagos diversos
    echo "3. Insertando 65 registros de pagos diversos...\n";

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
        'MIGUEL ANGEL VAZQUEZ RUIZ',
        'PEDRO ANTONIO CASTRO REYES',
        'MARTHA ELIZABETH RAMOS SILVA'
    ];

    $conceptos = [
        'Derechos de Licencia de Construcción',
        'Permiso de Uso de Suelo',
        'Certificación Catastral',
        'Trámite de Alineamiento',
        'Expedición de Constancias',
        'Copias Certificadas',
        'Autorización de Publicidad',
        'Registro de Obra',
        'Dictamen de Protección Civil',
        'Licencia de Funcionamiento'
    ];

    $formas_pago = ['EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'CHEQUE'];
    $estados = ['PAGADO', 'CANCELADO', 'PENDIENTE'];
    $cajeros = ['CAJERO01', 'CAJERO02', 'CAJERO03', 'CAJERO04', 'ADMIN01'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.pagos_diversos
        (clave_cuenta, folio_pago, fecha_pago, contribuyente, domicilio, concepto, monto,
         forma_pago, referencia, cajero, estatus, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    // Generar fechas recientes (últimos 90 días)
    $hoy = new DateTime();

    for ($i = 1; $i <= 65; $i++) {
        // Generar cuentas agrupadas
        if ($i <= 20) {
            $cuenta = "PGDIV-CTA-001";
        } elseif ($i <= 38) {
            $cuenta = "PGDIV-CTA-002";
        } elseif ($i <= 52) {
            $cuenta = "PGDIV-CTA-003";
        } else {
            $cuenta = "PGDIV-CTA-004";
        }

        $folio = "PDIV-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);

        // Fecha de pago: restando días desde hoy
        $fecha_pago = clone $hoy;
        $fecha_pago->modify("-" . ($i * 1) . " days");

        $contribuyente = $contribuyentes[$i % 12];
        $domicilio = "CALLE MORELOS #" . (200 + $i) . " COL CENTRO CP 44100";
        $concepto = $conceptos[$i % 10];
        $monto = 500.00 + ($i * 75.50);
        $forma_pago = $formas_pago[$i % 4];

        // Generar referencia solo para algunos pagos
        $referencia = ($i % 3 == 0) ? "REF-" . str_pad($i * 100, 8, '0', STR_PAD_LEFT) : null;

        $cajero = $cajeros[$i % 5];
        $estatus = $estados[$i % 3];

        $observaciones_list = [
            'Pago recibido conforme',
            'Trámite urgente procesado',
            null,
            'Cliente solicitó factura electrónica',
            'Pago realizado por tercero'
        ];
        $observaciones = $observaciones_list[$i % 5];

        $stmt->execute([
            $cuenta,
            $folio,
            $fecha_pago->format('Y-m-d'),
            $contribuyente,
            $domicilio,
            $concepto,
            $monto,
            $forma_pago,
            $referencia,
            $cajero,
            $estatus,
            $observaciones
        ]);
    }
    echo "   ✓ 65 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - PGDIV-CTA-001: 20 registros\n";
    echo "   - PGDIV-CTA-002: 18 registros\n";
    echo "   - PGDIV-CTA-003: 14 registros\n";
    echo "   - PGDIV-CTA-004: 13 registros\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_pagos_div_cuenta ON publico.pagos_diversos(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_pagos_div_folio ON publico.pagos_diversos(folio_pago)");
    $pdo->exec("CREATE INDEX idx_pagos_div_fecha ON publico.pagos_diversos(fecha_pago DESC)");
    $pdo->exec("CREATE INDEX idx_pagos_div_contrib ON publico.pagos_diversos(contribuyente)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_pagosdivfrm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_pagosdivfrm(
        p_clave_cuenta VARCHAR
    )
    RETURNS TABLE (
        id_pago INTEGER,
        clave_cuenta VARCHAR,
        folio_pago VARCHAR,
        fecha_pago DATE,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        concepto VARCHAR,
        monto NUMERIC,
        forma_pago VARCHAR,
        referencia VARCHAR,
        cajero VARCHAR,
        estatus VARCHAR,
        observaciones TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            p.id_pago,
            p.clave_cuenta,
            p.folio_pago,
            p.fecha_pago,
            p.contribuyente,
            p.domicilio,
            p.concepto,
            p.monto,
            p.forma_pago,
            p.referencia,
            p.cajero,
            p.estatus,
            p.observaciones
        FROM publico.pagos_diversos p
        WHERE
            CASE
                WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
                ELSE (
                    p.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                    OR p.folio_pago ILIKE '%' || p_clave_cuenta || '%'
                    OR p.contribuyente ILIKE '%' || p_clave_cuenta || '%'
                )
            END
        ORDER BY p.fecha_pago DESC, p.id_pago DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Sin filtro (debe traer todos los 65 registros)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Filtrar por cuenta PGDIV-CTA-001 (debe traer 20 registros)',
            'filtro' => 'PGDIV-CTA-001'
        ],
        [
            'nombre' => 'Filtrar por cuenta PGDIV-CTA-003 (debe traer 14 registros)',
            'filtro' => 'PGDIV-CTA-003'
        ],
        [
            'nombre' => 'Filtrar por contribuyente MARIA',
            'filtro' => 'MARIA'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosdivfrm(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " registros\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - Folio: " . $row['folio_pago'] .
                     " - " . $row['contribuyente'] .
                     " - Concepto: " . $row['concepto'] .
                     " - Monto: $" . number_format($row['monto'], 2) .
                     " - " . $row['forma_pago'] .
                     " - Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla pagos_diversos recreada con 65 registros\n";
    echo "   - Campo vacío: trae TODOS los 65 registros\n";
    echo "   - Con valor: filtra por clave_cuenta, folio_pago o contribuyente\n";
    echo "   - Conceptos diversos: Licencias, Permisos, Certificaciones, Constancias, etc.\n";
    echo "   - Formas de pago: EFECTIVO, TARJETA, TRANSFERENCIA, CHEQUE\n";
    echo "   - Paginación client-side (10 registros por página en el frontend)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
