<?php
// Script para crear tabla notificaciones_actas y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listanotificacionesfrm(INTEGER, INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de notificaciones de actas
    echo "2. Creando tabla publico.notificaciones_actas...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.notificaciones_actas CASCADE");

    $sql = "
    CREATE TABLE publico.notificaciones_actas (
        id_notificacion SERIAL PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        abrevia VARCHAR(20) NOT NULL,
        axo_acta INTEGER NOT NULL,
        num_acta VARCHAR(50) NOT NULL,
        num_lote INTEGER NOT NULL,
        folioreq INTEGER NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300) NOT NULL,
        total NUMERIC(12,2) NOT NULL,
        tipo_documento VARCHAR(1) NOT NULL,
        fecha_notificacion DATE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de notificaciones
    echo "3. Insertando 60 registros de notificaciones de actas...\n";

    $dependencias = [
        'SEAPAL',
        'TDM',
        'ECOLOGIA',
        'OBRAS',
        'CATASTRO',
        'SEGURIDAD',
        'TURISMO',
        'PARQUES'
    ];

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
        'CARMEN ROSA LOPEZ FERNANDEZ',
        'PEDRO ANTONIO CASTRO REYES',
        'MARTHA ELIZABETH RAMOS SILVA'
    ];

    $tipos_documento = ['N', 'R', 'S']; // N=Notificación, R=Requerimiento, S=Secuestro

    $stmt = $pdo->prepare("
        INSERT INTO publico.notificaciones_actas
        (recaudadora, abrevia, axo_acta, num_acta, num_lote, folioreq, contribuyente, domicilio, total, tipo_documento, fecha_notificacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 60; $i++) {
        // Recaudadora de 1 a 5
        $recaudadora = (($i - 1) % 5) + 1;

        $dependencia = $dependencias[$i % 8];

        // Año: distribuir entre 2023 y 2024
        $axo_acta = ($i <= 30) ? 2024 : 2023;

        $num_acta = str_pad($i, 5, '0', STR_PAD_LEFT);

        // Número de lote (agrupados cada 5 registros)
        $num_lote = intval(($i - 1) / 5) + 1;

        // Folio de requerimiento secuencial
        $folioreq = 1000 + $i;

        $contribuyente = $contribuyentes[$i % 12];

        $domicilio = "CALLE INDEPENDENCIA #" . (100 + $i) . " COL CENTRO CP 44100";

        // Total entre 500 y 15000
        $total = 500.00 + ($i * 245.50);
        if ($total > 15000) $total = 15000 - (($i % 10) * 100);

        // Tipo de documento: distribuir entre N, R, S
        $tipo_documento = $tipos_documento[$i % 3];

        // Fecha: últimos 90 días
        $fecha_notificacion = clone $hoy;
        $dias_atras = rand(1, 90);
        $fecha_notificacion->modify("-{$dias_atras} days");

        $stmt->execute([
            $recaudadora,
            $dependencia,
            $axo_acta,
            $num_acta,
            $num_lote,
            $folioreq,
            $contribuyente,
            $domicilio,
            $total,
            $tipo_documento,
            $fecha_notificacion->format('Y-m-d')
        ]);
    }
    echo "   ✓ 60 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Recaudadoras: 1-5 (12 registros cada una)\n";
    echo "   - Años: 2024 (30 registros), 2023 (30 registros)\n";
    echo "   - Tipos: N (Notificación), R (Requerimiento), S (Secuestro)\n";
    echo "   - Folios: 1001-1060\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_notif_recaudadora ON publico.notificaciones_actas(recaudadora)");
    $pdo->exec("CREATE INDEX idx_notif_axo_acta ON publico.notificaciones_actas(axo_acta)");
    $pdo->exec("CREATE INDEX idx_notif_folioreq ON publico.notificaciones_actas(folioreq)");
    $pdo->exec("CREATE INDEX idx_notif_tipo_doc ON publico.notificaciones_actas(tipo_documento)");
    $pdo->exec("CREATE INDEX idx_notif_num_lote ON publico.notificaciones_actas(num_lote)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_listanotificacionesfrm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listanotificacionesfrm(
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
        num_acta VARCHAR,
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

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Recaudadora 1, Año 2024, Folios 1001-1020, Tipo N (Notificación), Orden por lote',
            'params' => [1, 2024, 1001, 1020, 'N', 'lote']
        ],
        [
            'nombre' => 'Recaudadora 2, Año 2024, Folios 1001-1030, Tipo R (Requerimiento), Orden por folio',
            'params' => [2, 2024, 1001, 1030, 'R', 'vigentes']
        ],
        [
            'nombre' => 'Recaudadora 3, Año 2023, Folios 1001-1050, Tipo S (Secuestro), Orden por dependencia',
            'params' => [3, 2023, 1001, 1050, 'S', 'dependencia']
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listanotificacionesfrm(?, ?, ?, ?, ?, ?)");
        $stmt->execute($test['params']);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " notificación(es)\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - Dep: " . $row['abrevia'] .
                     " | Acta: " . $row['num_acta'] . "/" . $row['axo_acta'] .
                     " | Lote: " . $row['num_lote'] .
                     " | Folio: " . $row['folioreq'] .
                     " | " . $row['contribuyente'] .
                     " | Total: $" . number_format($row['total'], 2) . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla notificaciones_actas creada con 60 registros\n";
    echo "   - Recaudadoras: 1-5 (12 registros cada una)\n";
    echo "   - Años: 2023-2024\n";
    echo "   - Dependencias: SEAPAL, TDM, ECOLOGIA, OBRAS, CATASTRO, SEGURIDAD, TURISMO, PARQUES\n";
    echo "   - Tipos de documento: N (Notificación), R (Requerimiento), S (Secuestro)\n";
    echo "   - Folios de requerimiento: 1001-1060\n";
    echo "   - Números de lote: 1-12\n";
    echo "   - SP recaudadora_listanotificacionesfrm creado\n";
    echo "   - Parámetros: recaudadora, año, folio inicio/fin, tipo documento, orden\n";
    echo "   - Orden dinámico: lote, vigentes (folio), dependencia\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
