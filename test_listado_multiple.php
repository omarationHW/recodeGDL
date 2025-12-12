<?php
// Script para crear los SPs listado_multiple y listado_multiple_count

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear tabla para listado múltiple si no existe
    echo "1. Creando tabla publico.listado_multiple...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.listado_multiple CASCADE");

    $sql = "
    CREATE TABLE publico.listado_multiple (
        id SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        tipo_movimiento VARCHAR(50) NOT NULL,
        clave_cuenta VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        concepto VARCHAR(100) NOT NULL,
        descripcion TEXT,
        monto NUMERIC(12,2) NOT NULL,
        fecha_movimiento DATE NOT NULL,
        estado VARCHAR(20) NOT NULL,
        usuario VARCHAR(50),
        recaudadora INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 2. Crear índices para mejorar performance en búsquedas
    echo "2. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_listado_multiple_folio ON publico.listado_multiple(folio)");
    $pdo->exec("CREATE INDEX idx_listado_multiple_cuenta ON publico.listado_multiple(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_listado_multiple_contribuyente ON publico.listado_multiple(contribuyente)");
    $pdo->exec("CREATE INDEX idx_listado_multiple_fecha ON publico.listado_multiple(fecha_movimiento)");
    echo "   ✓ Índices creados.\n\n";

    // 3. Insertar datos de prueba (120 registros para probar paginación)
    echo "3. Insertando 120 registros de prueba...\n";

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
        'Pago Predial',
        'Pago Agua',
        'Licencia Comercial',
        'Multa Tránsito',
        'Derechos Construcción',
        'Certificación',
        'Devolución',
        'Ajuste de Cuenta'
    ];

    $tipos_mov = [
        'PAGO',
        'CARGO',
        'DESCUENTO',
        'CONDONACIÓN',
        'CANCELACIÓN',
        'AJUSTE'
    ];

    $estados = ['APLICADO', 'PENDIENTE', 'CANCELADO', 'PROCESADO'];
    $usuarios = ['ADMIN01', 'CAJERO01', 'CAJERO02', 'SUPERVISOR01'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.listado_multiple
        (folio, tipo_movimiento, clave_cuenta, contribuyente, concepto, descripcion,
         monto, fecha_movimiento, estado, usuario, recaudadora)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 120; $i++) {
        $year = 2024;
        $folio = "MUL-{$year}-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $tipo = $tipos_mov[$i % 6];
        $cuenta = "CTA-" . str_pad(($i % 20) + 1, 5, '0', STR_PAD_LEFT);
        $contribuyente = $contribuyentes[$i % 12];
        $concepto = $conceptos[$i % 8];
        $descripcion = "Movimiento múltiple: {$tipo} - {$concepto} para cuenta {$cuenta}";
        $monto = 500.00 + ($i * 37.50);
        $fecha = date('Y-m-d', strtotime("2024-01-01 +{$i} days"));
        $estado = $estados[$i % 4];
        $usuario = $usuarios[$i % 4];
        $recaudadora = (($i - 1) % 5) + 1; // 1-5

        $stmt->execute([
            $folio,
            $tipo,
            $cuenta,
            $contribuyente,
            $concepto,
            $descripcion,
            $monto,
            $fecha,
            $estado,
            $usuario,
            $recaudadora
        ]);
    }
    echo "   ✓ 120 registros insertados.\n\n";

    // 4. Crear el stored procedure para obtener datos paginados
    echo "4. Creando stored procedure publico.recaudadora_listado_multiple...\n";
    $sql = "
    CREATE OR REPLACE FUNCTION publico.recaudadora_listado_multiple(
        p_filtro VARCHAR,
        p_limit INTEGER,
        p_offset INTEGER
    )
    RETURNS TABLE (
        id INTEGER,
        folio VARCHAR,
        tipo_movimiento VARCHAR,
        clave_cuenta VARCHAR,
        contribuyente VARCHAR,
        concepto VARCHAR,
        descripcion TEXT,
        monto NUMERIC,
        fecha_movimiento DATE,
        estado VARCHAR,
        usuario VARCHAR,
        recaudadora INTEGER
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            l.id,
            l.folio,
            l.tipo_movimiento,
            l.clave_cuenta,
            l.contribuyente,
            l.concepto,
            l.descripcion,
            l.monto,
            l.fecha_movimiento,
            l.estado,
            l.usuario,
            l.recaudadora
        FROM publico.listado_multiple l
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    l.folio ILIKE '%' || p_filtro || '%'
                    OR l.clave_cuenta ILIKE '%' || p_filtro || '%'
                    OR l.contribuyente ILIKE '%' || p_filtro || '%'
                    OR l.concepto ILIKE '%' || p_filtro || '%'
                    OR l.tipo_movimiento ILIKE '%' || p_filtro || '%'
                    OR l.estado ILIKE '%' || p_filtro || '%'
                )
            END
        ORDER BY l.fecha_movimiento DESC, l.id DESC
        LIMIT p_limit
        OFFSET p_offset;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure recaudadora_listado_multiple creado.\n\n";

    // 5. Crear el stored procedure para obtener el conteo
    echo "5. Creando stored procedure publico.recaudadora_listado_multiple_count...\n";
    $sql = "
    CREATE OR REPLACE FUNCTION publico.recaudadora_listado_multiple_count(
        p_filtro VARCHAR
    )
    RETURNS TABLE (
        total BIGINT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT COUNT(*)::BIGINT
        FROM publico.listado_multiple l
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    l.folio ILIKE '%' || p_filtro || '%'
                    OR l.clave_cuenta ILIKE '%' || p_filtro || '%'
                    OR l.contribuyente ILIKE '%' || p_filtro || '%'
                    OR l.concepto ILIKE '%' || p_filtro || '%'
                    OR l.tipo_movimiento ILIKE '%' || p_filtro || '%'
                    OR l.estado ILIKE '%' || p_filtro || '%'
                )
            END;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure recaudadora_listado_multiple_count creado.\n\n";

    // 6. Probar los SPs con varios ejemplos
    echo "6. Probando los stored procedures:\n\n";

    $tests = [
        [
            'nombre' => 'Primera página sin filtro (10 registros)',
            'filtro' => '',
            'limit' => 10,
            'offset' => 0
        ],
        [
            'nombre' => 'Segunda página sin filtro (10 registros, offset 10)',
            'filtro' => '',
            'limit' => 10,
            'offset' => 10
        ],
        [
            'nombre' => 'Filtrar por tipo PAGO (primera página, 10 registros)',
            'filtro' => 'PAGO',
            'limit' => 10,
            'offset' => 0
        ],
        [
            'nombre' => 'Filtrar por contribuyente MARIA (primera página)',
            'filtro' => 'MARIA',
            'limit' => 10,
            'offset' => 0
        ],
        [
            'nombre' => 'Filtrar por estado APLICADO (primera página)',
            'filtro' => 'APLICADO',
            'limit' => 10,
            'offset' => 0
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";

        // Obtener el conteo
        $stmt_count = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple_count(?)");
        $stmt_count->execute([$test['filtro']]);
        $count_result = $stmt_count->fetch(PDO::FETCH_ASSOC);
        $total = $count_result['total'];
        echo "   Total de registros que coinciden: {$total}\n";

        // Obtener los datos
        $stmt_data = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?, ?, ?)");
        $stmt_data->execute([$test['filtro'], $test['limit'], $test['offset']]);
        $rows = $stmt_data->fetchAll(PDO::FETCH_ASSOC);
        echo "   Registros devueltos en esta página: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "   Primeros 2 registros:\n";
            foreach (array_slice($rows, 0, 2) as $row) {
                echo "      - " . $row['folio'] .
                     " - " . $row['tipo_movimiento'] .
                     " - " . $row['contribuyente'] .
                     " - " . $row['concepto'] .
                     " - $" . number_format($row['monto'], 2) .
                     " - " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 NOTA: Se crearon 2 stored procedures:\n";
    echo "   1. recaudadora_listado_multiple - Obtiene los datos paginados\n";
    echo "   2. recaudadora_listado_multiple_count - Obtiene el total de registros\n";
    echo "   - Ambos SPs filtran por folio, cuenta, contribuyente, concepto, tipo y estado\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
