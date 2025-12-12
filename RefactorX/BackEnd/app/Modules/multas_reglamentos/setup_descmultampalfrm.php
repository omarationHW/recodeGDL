<?php
/**
 * Setup script for RECAUDADORA_DESCMULTAMPALFRM
 * Creates table publico.descuentos_multa_municipal and stored procedure
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión establecida\n";

    // Drop existing function
    echo "\n1. Eliminando función anterior si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_descmultampalfrm(TEXT)");
    echo "✓ Función eliminada\n";

    // Create table
    echo "\n2. Creando tabla publico.descuentos_multa_municipal...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS publico.descuentos_multa_municipal (
            id SERIAL PRIMARY KEY,
            id_multa VARCHAR(50) NOT NULL,
            tipo_descto VARCHAR(50),
            valor_descuento NUMERIC(10,2),
            cvepago VARCHAR(50),
            fecha_descuento VARCHAR(20),
            capturista VARCHAR(100),
            autoriza VARCHAR(100),
            estado_desc VARCHAR(50),
            folio VARCHAR(50),
            observacion TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");
    echo "✓ Tabla creada\n";

    // Create stored procedure
    echo "\n3. Creando stored procedure publico.recaudadora_descmultampalfrm...\n";
    $pdo->exec("
        CREATE OR REPLACE FUNCTION publico.recaudadora_descmultampalfrm(
            p_clave_cuenta TEXT
        )
        RETURNS TABLE(
            id_multa VARCHAR,
            tipo_descto VARCHAR,
            valor_descuento NUMERIC,
            cvepago VARCHAR,
            fecha_descuento VARCHAR,
            capturista VARCHAR,
            autoriza VARCHAR,
            estado_desc VARCHAR,
            folio VARCHAR,
            observacion TEXT
        )
        LANGUAGE plpgsql
        AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                d.id_multa,
                d.tipo_descto,
                d.valor_descuento,
                d.cvepago,
                d.fecha_descuento,
                d.capturista,
                d.autoriza,
                d.estado_desc,
                d.folio,
                d.observacion
            FROM publico.descuentos_multa_municipal d
            WHERE d.id_multa = p_clave_cuenta
            ORDER BY d.created_at DESC;
        END;
        \$\$;
    ");
    echo "✓ Stored procedure creado\n";

    // Insert sample data
    echo "\n4. Insertando datos de ejemplo...\n";

    // Clear existing data
    $pdo->exec("TRUNCATE TABLE publico.descuentos_multa_municipal RESTART IDENTITY CASCADE");

    $sampleData = [
        // Multa 191 - 3 descuentos
        [
            'id_multa' => '191',
            'tipo_descto' => 'Porcentaje',
            'valor_descuento' => 50,
            'cvepago' => 'PAG-2024-0191-A',
            'fecha_descuento' => '2024-01-15',
            'capturista' => 'MARIA LOPEZ',
            'autoriza' => 'DIRECTOR RECAUDACION',
            'estado_desc' => 'Vigente',
            'folio' => 'DESC-191-001',
            'observacion' => 'Descuento por pronto pago'
        ],
        [
            'id_multa' => '191',
            'tipo_descto' => 'Monto',
            'valor_descuento' => 500,
            'cvepago' => 'PAG-2024-0191-B',
            'fecha_descuento' => '2024-02-10',
            'capturista' => 'JUAN PEREZ',
            'autoriza' => 'SUBDIRECTOR',
            'estado_desc' => 'Pagado',
            'folio' => 'DESC-191-002',
            'observacion' => 'Descuento por situación económica'
        ],
        [
            'id_multa' => '191',
            'tipo_descto' => 'Porcentaje',
            'valor_descuento' => 25,
            'cvepago' => 'PAG-2024-0191-C',
            'fecha_descuento' => '2024-03-05',
            'capturista' => 'ANA GARCIA',
            'autoriza' => 'DIRECTOR RECAUDACION',
            'estado_desc' => 'Cancelado',
            'folio' => 'DESC-191-003',
            'observacion' => 'Descuento cancelado por error en aplicación'
        ],

        // Multa 224 - 2 descuentos
        [
            'id_multa' => '224',
            'tipo_descto' => 'Porcentaje',
            'valor_descuento' => 30,
            'cvepago' => 'PAG-2024-0224-A',
            'fecha_descuento' => '2024-04-12',
            'capturista' => 'CARLOS MARTINEZ',
            'autoriza' => 'JEFE DEPARTAMENTO',
            'estado_desc' => 'Vigente',
            'folio' => 'DESC-224-001',
            'observacion' => 'Descuento por campaña de regularización'
        ],
        [
            'id_multa' => '224',
            'tipo_descto' => 'Monto',
            'valor_descuento' => 1000,
            'cvepago' => 'PAG-2024-0224-B',
            'fecha_descuento' => '2024-05-20',
            'capturista' => 'LUCIA HERNANDEZ',
            'autoriza' => 'DIRECTOR RECAUDACION',
            'estado_desc' => 'Pagado',
            'folio' => 'DESC-224-002',
            'observacion' => 'Descuento autorizado por acuerdo municipal'
        ],

        // Multa 241 - 3 descuentos
        [
            'id_multa' => '241',
            'tipo_descto' => 'Porcentaje',
            'valor_descuento' => 40,
            'cvepago' => 'PAG-2024-0241-A',
            'fecha_descuento' => '2024-06-08',
            'capturista' => 'PEDRO SANCHEZ',
            'autoriza' => 'SUBDIRECTOR',
            'estado_desc' => 'Vigente',
            'folio' => 'DESC-241-001',
            'observacion' => 'Descuento por primera infracción'
        ],
        [
            'id_multa' => '241',
            'tipo_descto' => 'Porcentaje',
            'valor_descuento' => 15,
            'cvepago' => 'PAG-2024-0241-B',
            'fecha_descuento' => '2024-07-15',
            'capturista' => 'SOFIA RAMIREZ',
            'autoriza' => 'JEFE DEPARTAMENTO',
            'estado_desc' => 'Vigente',
            'folio' => 'DESC-241-002',
            'observacion' => 'Descuento adicional por convenio de pago'
        ],
        [
            'id_multa' => '241',
            'tipo_descto' => 'Monto',
            'valor_descuento' => 750,
            'cvepago' => 'PAG-2024-0241-C',
            'fecha_descuento' => '2024-08-22',
            'capturista' => 'ROBERTO TORRES',
            'autoriza' => 'DIRECTOR RECAUDACION',
            'estado_desc' => 'Pagado',
            'folio' => 'DESC-241-003',
            'observacion' => 'Pago total con descuentos aplicados'
        ]
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.descuentos_multa_municipal
        (id_multa, tipo_descto, valor_descuento, cvepago, fecha_descuento, capturista, autoriza, estado_desc, folio, observacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $insertCount = 0;
    foreach ($sampleData as $row) {
        $stmt->execute([
            $row['id_multa'],
            $row['tipo_descto'],
            $row['valor_descuento'],
            $row['cvepago'],
            $row['fecha_descuento'],
            $row['capturista'],
            $row['autoriza'],
            $row['estado_desc'],
            $row['folio'],
            $row['observacion']
        ]);
        $insertCount++;
    }
    echo "✓ {$insertCount} registros insertados\n";

    // Test the stored procedure
    echo "\n5. Probando stored procedure...\n";
    $testIds = ['191', '224', '241'];

    foreach ($testIds as $testId) {
        echo "\n   Probando con ID Multa = {$testId}:\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descmultampalfrm(?)");
        $stmt->execute([$testId]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   ✓ Retornó " . count($results) . " registros\n";

        if (count($results) > 0) {
            foreach ($results as $idx => $row) {
                echo "     - Registro " . ($idx + 1) . ": {$row['tipo_descto']} = {$row['valor_descuento']}";
                echo ($row['tipo_descto'] === 'Porcentaje' ? '%' : '');
                echo ", Estado: {$row['estado_desc']}\n";
            }
        }
    }

    echo "\n✓ Setup completado exitosamente\n";
    echo "\n=== DATOS DE PRUEBA ===\n";
    echo "ID Multa 191: 3 descuentos (50%, \$500, 25% cancelado)\n";
    echo "ID Multa 224: 2 descuentos (30%, \$1000 pagado)\n";
    echo "ID Multa 241: 3 descuentos (40%, 15%, \$750 pagado)\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
