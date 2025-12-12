<?php
// Script para crear el SP listana con paginación server-side

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear tabla para listado analítico si no existe
    echo "1. Creando tabla publico.listado_analitico...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.listado_analitico CASCADE");

    $sql = "
    CREATE TABLE publico.listado_analitico (
        id SERIAL PRIMARY KEY,
        clave_cuenta VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        concepto VARCHAR(100) NOT NULL,
        ejercicio INTEGER NOT NULL,
        periodo VARCHAR(20),
        monto_original NUMERIC(12,2) NOT NULL,
        monto_recargos NUMERIC(12,2) DEFAULT 0,
        monto_descuento NUMERIC(12,2) DEFAULT 0,
        monto_total NUMERIC(12,2) NOT NULL,
        fecha_emision DATE NOT NULL,
        fecha_vencimiento DATE,
        estado VARCHAR(20) NOT NULL,
        recaudadora INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 2. Insertar datos de prueba (150 registros para probar paginación)
    echo "2. Insertando 150 registros de prueba...\n";

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

    $conceptos = [
        'Impuesto Predial',
        'Agua Potable',
        'Licencia Comercial',
        'Multa de Tránsito',
        'Derechos de Construcción',
        'Limpia y Recolección',
        'Alumbrado Público',
        'Drenaje y Alcantarillado'
    ];

    $estados = ['PENDIENTE', 'PAGADO', 'VENCIDO', 'CANCELADO'];
    $periodos = ['ENERO-FEBRERO', 'MARZO-ABRIL', 'MAYO-JUNIO', 'JULIO-AGOSTO', 'SEPT-OCT', 'NOV-DIC', 'ANUAL'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.listado_analitico
        (clave_cuenta, contribuyente, domicilio, concepto, ejercicio, periodo,
         monto_original, monto_recargos, monto_descuento, monto_total,
         fecha_emision, fecha_vencimiento, estado, recaudadora)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 150; $i++) {
        $cuenta = "ANA-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $contribuyente = $contribuyentes[$i % 15];
        $domicilio = "AV REVOLUCION #" . (100 + $i) . " COL CENTRO";
        $concepto = $conceptos[$i % 8];
        $ejercicio = 2024;
        $periodo = $periodos[$i % 7];

        $monto_original = 1000.00 + ($i * 25.00);
        $monto_recargos = $monto_original * 0.10; // 10% de recargos
        $monto_descuento = ($i % 3 == 0) ? $monto_original * 0.05 : 0; // 5% descuento cada 3
        $monto_total = $monto_original + $monto_recargos - $monto_descuento;

        $fecha_emision = date('Y-m-d', strtotime("2024-01-01 +{$i} days"));
        $fecha_venc = date('Y-m-d', strtotime($fecha_emision . " +30 days"));
        $estado = $estados[$i % 4];
        $recaudadora = (($i - 1) % 5) + 1; // 1-5

        $stmt->execute([
            $cuenta,
            $contribuyente,
            $domicilio,
            $concepto,
            $ejercicio,
            $periodo,
            $monto_original,
            $monto_recargos,
            $monto_descuento,
            $monto_total,
            $fecha_emision,
            $fecha_venc,
            $estado,
            $recaudadora
        ]);
    }
    echo "   ✓ 150 registros insertados.\n\n";

    // 3. Crear o reemplazar el stored procedure con paginación server-side
    echo "3. Creando stored procedure publico.recaudadora_listana...\n";
    $sql = "
    CREATE OR REPLACE FUNCTION publico.recaudadora_listana(
        p_filtro VARCHAR,
        p_offset INTEGER,
        p_limit INTEGER
    )
    RETURNS TABLE (
        total_count BIGINT,
        clave_cuenta VARCHAR,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        concepto VARCHAR,
        ejercicio INTEGER,
        periodo VARCHAR,
        monto_original NUMERIC,
        monto_recargos NUMERIC,
        monto_descuento NUMERIC,
        monto_total NUMERIC,
        fecha_emision DATE,
        fecha_vencimiento DATE,
        estado VARCHAR,
        recaudadora INTEGER
    )
    LANGUAGE plpgsql
    AS \$\$
    DECLARE
        v_total_count BIGINT;
    BEGIN
        -- Primero calcular el total de registros que coinciden con el filtro
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

        -- Luego devolver los registros paginados con el total_count incluido
        RETURN QUERY
        SELECT
            v_total_count,
            l.clave_cuenta,
            l.contribuyente,
            l.domicilio,
            l.concepto,
            l.ejercicio,
            l.periodo,
            l.monto_original,
            l.monto_recargos,
            l.monto_descuento,
            l.monto_total,
            l.fecha_emision,
            l.fecha_vencimiento,
            l.estado,
            l.recaudadora
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
        ORDER BY l.fecha_emision DESC, l.id DESC
        LIMIT p_limit
        OFFSET p_offset;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 4. Probar el SP con varios ejemplos
    echo "4. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Primera página sin filtro (10 registros)',
            'params' => ['', 0, 10]
        ],
        [
            'nombre' => 'Segunda página sin filtro (10 registros, offset 10)',
            'params' => ['', 10, 10]
        ],
        [
            'nombre' => 'Filtrar por Predial (primera página, 25 registros)',
            'params' => ['Predial', 0, 25]
        ],
        [
            'nombre' => 'Filtrar por MARIA (primera página, 10 registros)',
            'params' => ['MARIA', 0, 10]
        ],
        [
            'nombre' => 'Filtrar por estado PENDIENTE (50 registros)',
            'params' => ['PENDIENTE', 0, 50]
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listana(?, ?, ?)");
        $stmt->execute($test['params']);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $total_count = $rows[0]['total_count'] ?? 0;
        echo "   Total de registros que coinciden: {$total_count}\n";
        echo "   Registros devueltos en esta página: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "   Primeros 2 registros:\n";
            foreach (array_slice($rows, 0, 2) as $row) {
                echo "      - " . $row['clave_cuenta'] .
                     " - " . $row['contribuyente'] .
                     " - " . $row['concepto'] .
                     " - $" . number_format($row['monto_total'], 2) .
                     " - " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 NOTA: Paginación server-side implementada:\n";
    echo "   - El SP cuenta el total de registros que coinciden con el filtro\n";
    echo "   - Devuelve solo los registros de la página solicitada (OFFSET/LIMIT)\n";
    echo "   - Incluye total_count en cada fila para la paginación del frontend\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
