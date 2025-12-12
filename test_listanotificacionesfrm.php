<?php
// Script para crear el SP listanotificacionesfrm y datos de prueba

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear tabla para notificaciones si no existe
    echo "1. Creando tabla publico.notificaciones_actas...\n";
    $sql = "
    CREATE TABLE IF NOT EXISTS publico.notificaciones_actas (
        id SERIAL PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        abrevia VARCHAR(50) NOT NULL,
        axo_acta INTEGER NOT NULL,
        num_acta INTEGER NOT NULL,
        num_lote INTEGER NOT NULL,
        folioreq INTEGER NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        total NUMERIC(12,2) NOT NULL,
        tipo_documento VARCHAR(1) NOT NULL, -- N=Notificación, R=Requerimiento, S=Secuestro
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada o ya existe.\n\n";

    // 2. Insertar datos de prueba (50 registros)
    echo "2. Insertando datos de prueba...\n";
    $pdo->exec("DELETE FROM publico.notificaciones_actas");

    $tipos = ['N', 'R', 'S'];
    $dependencias = [
        ['Catastro', 'CAT'],
        ['Ecología', 'ECO'],
        ['Comercio', 'COM'],
        ['Obras Públicas', 'OBR'],
        ['Hacienda', 'HAC']
    ];

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

    $stmt = $pdo->prepare("
        INSERT INTO publico.notificaciones_actas
        (recaudadora, abrevia, axo_acta, num_acta, num_lote, folioreq, contribuyente, domicilio, total, tipo_documento)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    for ($i = 1; $i <= 50; $i++) {
        $reca = (($i - 1) % 5) + 1; // 1-5
        $dep_idx = ($i - 1) % 5;
        $dep = $dependencias[$dep_idx];

        $axo = 2024;
        $num_acta = 1000 + $i;
        $num_lote = floor(($i - 1) / 10) + 1; // Lotes de 10
        $folioreq = 2000 + $i;
        $contribuyente = $contribuyentes[$i % 10];
        $domicilio = "AV PRINCIPAL #" . (100 + $i) . " COL CENTRO";
        $total = 1500.00 + ($i * 150.50);
        $tipo = $tipos[$i % 3];

        $stmt->execute([
            $reca,
            $dep[1],
            $axo,
            $num_acta,
            $num_lote,
            $folioreq,
            $contribuyente,
            $domicilio,
            $total,
            $tipo
        ]);
    }
    echo "   ✓ 50 registros insertados.\n\n";

    // 3. Crear o reemplazar el stored procedure
    echo "3. Creando stored procedure publico.recaudadora_listanotificacionesfrm...\n";
    $sql = "
    CREATE OR REPLACE FUNCTION publico.recaudadora_listanotificacionesfrm(
        p_reca INTEGER,
        p_axo INTEGER,
        p_inicio INTEGER,
        p_final INTEGER,
        p_tipo VARCHAR,
        p_orden VARCHAR
    )
    RETURNS TABLE (
        abrevia VARCHAR,
        axo_acta INTEGER,
        num_acta INTEGER,
        num_lote INTEGER,
        folioreq INTEGER,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        total NUMERIC
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            n.abrevia,
            n.axo_acta,
            n.num_acta,
            n.num_lote,
            n.folioreq,
            n.contribuyente,
            n.domicilio,
            n.total
        FROM publico.notificaciones_actas n
        WHERE n.recaudadora = p_reca
          AND n.axo_acta = p_axo
          AND n.folioreq BETWEEN p_inicio AND p_final
          AND n.tipo_documento = p_tipo
        ORDER BY
            CASE
                WHEN p_orden = 'lote' THEN n.num_lote::text
                WHEN p_orden = 'vigentes' THEN n.folioreq::text
                WHEN p_orden = 'dependencia' THEN n.abrevia || n.num_acta::text
                ELSE n.num_lote::text
            END;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 4. Probar el SP con varios ejemplos
    echo "4. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todas las notificaciones de recaudadora 1, año 2024, folios 2001-2010, tipo N, orden por lote',
            'params' => [1, 2024, 2001, 2010, 'N', 'lote']
        ],
        [
            'nombre' => 'Requerimientos de recaudadora 2, año 2024, folios 2005-2020, tipo R, orden por folio',
            'params' => [2, 2024, 2005, 2020, 'R', 'vigentes']
        ],
        [
            'nombre' => 'Todos los documentos tipo S, recaudadora 3, folios 2001-2050, orden por dependencia',
            'params' => [3, 2024, 2001, 2050, 'S', 'dependencia']
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listanotificacionesfrm(?, ?, ?, ?, ?, ?)");
        $stmt->execute($test['params']);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   Resultados: " . count($rows) . " registros\n";
        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - " . $row['abrevia'] . " " . $row['axo_acta'] . "/" . $row['num_acta'] .
                     " - Lote: " . $row['num_lote'] .
                     " - Folio: " . $row['folioreq'] .
                     " - " . $row['contribuyente'] .
                     " - $" . number_format($row['total'], 2) . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
