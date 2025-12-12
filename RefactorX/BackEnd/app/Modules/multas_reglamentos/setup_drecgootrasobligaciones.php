<?php
/**
 * Setup script for RECAUDADORA_DRECGOOTRASOBLIGACIONES
 * Creates table publico.otras_obligaciones and stored procedure
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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_drecgootrasobligaciones(TEXT)");
    echo "✓ Función eliminada\n";

    // Create table
    echo "\n2. Creando tabla publico.otras_obligaciones...\n";
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS publico.otras_obligaciones (
            id SERIAL PRIMARY KEY,
            clave_cuenta VARCHAR(50) NOT NULL,
            tipo_obligacion VARCHAR(100),
            concepto VARCHAR(200),
            importe NUMERIC(10,2),
            ejercicio INTEGER,
            fecha_vencimiento VARCHAR(20),
            estatus VARCHAR(50),
            referencia VARCHAR(100),
            observaciones TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");
    echo "✓ Tabla creada\n";

    // Create stored procedure
    echo "\n3. Creando stored procedure publico.recaudadora_drecgootrasobligaciones...\n";
    $pdo->exec("
        CREATE OR REPLACE FUNCTION publico.recaudadora_drecgootrasobligaciones(
            p_clave_cuenta TEXT
        )
        RETURNS TABLE(
            clave_cuenta VARCHAR,
            tipo_obligacion VARCHAR,
            concepto VARCHAR,
            importe NUMERIC,
            ejercicio INTEGER,
            fecha_vencimiento VARCHAR,
            estatus VARCHAR,
            referencia VARCHAR,
            observaciones TEXT
        )
        LANGUAGE plpgsql
        AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                o.clave_cuenta,
                o.tipo_obligacion,
                o.concepto,
                o.importe,
                o.ejercicio,
                o.fecha_vencimiento,
                o.estatus,
                o.referencia,
                o.observaciones
            FROM publico.otras_obligaciones o
            WHERE o.clave_cuenta = p_clave_cuenta
            ORDER BY o.ejercicio DESC, o.created_at DESC;
        END;
        \$\$;
    ");
    echo "✓ Stored procedure creado\n";

    // Insert sample data
    echo "\n4. Insertando datos de ejemplo...\n";

    // Clear existing data
    $pdo->exec("TRUNCATE TABLE publico.otras_obligaciones RESTART IDENTITY CASCADE");

    $sampleData = [
        // Cuenta OBL-2024-001 - 3 obligaciones
        [
            'clave_cuenta' => 'OBL-2024-001',
            'tipo_obligacion' => 'CONTRIBUCION ESPECIAL',
            'concepto' => 'Mejora de infraestructura vial',
            'importe' => 5000.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-12-31',
            'estatus' => 'PENDIENTE',
            'referencia' => 'INFRA-2024-001',
            'observaciones' => 'Contribución por obras de pavimentación'
        ],
        [
            'clave_cuenta' => 'OBL-2024-001',
            'tipo_obligacion' => 'DERECHO DE TRAMITE',
            'concepto' => 'Licencia ambiental especial',
            'importe' => 2500.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-11-30',
            'estatus' => 'PAGADO',
            'referencia' => 'AMB-2024-045',
            'observaciones' => 'Pagado el 15 de noviembre de 2024'
        ],
        [
            'clave_cuenta' => 'OBL-2024-001',
            'tipo_obligacion' => 'APROVECHAMIENTO',
            'concepto' => 'Uso de vía pública para eventos',
            'importe' => 1200.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-10-15',
            'estatus' => 'VENCIDO',
            'referencia' => 'VP-2024-123',
            'observaciones' => 'Evento realizado en septiembre 2024'
        ],

        // Cuenta OBL-2024-002 - 2 obligaciones
        [
            'clave_cuenta' => 'OBL-2024-002',
            'tipo_obligacion' => 'CONTRIBUCION ESPECIAL',
            'concepto' => 'Drenaje y alcantarillado',
            'importe' => 8500.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-12-31',
            'estatus' => 'PENDIENTE',
            'referencia' => 'DREN-2024-078',
            'observaciones' => 'Obras de drenaje pluvial zona norte'
        ],
        [
            'clave_cuenta' => 'OBL-2024-002',
            'tipo_obligacion' => 'SANCION ADMINISTRATIVA',
            'concepto' => 'Incumplimiento normativa construcción',
            'importe' => 15000.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-09-30',
            'estatus' => 'EN PROCESO',
            'referencia' => 'SAN-2024-234',
            'observaciones' => 'En proceso de recurso de revisión'
        ],

        // Cuenta OBL-2024-003 - 4 obligaciones
        [
            'clave_cuenta' => 'OBL-2024-003',
            'tipo_obligacion' => 'DERECHO DE TRAMITE',
            'concepto' => 'Permiso construcción obra nueva',
            'importe' => 3500.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-12-15',
            'estatus' => 'PAGADO',
            'referencia' => 'CONST-2024-456',
            'observaciones' => 'Permiso vigente hasta diciembre 2025'
        ],
        [
            'clave_cuenta' => 'OBL-2024-003',
            'tipo_obligacion' => 'APROVECHAMIENTO',
            'concepto' => 'Ocupación temporal vía pública',
            'importe' => 800.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-08-31',
            'estatus' => 'PAGADO',
            'referencia' => 'OCUP-2024-089',
            'observaciones' => 'Para andamios durante obra'
        ],
        [
            'clave_cuenta' => 'OBL-2024-003',
            'tipo_obligacion' => 'CONTRIBUCION ESPECIAL',
            'concepto' => 'Alumbrado público nuevo fraccionamiento',
            'importe' => 12000.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-12-31',
            'estatus' => 'PENDIENTE',
            'referencia' => 'ALUM-2024-012',
            'observaciones' => 'Instalación de 24 luminarias LED'
        ],
        [
            'clave_cuenta' => 'OBL-2024-003',
            'tipo_obligacion' => 'DERECHO DE TRAMITE',
            'concepto' => 'Alineamiento y número oficial',
            'importe' => 450.00,
            'ejercicio' => 2024,
            'fecha_vencimiento' => '2024-07-31',
            'estatus' => 'PAGADO',
            'referencia' => 'ALIN-2024-567',
            'observaciones' => 'Trámite concluido'
        ],

        // Cuenta OBL-2023-005 - obligación de años anteriores
        [
            'clave_cuenta' => 'OBL-2023-005',
            'tipo_obligacion' => 'APROVECHAMIENTO',
            'concepto' => 'Concesión de mercado municipal',
            'importe' => 6000.00,
            'ejercicio' => 2023,
            'fecha_vencimiento' => '2023-12-31',
            'estatus' => 'VENCIDO',
            'referencia' => 'MERC-2023-234',
            'observaciones' => 'Pendiente de renovación y pago'
        ]
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.otras_obligaciones
        (clave_cuenta, tipo_obligacion, concepto, importe, ejercicio, fecha_vencimiento, estatus, referencia, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $insertCount = 0;
    foreach ($sampleData as $row) {
        $stmt->execute([
            $row['clave_cuenta'],
            $row['tipo_obligacion'],
            $row['concepto'],
            $row['importe'],
            $row['ejercicio'],
            $row['fecha_vencimiento'],
            $row['estatus'],
            $row['referencia'],
            $row['observaciones']
        ]);
        $insertCount++;
    }
    echo "✓ {$insertCount} registros insertados\n";

    // Test the stored procedure
    echo "\n5. Probando stored procedure...\n";
    $testAccounts = ['OBL-2024-001', 'OBL-2024-002', 'OBL-2024-003'];

    foreach ($testAccounts as $testAccount) {
        echo "\n   Probando con Cuenta = {$testAccount}:\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgootrasobligaciones(?)");
        $stmt->execute([$testAccount]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   ✓ Retornó " . count($results) . " registros\n";

        if (count($results) > 0) {
            foreach ($results as $idx => $row) {
                echo "     - Registro " . ($idx + 1) . ": {$row['tipo_obligacion']} - \${$row['importe']}";
                echo " - {$row['estatus']}\n";
            }
        }
    }

    echo "\n✓ Setup completado exitosamente\n";
    echo "\n=== DATOS DE PRUEBA ===\n";
    echo "Cuenta OBL-2024-001: 3 obligaciones (Contribución, Derecho, Aprovechamiento)\n";
    echo "Cuenta OBL-2024-002: 2 obligaciones (Contribución \$8,500, Sanción \$15,000)\n";
    echo "Cuenta OBL-2024-003: 4 obligaciones (Permisos, Alumbrado, Alineamiento)\n";
    echo "Cuenta OBL-2023-005: 1 obligación vencida (Concesión mercado 2023)\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
