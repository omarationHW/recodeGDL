<?php
// Script para crear tabla licencias_microgenerador_ecologia y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_licenciamicrogeneradorecologia(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de licencias de microgenerador ecología
    echo "2. Creando tabla publico.licencias_microgenerador_ecologia...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.licencias_microgenerador_ecologia CASCADE");

    $sql = "
    CREATE TABLE publico.licencias_microgenerador_ecologia (
        id_licencia SERIAL PRIMARY KEY,
        rfc VARCHAR(13) NOT NULL,
        folio_licencia VARCHAR(50) NOT NULL,
        nombre_solicitante VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300),
        tipo_energia VARCHAR(100) NOT NULL,
        capacidad_kw NUMERIC(10,2) NOT NULL,
        fecha_emision DATE NOT NULL,
        fecha_vencimiento DATE NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de licencias ecológicas
    echo "3. Insertando 30 registros de licencias ecológicas...\n";

    $nombres = [
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

    $rfcs = [
        'MAGJ850315ABC',
        'HELM900520XYZ',
        'GORJ880412DEF',
        'ROSA920725GHI',
        'SAMR870830JKL',
        'JICL910615MNO',
        'PETF860920PQR',
        'MEOG931105STU',
        'VARM891220VWX',
        'LOFC870410YZA'
    ];

    $tipos_energia = [
        'SOLAR FOTOVOLTAICA',
        'SOLAR TÉRMICA',
        'EÓLICA RESIDENCIAL',
        'BIOMASA',
        'HIDROELÉCTRICA MINI'
    ];

    $estados = ['VIGENTE', 'VENCIDA', 'SUSPENDIDA'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.licencias_microgenerador_ecologia
        (rfc, folio_licencia, nombre_solicitante, domicilio, tipo_energia, capacidad_kw,
         fecha_emision, fecha_vencimiento, estatus)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 30; $i++) {
        $nombre_idx = ($i - 1) % 10;
        $rfc = $rfcs[$nombre_idx];
        $nombre = $nombres[$nombre_idx];

        $folio = "LMGE-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $domicilio = "CALLE REFORMA #" . (100 + $i) . " COL AMERICANA CP 44160";
        $tipo_energia = $tipos_energia[$i % 5];

        // Capacidad entre 1 y 10 kW
        $capacidad_kw = 1.5 + ($i * 0.25);

        // Fecha de emisión: entre 6 meses y 3 años atrás
        $fecha_emision = clone $hoy;
        $dias_atras = 180 + ($i * 30);
        $fecha_emision->modify("-{$dias_atras} days");

        // Fecha de vencimiento: 5 años después de la emisión
        $fecha_vencimiento = clone $fecha_emision;
        $fecha_vencimiento->modify("+5 years");

        // Estado basado en si está vencida
        if ($fecha_vencimiento < $hoy) {
            $estatus = 'VENCIDA';
        } elseif ($i % 7 == 0) {
            $estatus = 'SUSPENDIDA';
        } else {
            $estatus = 'VIGENTE';
        }

        $stmt->execute([
            $rfc,
            $folio,
            $nombre,
            $domicilio,
            $tipo_energia,
            $capacidad_kw,
            $fecha_emision->format('Y-m-d'),
            $fecha_vencimiento->format('Y-m-d'),
            $estatus
        ]);
    }
    echo "   ✓ 30 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - 10 RFCs diferentes con múltiples licencias cada uno\n";
    echo "   - Tipos de energía: Solar, Eólica, Biomasa, Hidroeléctrica\n";
    echo "   - Estados: VIGENTE, VENCIDA, SUSPENDIDA\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_lic_micro_rfc ON publico.licencias_microgenerador_ecologia(rfc)");
    $pdo->exec("CREATE INDEX idx_lic_micro_folio ON publico.licencias_microgenerador_ecologia(folio_licencia)");
    $pdo->exec("CREATE INDEX idx_lic_micro_fecha_emision ON publico.licencias_microgenerador_ecologia(fecha_emision DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_licenciamicrogeneradorecologia...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_licenciamicrogeneradorecologia(
        p_rfc VARCHAR
    )
    RETURNS TABLE (
        id_licencia INTEGER,
        rfc VARCHAR,
        folio_licencia VARCHAR,
        nombre_solicitante VARCHAR,
        domicilio VARCHAR,
        tipo_energia VARCHAR,
        capacidad_kw NUMERIC,
        fecha_emision DATE,
        fecha_vencimiento DATE,
        estatus VARCHAR
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            l.id_licencia,
            l.rfc,
            l.folio_licencia,
            l.nombre_solicitante,
            l.domicilio,
            l.tipo_energia,
            l.capacidad_kw,
            l.fecha_emision,
            l.fecha_vencimiento,
            l.estatus
        FROM publico.licencias_microgenerador_ecologia l
        WHERE l.rfc = UPPER(p_rfc)
        ORDER BY l.fecha_emision DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Licencias para RFC MAGJ850315ABC',
            'rfc' => 'MAGJ850315ABC'
        ],
        [
            'nombre' => 'Licencias para RFC HELM900520XYZ',
            'rfc' => 'HELM900520XYZ'
        ],
        [
            'nombre' => 'Licencias para RFC GORJ880412DEF',
            'rfc' => 'GORJ880412DEF'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogeneradorecologia(?)");
        $stmt->execute([$test['rfc']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " licencia(s)\n";

        if (count($rows) > 0) {
            foreach ($rows as $row) {
                echo "      - Folio: " . $row['folio_licencia'] .
                     " | " . $row['nombre_solicitante'] .
                     " | Tipo: " . $row['tipo_energia'] .
                     " | Capacidad: " . $row['capacidad_kw'] . " kW" .
                     " | Emisión: " . $row['fecha_emision'] .
                     " | Vencimiento: " . $row['fecha_vencimiento'] .
                     " | Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla licencias_microgenerador_ecologia creada con 30 registros\n";
    echo "   - 10 RFCs diferentes con múltiples licencias\n";
    echo "   - Tipos de energía: Solar Fotovoltaica, Solar Térmica, Eólica, Biomasa, Hidroeléctrica\n";
    echo "   - Capacidades desde 1.5 kW hasta 9 kW\n";
    echo "   - Estados: VIGENTE, VENCIDA, SUSPENDIDA\n";
    echo "   - SP recaudadora_licenciamicrogeneradorecologia creado\n";
    echo "   - Búsqueda por RFC (convierte automáticamente a mayúsculas)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
