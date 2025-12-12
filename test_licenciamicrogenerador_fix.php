<?php
// Script para crear tabla licencias_microgenerador y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_licenciamicrogenerador(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de licencias de microgenerador
    echo "2. Creando tabla publico.licencias_microgenerador...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.licencias_microgenerador CASCADE");

    $sql = "
    CREATE TABLE publico.licencias_microgenerador (
        id_licencia SERIAL PRIMARY KEY,
        rfc VARCHAR(13) NOT NULL,
        folio_licencia VARCHAR(50) NOT NULL,
        nombre_titular VARCHAR(200) NOT NULL,
        domicilio_instalacion VARCHAR(300) NOT NULL,
        tipo_sistema VARCHAR(100) NOT NULL,
        potencia_instalada_kw NUMERIC(10,2) NOT NULL,
        num_paneles INTEGER NOT NULL,
        fecha_instalacion DATE NOT NULL,
        fecha_vencimiento DATE NOT NULL,
        estatus VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de licencias de microgenerador
    echo "3. Insertando 40 registros de licencias de microgenerador...\n";

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
        'CARMEN ROSA LOPEZ FERNANDEZ',
        'PEDRO ANTONIO CASTRO REYES',
        'MARTHA ELIZABETH RAMOS SILVA'
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
        'LOFC870410YZA',
        'CARP840525BCD',
        'RASM910310EFG'
    ];

    $tipos_sistema = [
        'INTERCONECTADO A RED CFE',
        'SISTEMA AISLADO CON BATERIAS',
        'SISTEMA HIBRIDO GRID-TIE',
        'SISTEMA ON-GRID SIN RESPALDO',
        'SISTEMA OFF-GRID AUTONOMO'
    ];

    $estados = ['VIGENTE', 'VENCIDA', 'EN TRAMITE', 'SUSPENDIDA'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.licencias_microgenerador
        (rfc, folio_licencia, nombre_titular, domicilio_instalacion, tipo_sistema,
         potencia_instalada_kw, num_paneles, fecha_instalacion, fecha_vencimiento, estatus)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 40; $i++) {
        $nombre_idx = ($i - 1) % 12;
        $rfc = $rfcs[$nombre_idx];
        $nombre = $nombres[$nombre_idx];

        $folio = "LMG-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $domicilio = "CALLE LIBERTAD #" . (500 + $i) . " COL JARDINES DEL VALLE CP 45138";
        $tipo_sistema = $tipos_sistema[$i % 5];

        // Potencia entre 3 y 15 kW
        $potencia_kw = 3.0 + ($i * 0.3);

        // Número de paneles proporcional a la potencia (aproximadamente 1 panel = 0.4 kW)
        $num_paneles = round($potencia_kw / 0.4);

        // Fecha de instalación: entre 1 y 4 años atrás
        $fecha_instalacion = clone $hoy;
        $dias_atras = 30 + ($i * 25);
        $fecha_instalacion->modify("-{$dias_atras} days");

        // Fecha de vencimiento: 10 años después de la instalación
        $fecha_vencimiento = clone $fecha_instalacion;
        $fecha_vencimiento->modify("+10 years");

        // Estado basado en varios criterios
        if ($fecha_vencimiento < $hoy) {
            $estatus = 'VENCIDA';
        } elseif ($i % 9 == 0) {
            $estatus = 'EN TRAMITE';
        } elseif ($i % 11 == 0) {
            $estatus = 'SUSPENDIDA';
        } else {
            $estatus = 'VIGENTE';
        }

        $stmt->execute([
            $rfc,
            $folio,
            $nombre,
            $domicilio,
            $tipo_sistema,
            $potencia_kw,
            $num_paneles,
            $fecha_instalacion->format('Y-m-d'),
            $fecha_vencimiento->format('Y-m-d'),
            $estatus
        ]);
    }
    echo "   ✓ 40 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - 12 RFCs diferentes con múltiples licencias cada uno\n";
    echo "   - Tipos de sistema: Interconectado, Aislado, Híbrido, etc.\n";
    echo "   - Estados: VIGENTE, VENCIDA, EN TRAMITE, SUSPENDIDA\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_licmicrogen_rfc ON publico.licencias_microgenerador(rfc)");
    $pdo->exec("CREATE INDEX idx_licmicrogen_folio ON publico.licencias_microgenerador(folio_licencia)");
    $pdo->exec("CREATE INDEX idx_licmicrogen_fecha_inst ON publico.licencias_microgenerador(fecha_instalacion DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_licenciamicrogenerador...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_licenciamicrogenerador(
        p_rfc VARCHAR
    )
    RETURNS TABLE (
        id_licencia INTEGER,
        rfc VARCHAR,
        folio_licencia VARCHAR,
        nombre_titular VARCHAR,
        domicilio_instalacion VARCHAR,
        tipo_sistema VARCHAR,
        potencia_instalada_kw NUMERIC,
        num_paneles INTEGER,
        fecha_instalacion DATE,
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
            l.nombre_titular,
            l.domicilio_instalacion,
            l.tipo_sistema,
            l.potencia_instalada_kw,
            l.num_paneles,
            l.fecha_instalacion,
            l.fecha_vencimiento,
            l.estatus
        FROM publico.licencias_microgenerador l
        WHERE l.rfc = UPPER(p_rfc)
        ORDER BY l.fecha_instalacion DESC;
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
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_licenciamicrogenerador(?)");
        $stmt->execute([$test['rfc']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " licencia(s)\n";

        if (count($rows) > 0) {
            foreach ($rows as $row) {
                echo "      - Folio: " . $row['folio_licencia'] .
                     " | " . $row['nombre_titular'] .
                     " | Sistema: " . $row['tipo_sistema'] .
                     " | Potencia: " . $row['potencia_instalada_kw'] . " kW" .
                     " | Paneles: " . $row['num_paneles'] .
                     " | Instalación: " . $row['fecha_instalacion'] .
                     " | Vencimiento: " . $row['fecha_vencimiento'] .
                     " | Estado: " . $row['estatus'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla licencias_microgenerador creada con 40 registros\n";
    echo "   - 12 RFCs diferentes con múltiples licencias\n";
    echo "   - Tipos de sistema: Interconectado a Red CFE, Aislado con Baterías, Híbrido, etc.\n";
    echo "   - Potencias desde 3 kW hasta 15 kW\n";
    echo "   - Número de paneles proporcional a la potencia instalada\n";
    echo "   - Estados: VIGENTE, VENCIDA, EN TRAMITE, SUSPENDIDA\n";
    echo "   - Vigencia: 10 años desde la fecha de instalación\n";
    echo "   - SP recaudadora_licenciamicrogenerador creado\n";
    echo "   - Búsqueda por RFC (convierte automáticamente a mayúsculas)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
