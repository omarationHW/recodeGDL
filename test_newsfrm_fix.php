<?php
// Script para crear newsfrm con más registros y paginación server-side

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_newsfrm(VARCHAR, INTEGER, INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de novedades de multas
    echo "2. Recreando tabla publico.multas_novedades...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.multas_novedades CASCADE");

    $sql = "
    CREATE TABLE publico.multas_novedades (
        id_multa SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        anio INTEGER NOT NULL,
        fecha_acta DATE NOT NULL,
        fecha_recepcion DATE NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        total NUMERIC(12,2) NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 75 registros de novedades recientes
    echo "3. Insertando 75 registros de novedades de multas...\n";

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
        'MARTHA ELIZABETH RAMOS SILVA',
        'JORGE ALBERTO FLORES DOMINGUEZ',
        'SILVIA CRISTINA MORENO GUTIERREZ',
        'RICARDO DAVID AGUILAR VARGAS'
    ];

    $estados = ['PENDIENTE', 'PAGADA', 'CANCELADA'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.multas_novedades
        (folio, anio, fecha_acta, fecha_recepcion, contribuyente, domicilio, total, estatus)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");

    // Generar fechas recientes (últimos 75 días)
    $hoy = new DateTime();

    for ($i = 1; $i <= 75; $i++) {
        $folio = "NOV-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $anio = 2024;

        // Fecha de acta: restando días desde hoy
        $fecha_acta = clone $hoy;
        $fecha_acta->modify("-{$i} days");

        // Fecha de recepción: 3-7 días después de la fecha de acta
        $fecha_recepcion = clone $fecha_acta;
        $fecha_recepcion->modify("+" . (3 + ($i % 5)) . " days");

        $contribuyente = $contribuyentes[$i % 15];
        $domicilio = "AV LOPEZ MATEOS #" . (100 + $i) . " COL AMERICANA CP 44160";
        $total = 2000.00 + ($i * 125.50);
        $estatus = $estados[$i % 3];

        $stmt->execute([
            $folio,
            $anio,
            $fecha_acta->format('Y-m-d'),
            $fecha_recepcion->format('Y-m-d'),
            $contribuyente,
            $domicilio,
            $total,
            $estatus
        ]);
    }
    echo "   ✓ 75 registros de novedades insertados.\n";
    echo "   - Novedades de los últimos 75 días\n";
    echo "   - Ordenadas de más reciente a más antigua\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_multas_nov_folio ON publico.multas_novedades(folio)");
    $pdo->exec("CREATE INDEX idx_multas_nov_contrib ON publico.multas_novedades(contribuyente)");
    $pdo->exec("CREATE INDEX idx_multas_nov_fecha_recep ON publico.multas_novedades(fecha_recepcion DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure con paginación server-side
    echo "5. Creando stored procedure publico.recaudadora_newsfrm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_newsfrm(
        p_filtro VARCHAR,
        p_offset INTEGER,
        p_limit INTEGER
    )
    RETURNS TABLE (
        total_registros BIGINT,
        id_multa INTEGER,
        folio VARCHAR,
        anio INTEGER,
        fecha_acta DATE,
        fecha_recepcion DATE,
        contribuyente VARCHAR,
        domicilio VARCHAR,
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
        FROM publico.multas_novedades m
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    m.folio ILIKE '%' || p_filtro || '%'
                    OR m.contribuyente ILIKE '%' || p_filtro || '%'
                    OR m.anio::TEXT ILIKE '%' || p_filtro || '%'
                )
            END;

        -- Luego devolver los registros paginados con el total incluido
        -- Ordenados por fecha de recepción más reciente primero
        RETURN QUERY
        SELECT
            v_total_registros,
            m.id_multa,
            m.folio,
            m.anio,
            m.fecha_acta,
            m.fecha_recepcion,
            m.contribuyente,
            m.domicilio,
            m.total,
            m.estatus
        FROM publico.multas_novedades m
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    m.folio ILIKE '%' || p_filtro || '%'
                    OR m.contribuyente ILIKE '%' || p_filtro || '%'
                    OR m.anio::TEXT ILIKE '%' || p_filtro || '%'
                )
            END
        ORDER BY m.fecha_recepcion DESC, m.id_multa DESC
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
            'nombre' => 'Primera página sin filtro (10 registros de 75 total)',
            'filtro' => '',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Filtrar por contribuyente MARIA',
            'filtro' => 'MARIA',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Filtrar por año 2024',
            'filtro' => '2024',
            'offset' => 0,
            'limit' => 10
        ],
        [
            'nombre' => 'Filtrar por folio NOV-2024-00015',
            'filtro' => 'NOV-2024-00015',
            'offset' => 0,
            'limit' => 10
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm(?, ?, ?)");
        $stmt->execute([$test['filtro'], $test['offset'], $test['limit']]);
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
                     " - Recepción: " . $row['fecha_recepcion'] .
                     " - Total: $" . number_format($row['total'], 2) .
                     " - Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla multas_novedades recreada con 75 registros\n";
    echo "   - Novedades de los últimos 75 días\n";
    echo "   - Paginación server-side implementada (offset/limit)\n";
    echo "   - Campo total_registros incluido en cada fila\n";
    echo "   - Ordenadas por fecha de recepción más reciente primero\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
