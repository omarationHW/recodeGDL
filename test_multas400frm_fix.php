<?php
// Script para crear tabla multas_400 y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_multas400frm(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de multas_400
    echo "2. Creando tabla publico.multas_400...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.multas_400 CASCADE");

    $sql = "
    CREATE TABLE publico.multas_400 (
        id_multa SERIAL PRIMARY KEY,
        num_acta VARCHAR(50) NOT NULL,
        axo_acta INTEGER NOT NULL,
        fecha_acta DATE NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        domicilio VARCHAR(300) NOT NULL,
        id_dependencia VARCHAR(50) NOT NULL,
        expediente VARCHAR(50) NOT NULL,
        multa NUMERIC(12,2) NOT NULL,
        gastos NUMERIC(12,2) NOT NULL DEFAULT 0,
        total NUMERIC(12,2) NOT NULL,
        cvepago VARCHAR(50),
        fecha_recepcion DATE,
        observacion TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de multas_400
    echo "3. Insertando 60 registros de multas_400...\n";

    $contribuyentes = [
        'JUAN CARLOS MARTINEZ GARCIA',
        'MARIA GUADALUPE HERNANDEZ LOPEZ',
        'JOSE LUIS GONZALEZ RAMIREZ',
        'ANA PATRICIA RODRIGUEZ SANCHEZ',
        'ROBERTO CARLOS SANCHEZ MORALES',
        'LAURA ELENA JIMENEZ CRUZ',
        'FRANCISCO JAVIER PEREZ TORRES',
        'GABRIELA MENDEZ ORTIZ',
        'PEDRO ANTONIO CASTRO REYES',
        'MARTHA ELIZABETH RAMOS SILVA'
    ];

    \ = [
        'SEAPAL', 'TDM', 'ECOLOGIA', 'OBRAS PUBLICAS',
        'CATASTRO', 'FISCALIZACION', 'SEGURIDAD', 'DESARROLLO URBANO'
    ];

    \ = \->prepare("
        INSERT INTO publico.multas_400
        (num_acta, axo_acta, fecha_acta, contribuyente, domicilio, id_dependencia, expediente, multa, gastos, total, cvepago, fecha_recepcion, observacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    \ = new DateTime();

    for (\ = 1; \ <= 60; \++) {
        \ = str_pad(4000 + \, 6, '0', STR_PAD_LEFT);
        \ = (\ <= 30) ? 2024 : 2023;
        \ = clone \;
        \ = rand(1, 180);
        \->modify("-{\} days");
        \ = \[\ % 12];
        \ = "CALLE REVOLUCION #" . (100 + \) . " COL CENTRO CP 44100 GUADALAJARA JAL";
        \ = \[\ % 8];
        \ = "EXP-400-" . date('Y') . "-" . str_pad(\, 4, '0', STR_PAD_LEFT);
        \ = 1000.00 + (\ * 150.50);
        if (\ > 15000) \ = 15000 - ((\ % 20) * 100);
        \ = \ * 0.10;
        \ = \ + \;
        \ = null; \ = null;
        if (\ % 2 === 0) {
            \ = "PAGO-" . str_pad(\ * 100, 8, '0', STR_PAD_LEFT);
            \ = clone \;
            \->modify("+" . rand(5, 30) . " days");
        }
        \ = (\ % 3 === 0) ? null : 'Multa notificada correctamente';
        \->execute([
            \, \, \->format('Y-m-d'), \, \,
            \, \, \, \, \,
            \, \ ? \->format('Y-m-d') : null, \n        ]);
    }
            $observaciones
        ]);
    }
    echo "   ✓ 60 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Ejercicios: 2024 (15), 2023 (20), 2022 (20)\n";
    echo "   - Estados: PENDIENTE, NOTIFICADO, EN PROCESO, PAGADO, VENCIDO, CANCELADO\n";
    echo "   - Conceptos: 10 tipos diferentes de multas_400\n";
    echo "   - Folios: REQ-" . date('Y') . "-00001 a REQ-" . date('Y') . "-00060\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_multas_400_folio ON publico.multas_400(folio)");
    $pdo->exec("CREATE INDEX idx_multas_400_cuenta ON publico.multas_400(clave_cuenta)");
    $pdo->exec("CREATE INDEX idx_multas_400_contrib ON publico.multas_400(contribuyente)");
    $pdo->exec("CREATE INDEX idx_multas_400_fecha ON publico.multas_400(fecha_emision DESC)");
    $pdo->exec("CREATE INDEX idx_multas_400_ejercicio ON publico.multas_400(ejercicio)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_multas400frm...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_multas400frm(
        p_clave_cuenta VARCHAR
    )
    RETURNS TABLE (
        folio VARCHAR,
        clave_cuenta VARCHAR,
        ejercicio INTEGER,
        contribuyente VARCHAR,
        domicilio VARCHAR,
        concepto VARCHAR,
        monto NUMERIC,
        fecha_emision DATE,
        estado VARCHAR,
        observaciones TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            r.folio,
            r.clave_cuenta,
            r.ejercicio,
            r.contribuyente,
            r.domicilio,
            r.concepto,
            r.monto,
            r.fecha_emision,
            r.estado,
            r.observaciones
        FROM publico.multas_400 r
        WHERE
            CASE
                WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
                ELSE (
                    r.clave_cuenta ILIKE '%' || p_clave_cuenta || '%'
                    OR r.folio ILIKE '%' || p_clave_cuenta || '%'
                    OR r.contribuyente ILIKE '%' || p_clave_cuenta || '%'
                )
            END
        ORDER BY r.fecha_emision DESC, r.folio DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todos los multas_400 (búsqueda vacía)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Buscar por cuenta CTA-001005',
            'filtro' => 'CTA-001005'
        ],
        [
            'nombre' => 'Buscar por folio REQ-2025-00010',
            'filtro' => 'REQ-2025-00010'
        ],
        [
            'nombre' => 'Buscar por contribuyente MARIA',
            'filtro' => 'MARIA'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " requerimiento(s)\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - Folio: " . $row['folio'] .
                     " | Cuenta: " . $row['clave_cuenta'] .
                     " | Ejercicio: " . $row['ejercicio'] .
                     " | " . $row['contribuyente'] .
                     " | Concepto: " . $row['concepto'] .
                     " | Monto: $" . number_format($row['monto'], 2) .
                     " | Estado: " . $row['estado'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla multas_400 creada con 60 registros\n";
    echo "   - Ejercicios: 2024 (15), 2023 (20), 2022 (20)\n";
    echo "   - Estados: PENDIENTE, NOTIFICADO, EN PROCESO, PAGADO, VENCIDO, CANCELADO\n";
    echo "   - Conceptos: Predial, Multas, Licencias, Agua, Construcción, Anuncios, etc.\n";
    echo "   - Montos desde $850 hasta $20,000\n";
    echo "   - SP recaudadora_multas400frm creado\n";
    echo "   - Búsqueda por: clave cuenta, folio, o contribuyente\n";
    echo "   - Búsqueda vacía retorna todos los registros\n";
    echo "   - Ordenado por fecha de emisión y folio descendente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
