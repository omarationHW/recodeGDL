<?php
// Script para crear multasfrm con más registros

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_multasfrm(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de multas general
    echo "2. Recreando tabla publico.multas_general...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.multas_general CASCADE");

    $sql = "
    CREATE TABLE publico.multas_general (
        id_multa SERIAL PRIMARY KEY,
        folio VARCHAR(50) NOT NULL,
        anio INTEGER NOT NULL,
        fecha_acta DATE NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        giro VARCHAR(100),
        licencia VARCHAR(50),
        total NUMERIC(12,2) NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar 65 registros de prueba
    echo "3. Insertando 65 registros de multas generales...\n";

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
        'JORGE ALBERTO FLORES DOMINGUEZ'
    ];

    $giros = [
        'RESTAURANT',
        'TIENDA DE ABARROTES',
        'FARMACIA',
        'FERRETERIA',
        'PAPELERIA',
        'TALLER MECANICO',
        'SALON DE BELLEZA',
        'CAFE INTERNET',
        'PANADERIA',
        'CARNICERIA'
    ];

    $estados = ['PENDIENTE', 'PAGADA', 'CANCELADA'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.multas_general
        (folio, anio, fecha_acta, contribuyente, domicilio, giro, licencia, total, estatus)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 65; $i++) {
        $folio = "MUL-GEN-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $anio = ($i <= 40) ? 2024 : 2023;
        $fecha = date('Y-m-d', strtotime("{$anio}-01-01 +{$i} days"));
        $contribuyente = $contribuyentes[$i % 13];
        $domicilio = "CALLE REVOLUCION #" . (100 + $i) . " COL CENTRO CP 44100";
        $giro = $giros[$i % 10];
        $licencia = ($i % 3 == 0) ? "LIC-" . str_pad($i, 5, '0', STR_PAD_LEFT) : null;
        $total = 1800.00 + ($i * 95.75);
        $estatus = $estados[$i % 3];

        $stmt->execute([
            $folio,
            $anio,
            $fecha,
            $contribuyente,
            $domicilio,
            $giro,
            $licencia,
            $total,
            $estatus
        ]);
    }
    echo "   ✓ 65 registros insertados.\n";
    echo "   - Año 2024: 40 registros\n";
    echo "   - Año 2023: 25 registros\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_multas_gen_folio ON publico.multas_general(folio)");
    $pdo->exec("CREATE INDEX idx_multas_gen_contrib ON publico.multas_general(contribuyente)");
    $pdo->exec("CREATE INDEX idx_multas_gen_domicilio ON publico.multas_general(domicilio)");
    $pdo->exec("CREATE INDEX idx_multas_gen_giro ON publico.multas_general(giro)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_multasfrm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_multasfrm(
        p_filtro VARCHAR
    )
    RETURNS TABLE (
        id_multa INTEGER,
        folio VARCHAR,
        anio INTEGER,
        fecha_acta DATE,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        giro VARCHAR,
        licencia VARCHAR,
        total NUMERIC,
        estatus VARCHAR
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            m.id_multa,
            m.folio,
            m.anio,
            m.fecha_acta,
            m.contribuyente,
            m.domicilio,
            m.giro,
            m.licencia,
            m.total,
            m.estatus
        FROM publico.multas_general m
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    m.folio ILIKE '%' || p_filtro || '%'
                    OR m.contribuyente ILIKE '%' || p_filtro || '%'
                    OR m.domicilio ILIKE '%' || p_filtro || '%'
                    OR m.giro ILIKE '%' || p_filtro || '%'
                    OR m.licencia ILIKE '%' || p_filtro || '%'
                )
            END
        ORDER BY m.fecha_acta DESC, m.id_multa DESC;
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
            'nombre' => 'Filtrar por contribuyente MARIA',
            'filtro' => 'MARIA'
        ],
        [
            'nombre' => 'Filtrar por giro RESTAURANT',
            'filtro' => 'RESTAURANT'
        ],
        [
            'nombre' => 'Filtrar por domicilio REVOLUCION',
            'filtro' => 'REVOLUCION'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " registros\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - ID: " . $row['id_multa'] .
                     " - Folio: " . $row['folio'] .
                     " - " . $row['contribuyente'] .
                     " - Giro: " . $row['giro'] .
                     " - Total: $" . number_format($row['total'], 2) .
                     " - Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla multas_general recreada con 65 registros\n";
    echo "   - Campo vacío: trae TODOS los 65 registros\n";
    echo "   - Con valor: filtra por folio, contribuyente, domicilio, giro o licencia\n";
    echo "   - Paginación client-side (10 registros por página en el frontend)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
