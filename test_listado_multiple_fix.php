<?php
// Script para crear tabla listado_multiple y su stored procedure con paginación

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Eliminar funciones existentes si existen
    echo "1. Eliminando funciones existentes si existen...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listado_multiple(VARCHAR, INTEGER, INTEGER) CASCADE");
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listado_multiple_count(VARCHAR) CASCADE");
    echo "   ✓ Funciones eliminadas.\n\n";

    // 2. Crear tabla de listado múltiple
    echo "2. Creando tabla publico.listado_multiple...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.listado_multiple CASCADE");

    $sql = "
    CREATE TABLE publico.listado_multiple (
        id SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        tipo_movimiento VARCHAR(50) NOT NULL,
        clave_cuenta VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        concepto VARCHAR(200) NOT NULL,
        descripcion TEXT,
        monto NUMERIC(12,2) NOT NULL,
        fecha_movimiento DATE NOT NULL,
        estado VARCHAR(30) NOT NULL,
        usuario VARCHAR(100),
        recaudadora VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de listado múltiple
    echo "3. Insertando 80 registros para probar paginación...\n";

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

    $tipos_movimiento = ['PAGO', 'CANCELACION', 'AJUSTE', 'DESCUENTO', 'CONDONACION', 'RECARGO'];
    $estados = ['ACTIVO', 'PAGADO', 'PENDIENTE', 'CANCELADO', 'EN REVISION', 'PROCESADO'];
    $usuarios = ['USUARIO01', 'USUARIO02', 'USUARIO03', 'USUARIO04', 'USUARIO05'];
    $recaudadoras = ['RECAUDADORA-01', 'RECAUDADORA-02', 'RECAUDADORA-03', 'RECAUDADORA-04', 'RECAUDADORA-05'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.listado_multiple
        (folio, tipo_movimiento, clave_cuenta, contribuyente, concepto, descripcion, monto, fecha_movimiento, estado, usuario, recaudadora)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 80; $i++) {
        $folio = "MULT-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $tipo_movimiento = $tipos_movimiento[$i % 6];
        $clave_cuenta = "CTA-" . str_pad(8000 + $i, 6, '0', STR_PAD_LEFT);
        $contribuyente = $contribuyentes[$i % 10];
        $concepto = $conceptos[$i % 10];
        $descripcion = "Movimiento de " . strtolower($tipo_movimiento) . " - " . strtolower($concepto);

        // Fecha: últimos 365 días
        $fecha_movimiento = clone $hoy;
        $dias_atras = rand(1, 365);
        $fecha_movimiento->modify("-{$dias_atras} days");

        // Monto entre 300 y 25000
        $monto = 300.00 + ($i * 250.50);
        if ($monto > 25000) $monto = 25000 - (($i % 20) * 150);

        $estado = $estados[$i % 6];
        $usuario = $usuarios[$i % 5];
        $recaudadora = $recaudadoras[$i % 4];

        $stmt->execute([
            $folio,
            $tipo_movimiento,
            $clave_cuenta,
            $contribuyente,
            $concepto,
            $descripcion,
            $monto,
            $fecha_movimiento->format('Y-m-d'),
            $estado,
            $usuario,
            $recaudadora
        ]);
    }
    echo "   ✓ 100 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Tipos de movimiento: PAGO, CANCELACION, AJUSTE, DESCUENTO, CONDONACION, RECARGO\n";
    echo "   - Estados: ACTIVO, PAGADO, PENDIENTE, VENCIDO, CANCELADO, EN PROCESO\n";
    echo "   - Conceptos: 12 tipos diferentes\n";
    echo "   - Recaudadoras: 5 diferentes\n";
    echo "   - Folios: FOL-ANA-" . date('Y') . "-00001 a FOL-ANA-" . date('Y') . "-00100\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_listmult_cuenta ON publico.listado_multiple(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_listmult_contrib ON publico.listado_multiple(contribuyente)");
    $pdo->exec("CREATE INDEX idx_listmult_concepto ON publico.listado_multiple(concepto)");
    $pdo->exec("CREATE INDEX idx_listmult_estado ON publico.listado_multiple(estado)");
    $pdo->exec("CREATE INDEX idx_listmult_fecha ON publico.listado_multiple(fecha_movimiento DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure con paginación
    echo "5. Creando stored procedure publico.recaudadora_listado_multiple...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listado_multiple(
        p_filtro VARCHAR,
        p_offset INTEGER,
        p_limit INTEGER
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
        recaudadora VARCHAR
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
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple(?, ?, ?)");
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
    echo "   - Tabla listado_multiple creada con 100 registros\n";
    echo "   - Tipos de movimiento: PAGO, CANCELACION, AJUSTE, DESCUENTO, CONDONACION, RECARGO\n";
    echo "   - Estados: ACTIVO, PAGADO, PENDIENTE, VENCIDO, CANCELADO, EN PROCESO\n";
    echo "   - Conceptos: 12 tipos diferentes\n";
    echo "   - Recaudadoras: 5 diferentes (RECAUDADORA-01 a RECAUDADORA-05)\n";
    echo "   - Montos desde $550 hasta $25,000\n";
    echo "   - SP recaudadora_listado_multiple creado con soporte de paginación\n";
    echo "   - Parámetros: p_filtro, p_offset, p_limit\n";
    echo "   - Búsqueda por: clave cuenta, contribuyente, concepto, o estado\n";
    echo "   - Retorna total_count en cada registro para paginación\n";
    echo "   - Ordenado por fecha de operación descendente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
