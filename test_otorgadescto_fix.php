<?php
// Script para crear otorga_descto con más registros y paginación server-side

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_otorga_descto(VARCHAR, INTEGER, INTEGER, INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de descuentos otorgados
    echo "2. Recreando tabla publico.descuentos_otorgados...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.descuentos_otorgados CASCADE");

    $sql = "
    CREATE TABLE publico.descuentos_otorgados (
        id_multa SERIAL PRIMARY KEY,
        clave_cuenta VARCHAR(50) NOT NULL,
        folio VARCHAR(50) NOT NULL,
        anio INTEGER NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        monto_multa NUMERIC(12,2) NOT NULL,
        tipo_descto VARCHAR(50) NOT NULL,
        porcentaje_descto NUMERIC(5,2) NOT NULL,
        importe_descto NUMERIC(12,2) NOT NULL,
        fecha_captura DATE NOT NULL,
        capturista VARCHAR(100) NOT NULL,
        autoriza VARCHAR(100) NOT NULL,
        estado VARCHAR(20) NOT NULL,
        observacion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 70 registros de descuentos otorgados
    echo "3. Insertando 70 registros de descuentos otorgados...\n";

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

    $tipos_descto = [
        'Descuento por Pronto Pago',
        'Descuento por Tercera Edad',
        'Descuento Especial',
        'Descuento por Discapacidad',
        'Condonación Parcial'
    ];

    $capturistas = ['CAJERO01', 'CAJERO02', 'CAJERO03', 'ADMIN01'];
    $autorizantes = ['SUPERVISOR01', 'SUPERVISOR02', 'DIRECTOR01', 'ADMIN02'];
    $estados = ['Vigente', 'Pagado', 'Cancelado'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.descuentos_otorgados
        (clave_cuenta, folio, anio, contribuyente, domicilio, monto_multa, tipo_descto,
         porcentaje_descto, importe_descto, fecha_captura, capturista, autoriza, estado, observacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 70; $i++) {
        // Generar cuentas agrupadas
        if ($i <= 25) {
            $cuenta = "DSCTO-CTA-001";
            $anio = 2024;
        } elseif ($i <= 45) {
            $cuenta = "DSCTO-CTA-002";
            $anio = 2024;
        } elseif ($i <= 60) {
            $cuenta = "DSCTO-CTA-003";
            $anio = 2023;
        } else {
            $cuenta = "DSCTO-CTA-004";
            $anio = 2023;
        }

        $folio = "DESC-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $contribuyente = $contribuyentes[$i % 10];
        $domicilio = "AV INDEPENDENCIA #" . (100 + $i) . " COL CENTRO";

        $monto_multa = 3000.00 + ($i * 150.00);
        $tipo_descto = $tipos_descto[$i % 5];

        // Porcentajes de descuento variados: 10%, 15%, 20%, 25%, 30%, 50%
        $porcentajes = [10, 15, 20, 25, 30, 50];
        $porcentaje = $porcentajes[$i % 6];
        $importe_descto = $monto_multa * ($porcentaje / 100);

        $fecha_captura = date('Y-m-d', strtotime("{$anio}-01-01 +{$i} days"));
        $capturista = $capturistas[$i % 4];
        $autoriza = $autorizantes[$i % 4];
        $estado = $estados[$i % 3];

        $observaciones = [
            'Descuento autorizado por cumplir requisitos',
            'Descuento aplicado según reglamento vigente',
            'Beneficio otorgado por pronto pago',
            null,
            'Autorización especial del director'
        ];
        $observacion = $observaciones[$i % 5];

        $stmt->execute([
            $cuenta,
            $folio,
            $anio,
            $contribuyente,
            $domicilio,
            $monto_multa,
            $tipo_descto,
            $porcentaje,
            $importe_descto,
            $fecha_captura,
            $capturista,
            $autoriza,
            $estado,
            $observacion
        ]);
    }
    echo "   ✓ 70 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - DSCTO-CTA-001 (2024): 25 registros\n";
    echo "   - DSCTO-CTA-002 (2024): 20 registros\n";
    echo "   - DSCTO-CTA-003 (2023): 15 registros\n";
    echo "   - DSCTO-CTA-004 (2023): 10 registros\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_desctos_cuenta ON publico.descuentos_otorgados(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_desctos_anio ON publico.descuentos_otorgados(anio)");
    $pdo->exec("CREATE INDEX idx_desctos_folio ON publico.descuentos_otorgados(folio)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure con paginación server-side
    echo "5. Creando stored procedure publico.recaudadora_otorga_descto...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_otorga_descto(
        p_clave_cuenta VARCHAR,
        p_ejercicio INTEGER,
        p_offset INTEGER,
        p_limit INTEGER
    )
    RETURNS TABLE (
        total_registros BIGINT,
        id_multa INTEGER,
        folio VARCHAR,
        anio INTEGER,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        monto_multa NUMERIC,
        tipo_descto VARCHAR,
        porcentaje_descto NUMERIC,
        importe_descto NUMERIC,
        fecha_captura DATE,
        capturista VARCHAR,
        autoriza VARCHAR,
        estado VARCHAR,
        observacion TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    DECLARE
        v_total_registros BIGINT;
    BEGIN
        -- Primero calcular el total de registros que coinciden
        SELECT COUNT(*)
        INTO v_total_registros
        FROM publico.descuentos_otorgados d
        WHERE
            (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR d.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
            AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR d.anio = p_ejercicio);

        -- Luego devolver los registros paginados con el total incluido
        RETURN QUERY
        SELECT
            v_total_registros,
            d.id_multa,
            d.folio,
            d.anio,
            d.contribuyente,
            d.domicilio,
            d.monto_multa,
            d.tipo_descto,
            d.porcentaje_descto,
            d.importe_descto,
            d.fecha_captura,
            d.capturista,
            d.autoriza,
            d.estado,
            d.observacion
        FROM publico.descuentos_otorgados d
        WHERE
            (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR d.clave_cuenta ILIKE '%' || p_clave_cuenta || '%')
            AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR d.anio = p_ejercicio)
        ORDER BY d.anio DESC, d.fecha_captura DESC, d.id_multa DESC
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
            'nombre' => 'Todos los descuentos del año 2024 (primera página)',
            'cuenta' => '',
            'ejercicio' => 2024,
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta DSCTO-CTA-001 en 2024 (debe tener 25 total)',
            'cuenta' => 'DSCTO-CTA-001',
            'ejercicio' => 2024,
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Cuenta DSCTO-CTA-003 en 2023 (debe tener 15 total)',
            'cuenta' => 'DSCTO-CTA-003',
            'ejercicio' => 2023,
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Todos los descuentos en 2023 (primera página)',
            'cuenta' => '',
            'ejercicio' => 2023,
            'offset' => 0,
            'limit' => 10
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto(?, ?, ?, ?)");
        $stmt->execute([$test['cuenta'], $test['ejercicio'], $test['offset'], $test['limit']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total = $rows[0]['total_registros'] ?? 0;
        echo "   Total de registros que coinciden: {$total}\n";
        echo "   Registros devueltos en esta página: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "   Primeros 2 registros:\n";
            foreach (array_slice($rows, 0, 2) as $row) {
                echo "      - Cuenta: " . $row['folio'] .
                     " - " . $row['contribuyente'] .
                     " - Tipo: " . $row['tipo_descto'] .
                     " - Descto: " . $row['porcentaje_descto'] . "%" .
                     " - $" . number_format($row['importe_descto'], 2) .
                     " - Estado: " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla descuentos_otorgados recreada con 70 registros\n";
    echo "   - Paginación server-side implementada (offset/limit)\n";
    echo "   - Campo total_registros incluido en cada fila\n";
    echo "   - Filtro por cuenta y ejercicio (año)\n";
    echo "   - Tipos de descuento variados: Pronto Pago, Tercera Edad, Especial, Discapacidad, Condonación\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
