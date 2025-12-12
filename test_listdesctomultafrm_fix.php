<?php
// Script para crear tabla descuentos_multa y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listdesctomultafrm(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de descuentos de multa
    echo "2. Creando tabla publico.descuentos_multa...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.descuentos_multa CASCADE");

    $sql = "
    CREATE TABLE publico.descuentos_multa (
        id_descuento SERIAL PRIMARY KEY,
        id_multa INTEGER NOT NULL,
        num_acta VARCHAR(50) NOT NULL,
        axo_acta INTEGER NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        tipo_descto VARCHAR(50) NOT NULL,
        valor_descto NUMERIC(12,2) NOT NULL,
        porcentaje VARCHAR(10),
        total_original NUMERIC(12,2) NOT NULL,
        total_con_descto NUMERIC(12,2) NOT NULL,
        estado VARCHAR(20) NOT NULL,
        fecha_movto DATE NOT NULL,
        folio VARCHAR(50) NOT NULL,
        observacion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de descuentos de multa
    echo "3. Insertando 60 registros de descuentos de multa...\n";

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

    $tipos_descto = ['Porcentaje', 'Monto Fijo', 'Autorizado'];
    $estados = ['Activo', 'Pagado', 'Cancelado'];

    $observaciones = [
        'Descuento por pronto pago',
        'Descuento autorizado por dirección',
        'Beneficio tercera edad',
        'Convenio de pago',
        null,
        'Descuento especial programa social',
        'Condonación parcial aprobada'
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.descuentos_multa
        (id_multa, num_acta, axo_acta, contribuyente, tipo_descto, valor_descto, porcentaje,
         total_original, total_con_descto, estado, fecha_movto, folio, observacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 60; $i++) {
        $id_multa = 1000 + $i;
        $num_acta = "ACTA-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $axo_acta = ($i <= 35) ? 2024 : 2023;

        $contribuyente = $contribuyentes[$i % 10];
        $tipo_descto = $tipos_descto[$i % 3];

        $total_original = 1000.00 + ($i * 125.50);

        // Calcular descuento según el tipo
        if ($tipo_descto === 'Porcentaje') {
            $porcentajes = ['10%', '15%', '20%', '25%', '30%', '50%'];
            $porcentaje = $porcentajes[$i % 6];
            $porcentaje_num = (int)str_replace('%', '', $porcentaje);
            $valor_descto = $total_original * ($porcentaje_num / 100);
        } elseif ($tipo_descto === 'Monto Fijo') {
            $valor_descto = 200.00 + ($i * 15.50);
            $porcentaje = null;
        } else { // Autorizado
            $valor_descto = $total_original * 0.40; // 40% autorizado
            $porcentaje = '40%';
        }

        $total_con_descto = $total_original - $valor_descto;

        $estado = $estados[$i % 3];

        // Fecha: últimos 90 días
        $fecha_movto = clone $hoy;
        $dias_atras = rand(1, 90);
        $fecha_movto->modify("-{$dias_atras} days");

        $folio = "FOLIO-DESC-" . str_pad($i, 5, '0', STR_PAD_LEFT);
        $observacion = $observaciones[$i % 7];

        $stmt->execute([
            $id_multa,
            $num_acta,
            $axo_acta,
            $contribuyente,
            $tipo_descto,
            $valor_descto,
            $porcentaje,
            $total_original,
            $total_con_descto,
            $estado,
            $fecha_movto->format('Y-m-d'),
            $folio,
            $observacion
        ]);
    }
    echo "   ✓ 60 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Año 2024: 35 registros\n";
    echo "   - Año 2023: 25 registros\n";
    echo "   - Tipos: Porcentaje, Monto Fijo, Autorizado\n";
    echo "   - Estados: Activo, Pagado, Cancelado\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_desctos_multa_id ON publico.descuentos_multa(id_multa)");
    $pdo->exec("CREATE INDEX idx_desctos_multa_acta ON publico.descuentos_multa(num_acta)");
    $pdo->exec("CREATE INDEX idx_desctos_multa_contrib ON publico.descuentos_multa(contribuyente)");
    $pdo->exec("CREATE INDEX idx_desctos_multa_fecha ON publico.descuentos_multa(fecha_movto DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_listdesctomultafrm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listdesctomultafrm(
        p_filtro VARCHAR
    )
    RETURNS TABLE (
        id_multa INTEGER,
        num_acta VARCHAR,
        axo_acta INTEGER,
        contribuyente VARCHAR,
        tipo_descto VARCHAR,
        valor_descto NUMERIC,
        porcentaje VARCHAR,
        total_original NUMERIC,
        total_con_descto NUMERIC,
        estado VARCHAR,
        fecha_movto DATE,
        folio VARCHAR,
        observacion TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            d.id_multa,
            d.num_acta,
            d.axo_acta,
            d.contribuyente,
            d.tipo_descto,
            d.valor_descto,
            d.porcentaje,
            d.total_original,
            d.total_con_descto,
            d.estado,
            d.fecha_movto,
            d.folio,
            d.observacion
        FROM publico.descuentos_multa d
        WHERE
            p_filtro = '' OR p_filtro IS NULL
            OR CAST(d.id_multa AS TEXT) ILIKE '%' || p_filtro || '%'
            OR d.num_acta ILIKE '%' || p_filtro || '%'
            OR CAST(d.axo_acta AS TEXT) ILIKE '%' || p_filtro || '%'
            OR d.contribuyente ILIKE '%' || p_filtro || '%'
            OR d.tipo_descto ILIKE '%' || p_filtro || '%'
            OR d.folio ILIKE '%' || p_filtro || '%'
            OR d.estado ILIKE '%' || p_filtro || '%'
        ORDER BY d.fecha_movto DESC, d.id_descuento DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todos los descuentos (sin filtro)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Filtrar por tipo "Porcentaje"',
            'filtro' => 'Porcentaje'
        ],
        [
            'nombre' => 'Filtrar por contribuyente MARIA',
            'filtro' => 'MARIA'
        ],
        [
            'nombre' => 'Filtrar por estado Activo',
            'filtro' => 'Activo'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listdesctomultafrm(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s)\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - ID Multa: " . $row['id_multa'] .
                     " | Acta: " . $row['num_acta'] . "/" . $row['axo_acta'] .
                     " | " . $row['contribuyente'] .
                     " | Tipo: " . $row['tipo_descto'] .
                     " | Descuento: $" . number_format($row['valor_descto'], 2) .
                     ($row['porcentaje'] ? " (" . $row['porcentaje'] . ")" : "") .
                     " | Original: $" . number_format($row['total_original'], 2) .
                     " | Con Descto: $" . number_format($row['total_con_descto'], 2) .
                     " | Estado: " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla descuentos_multa creada con 60 registros\n";
    echo "   - Tipos de descuento: Porcentaje (10%-50%), Monto Fijo, Autorizado (40%)\n";
    echo "   - Estados: Activo, Pagado, Cancelado\n";
    echo "   - Años: 2023-2024\n";
    echo "   - Importes originales desde $1,125 hasta $8,530\n";
    echo "   - Descuentos aplicados según tipo\n";
    echo "   - SP recaudadora_listdesctomultafrm creado\n";
    echo "   - Búsqueda por: ID multa, número de acta, año, contribuyente, tipo, folio, estado\n";
    echo "   - Ordenado por fecha más reciente primero\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
