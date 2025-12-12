<?php
// Script para crear recaudadora_pagos_espe con más registros

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_pagos_espe(VARCHAR, INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de pagos especiales
    echo "2. Recreando tabla publico.pagos_especiales...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.pagos_especiales CASCADE");

    $sql = "
    CREATE TABLE publico.pagos_especiales (
        id_autorizacion SERIAL PRIMARY KEY,
        cveaut VARCHAR(50) NOT NULL,
        cvecuenta VARCHAR(50) NOT NULL,
        bimestre_inicio INTEGER NOT NULL,
        año_inicio INTEGER NOT NULL,
        bimestre_fin INTEGER NOT NULL,
        año_fin INTEGER NOT NULL,
        fecha_autorizacion DATE NOT NULL,
        autorizado_por VARCHAR(100) NOT NULL,
        cve_pago VARCHAR(50),
        estado VARCHAR(20) NOT NULL,
        monto_autorizado NUMERIC(12,2),
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 70 registros de pagos especiales
    echo "3. Insertando 70 registros de autorizaciones de pagos especiales...\n";

    $autorizadores = [
        'DIRECTOR DE FINANZAS',
        'SUBDIRECTOR DE INGRESOS',
        'TESORERO MUNICIPAL',
        'COORDINADOR DE RECAUDACION',
        'JEFE DE DEPARTAMENTO'
    ];

    $estados = ['PENDIENTE', 'PAGADO', 'CANCELADO'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.pagos_especiales
        (cveaut, cvecuenta, bimestre_inicio, año_inicio, bimestre_fin, año_fin,
         fecha_autorizacion, autorizado_por, cve_pago, estado, monto_autorizado, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    // Generar fechas recientes (últimos 100 días)
    $hoy = new DateTime();

    for ($i = 1; $i <= 70; $i++) {
        // Generar cuentas agrupadas por ejercicio
        if ($i <= 25) {
            $cuenta = "PESP-CTA-" . str_pad($i, 3, '0', STR_PAD_LEFT);
            $año_inicio = 2024;
            $año_fin = 2024;
        } elseif ($i <= 50) {
            $cuenta = "PESP-CTA-" . str_pad($i - 25, 3, '0', STR_PAD_LEFT);
            $año_inicio = 2023;
            $año_fin = 2023;
        } else {
            $cuenta = "PESP-CTA-" . str_pad($i - 50, 3, '0', STR_PAD_LEFT);
            $año_inicio = 2022;
            $año_fin = 2022;
        }

        $cveaut = "AUT-PE-" . $año_inicio . "-" . str_pad($i, 4, '0', STR_PAD_LEFT);

        // Bimestres del 1 al 6
        $bimestre_inicio = (($i - 1) % 6) + 1;
        $bimestre_fin = min($bimestre_inicio + 1, 6);

        // Si el bimestre fin es menor que el inicio, ajustar el año fin
        if ($bimestre_fin < $bimestre_inicio) {
            $año_fin = $año_inicio + 1;
        }

        // Fecha de autorización: restando días desde hoy
        $fecha_autorizacion = clone $hoy;
        $fecha_autorizacion->modify("-" . ($i * 1) . " days");

        $autorizado_por = $autorizadores[$i % 5];

        // Estado distribuido
        $estado = $estados[$i % 3];

        // CVE Pago solo para pagados
        $cve_pago = ($estado === 'PAGADO') ? "PGO-" . str_pad($i * 100, 8, '0', STR_PAD_LEFT) : null;

        $monto_autorizado = 5000.00 + ($i * 150.75);

        $observaciones_list = [
            'Autorización para convenio de pago especial',
            'Solicitado por contribuyente con situación económica especial',
            'Aprobado por dirección para pago en parcialidades',
            null,
            'Requiere seguimiento mensual de pagos'
        ];
        $observaciones = $observaciones_list[$i % 5];

        $stmt->execute([
            $cveaut,
            $cuenta,
            $bimestre_inicio,
            $año_inicio,
            $bimestre_fin,
            $año_fin,
            $fecha_autorizacion->format('Y-m-d'),
            $autorizado_por,
            $cve_pago,
            $estado,
            $monto_autorizado,
            $observaciones
        ]);
    }
    echo "   ✓ 70 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Año 2024: 25 registros\n";
    echo "   - Año 2023: 25 registros\n";
    echo "   - Año 2022: 20 registros\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_pagos_espe_cuenta ON publico.pagos_especiales(cvecuenta)");
    $pdo->exec("CREATE INDEX idx_pagos_espe_año_inicio ON publico.pagos_especiales(año_inicio)");
    $pdo->exec("CREATE INDEX idx_pagos_espe_cveaut ON publico.pagos_especiales(cveaut)");
    $pdo->exec("CREATE INDEX idx_pagos_espe_fecha ON publico.pagos_especiales(fecha_autorizacion DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_pagos_espe...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_pagos_espe(
        p_clave_cuenta VARCHAR,
        p_ejercicio INTEGER
    )
    RETURNS TABLE (
        cveaut VARCHAR,
        cvecuenta VARCHAR,
        bimestre_inicio INTEGER,
        año_inicio INTEGER,
        bimestre_fin INTEGER,
        año_fin INTEGER,
        fecha_autorizacion DATE,
        autorizado_por VARCHAR,
        cve_pago VARCHAR,
        estado VARCHAR,
        monto_autorizado NUMERIC,
        observaciones TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            p.cveaut,
            p.cvecuenta,
            p.bimestre_inicio,
            p.año_inicio,
            p.bimestre_fin,
            p.año_fin,
            p.fecha_autorizacion,
            p.autorizado_por,
            p.cve_pago,
            p.estado,
            p.monto_autorizado,
            p.observaciones
        FROM publico.pagos_especiales p
        WHERE
            (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR p.cvecuenta ILIKE '%' || p_clave_cuenta || '%')
            AND (p_ejercicio IS NULL OR p.año_inicio = p_ejercicio OR p.año_fin = p_ejercicio)
        ORDER BY p.fecha_autorizacion DESC, p.id_autorizacion DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todos los pagos especiales del año 2024',
            'cuenta' => '',
            'ejercicio' => 2024
        ],
        [
            'nombre' => 'Todos los pagos especiales del año 2023',
            'cuenta' => '',
            'ejercicio' => 2023
        ],
        [
            'nombre' => 'Cuenta específica PESP-CTA-005 en 2024',
            'cuenta' => 'PESP-CTA-005',
            'ejercicio' => 2024
        ],
        [
            'nombre' => 'Todos los registros (sin filtros)',
            'cuenta' => '',
            'ejercicio' => null
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagos_espe(?, ?)");
        $stmt->execute([$test['cuenta'], $test['ejercicio']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " registros\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - CVE Aut: " . $row['cveaut'] .
                     " - Cuenta: " . $row['cvecuenta'] .
                     " - Período: Bim " . $row['bimestre_inicio'] . "/" . $row['año_inicio'] .
                     " a Bim " . $row['bimestre_fin'] . "/" . $row['año_fin'] .
                     " - Estado: " . $row['estado'] .
                     " - Monto: $" . number_format($row['monto_autorizado'], 2) . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla pagos_especiales recreada con 70 registros\n";
    echo "   - Autorizaciones de pagos especiales por bimestre\n";
    echo "   - Filtro por cuenta y ejercicio (año)\n";
    echo "   - Estados: PENDIENTE, PAGADO, CANCELADO\n";
    echo "   - CVE de pago solo para autorizaciones pagadas\n";
    echo "   - Paginación client-side (10 registros por página en el frontend)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
