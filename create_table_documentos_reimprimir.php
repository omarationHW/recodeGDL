<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO TABLA documentos_reimprimir ===\n\n";

// Crear tabla
$sql = "
DROP TABLE IF EXISTS publico.documentos_reimprimir CASCADE;

CREATE TABLE publico.documentos_reimprimir (
    folio INTEGER PRIMARY KEY,
    tipo_documento VARCHAR(30) NOT NULL,
    fecha DATE NOT NULL,
    contribuyente VARCHAR(200) NOT NULL,
    dependencia VARCHAR(100) NOT NULL,
    id_dependencia INTEGER NOT NULL,
    axo_acta INTEGER NOT NULL,
    num_acta VARCHAR(50) NOT NULL,
    importe NUMERIC(12,2) NOT NULL,
    estatus VARCHAR(30) NOT NULL
);

CREATE INDEX idx_documentos_tipo ON publico.documentos_reimprimir(tipo_documento);
CREATE INDEX idx_documentos_dependencia ON publico.documentos_reimprimir(id_dependencia);
CREATE INDEX idx_documentos_fecha ON publico.documentos_reimprimir(fecha);
CREATE INDEX idx_documentos_estatus ON publico.documentos_reimprimir(estatus);
";

$pdo->exec($sql);
echo "✅ Tabla documentos_reimprimir creada\n\n";

// Datos de prueba
$documentos = [
    // MULTAS - Dependencia 3 (Tránsito)
    ['folio' => 415010, 'tipo' => 'multa', 'fecha' => '2025-01-15', 'contrib' => 'JUAN CARLOS MARTINEZ LOPEZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001234', 'importe' => 1500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 415011, 'tipo' => 'multa', 'fecha' => '2025-01-20', 'contrib' => 'MARIA ELENA RODRIGUEZ GARCIA', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001235', 'importe' => 2000.00, 'estatus' => 'PAGADO'],
    ['folio' => 415012, 'tipo' => 'multa', 'fecha' => '2025-02-10', 'contrib' => 'ROBERTO SANCHEZ HERNANDEZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001236', 'importe' => 1800.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 415013, 'tipo' => 'multa', 'fecha' => '2025-03-05', 'contrib' => 'LAURA PATRICIA MENDEZ FLORES', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001237', 'importe' => 3500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 415014, 'tipo' => 'multa', 'fecha' => '2025-03-12', 'contrib' => 'JOSE LUIS GOMEZ RAMIREZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001238', 'importe' => 2500.00, 'estatus' => 'PAGADO'],
    ['folio' => 415015, 'tipo' => 'multa', 'fecha' => '2025-04-18', 'contrib' => 'DIANA CAROLINA TORRES CRUZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001239', 'importe' => 1200.00, 'estatus' => 'CANCELADO'],
    ['folio' => 415016, 'tipo' => 'multa', 'fecha' => '2025-05-22', 'contrib' => 'PEDRO ALEJANDRO CHAVEZ MORALES', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001240', 'importe' => 1750.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 415017, 'tipo' => 'multa', 'fecha' => '2025-06-08', 'contrib' => 'ANA GABRIELA VARGAS SANTOS', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001241', 'importe' => 2200.00, 'estatus' => 'PAGADO'],
    ['folio' => 415018, 'tipo' => 'multa', 'fecha' => '2025-07-14', 'contrib' => 'CARLOS EDUARDO JIMENEZ ORTIZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001242', 'importe' => 1900.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 415019, 'tipo' => 'multa', 'fecha' => '2025-08-03', 'contrib' => 'SOFIA ALEJANDRA RUIZ PEREZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001243', 'importe' => 1600.00, 'estatus' => 'PAGADO'],

    // MULTAS - Dependencia 7 (Reglamentos)
    ['folio' => 515001, 'tipo' => 'multa', 'fecha' => '2025-01-25', 'contrib' => 'COMERCIAL LA GUADALUPANA SA DE CV', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002100', 'importe' => 5000.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 515002, 'tipo' => 'multa', 'fecha' => '2025-02-15', 'contrib' => 'RESTAURANTE EL TAPATIO SC', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002101', 'importe' => 3500.00, 'estatus' => 'PAGADO'],
    ['folio' => 515003, 'tipo' => 'multa', 'fecha' => '2025-03-20', 'contrib' => 'TIENDA DE ABARROTES DON JOSE', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002102', 'importe' => 2500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 515004, 'tipo' => 'multa', 'fecha' => '2025-04-10', 'contrib' => 'FARMACIA GUADALAJARA SA', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002103', 'importe' => 4000.00, 'estatus' => 'PAGADO'],
    ['folio' => 515005, 'tipo' => 'multa', 'fecha' => '2025-05-05', 'contrib' => 'BAR Y CANTINA LA PERLA', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002104', 'importe' => 8500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 515006, 'tipo' => 'multa', 'fecha' => '2025-06-18', 'contrib' => 'CARNICERIA Y POLLERIA LOS ARCOS', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002105', 'importe' => 3000.00, 'estatus' => 'CANCELADO'],
    ['folio' => 515007, 'tipo' => 'multa', 'fecha' => '2025-07-22', 'contrib' => 'PANADERIA SAN MARTIN', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002106', 'importe' => 2800.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 515008, 'tipo' => 'multa', 'fecha' => '2025-08-12', 'contrib' => 'CENTRO COMERCIAL PLAZA DEL SOL', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002107', 'importe' => 12000.00, 'estatus' => 'PAGADO'],
    ['folio' => 515009, 'tipo' => 'multa', 'fecha' => '2025-09-08', 'contrib' => 'TALLER MECANICO LOPEZ Y ASOCIADOS', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002108', 'importe' => 4500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 515010, 'tipo' => 'multa', 'fecha' => '2025-10-15', 'contrib' => 'CLINICA DENTAL SMILE', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002109', 'importe' => 3200.00, 'estatus' => 'PAGADO'],

    // RECIBOS - Dependencia 3 (Tránsito)
    ['folio' => 610001, 'tipo' => 'recibo', 'fecha' => '2025-01-18', 'contrib' => 'MARIA ELENA RODRIGUEZ GARCIA', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REC-001235', 'importe' => 2000.00, 'estatus' => 'PAGADO'],
    ['folio' => 610002, 'tipo' => 'recibo', 'fecha' => '2025-03-10', 'contrib' => 'JOSE LUIS GOMEZ RAMIREZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REC-001238', 'importe' => 2500.00, 'estatus' => 'PAGADO'],
    ['folio' => 610003, 'tipo' => 'recibo', 'fecha' => '2025-06-05', 'contrib' => 'ANA GABRIELA VARGAS SANTOS', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REC-001241', 'importe' => 2200.00, 'estatus' => 'PAGADO'],
    ['folio' => 610004, 'tipo' => 'recibo', 'fecha' => '2025-07-28', 'contrib' => 'SOFIA ALEJANDRA RUIZ PEREZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REC-001243', 'importe' => 1600.00, 'estatus' => 'PAGADO'],

    // RECIBOS - Dependencia 7 (Reglamentos)
    ['folio' => 710001, 'tipo' => 'recibo', 'fecha' => '2025-02-12', 'contrib' => 'RESTAURANTE EL TAPATIO SC', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REC-002101', 'importe' => 3500.00, 'estatus' => 'PAGADO'],
    ['folio' => 710002, 'tipo' => 'recibo', 'fecha' => '2025-04-08', 'contrib' => 'FARMACIA GUADALAJARA SA', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REC-002103', 'importe' => 4000.00, 'estatus' => 'PAGADO'],
    ['folio' => 710003, 'tipo' => 'recibo', 'fecha' => '2025-08-09', 'contrib' => 'CENTRO COMERCIAL PLAZA DEL SOL', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REC-002107', 'importe' => 12000.00, 'estatus' => 'PAGADO'],
    ['folio' => 710004, 'tipo' => 'recibo', 'fecha' => '2025-10-12', 'contrib' => 'CLINICA DENTAL SMILE', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REC-002109', 'importe' => 3200.00, 'estatus' => 'PAGADO'],

    // REQUERIMIENTOS - Dependencia 3 (Tránsito)
    ['folio' => 810001, 'tipo' => 'requerimiento', 'fecha' => '2025-02-20', 'contrib' => 'JUAN CARLOS MARTINEZ LOPEZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REQ-001234', 'importe' => 1500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 810002, 'tipo' => 'requerimiento', 'fecha' => '2025-03-15', 'contrib' => 'ROBERTO SANCHEZ HERNANDEZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REQ-001236', 'importe' => 1800.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 810003, 'tipo' => 'requerimiento', 'fecha' => '2025-04-10', 'contrib' => 'LAURA PATRICIA MENDEZ FLORES', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REQ-001237', 'importe' => 3500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 810004, 'tipo' => 'requerimiento', 'fecha' => '2025-06-25', 'contrib' => 'PEDRO ALEJANDRO CHAVEZ MORALES', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REQ-001240', 'importe' => 1750.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 810005, 'tipo' => 'requerimiento', 'fecha' => '2025-08-18', 'contrib' => 'CARLOS EDUARDO JIMENEZ ORTIZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => 'REQ-001242', 'importe' => 1900.00, 'estatus' => 'PENDIENTE'],

    // REQUERIMIENTOS - Dependencia 7 (Reglamentos)
    ['folio' => 910001, 'tipo' => 'requerimiento', 'fecha' => '2025-03-01', 'contrib' => 'COMERCIAL LA GUADALUPANA SA DE CV', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REQ-002100', 'importe' => 5000.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 910002, 'tipo' => 'requerimiento', 'fecha' => '2025-04-22', 'contrib' => 'TIENDA DE ABARROTES DON JOSE', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REQ-002102', 'importe' => 2500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 910003, 'tipo' => 'requerimiento', 'fecha' => '2025-06-10', 'contrib' => 'BAR Y CANTINA LA PERLA', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REQ-002104', 'importe' => 8500.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 910004, 'tipo' => 'requerimiento', 'fecha' => '2025-08-28', 'contrib' => 'PANADERIA SAN MARTIN', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REQ-002106', 'importe' => 2800.00, 'estatus' => 'PENDIENTE'],
    ['folio' => 910005, 'tipo' => 'requerimiento', 'fecha' => '2025-10-05', 'contrib' => 'TALLER MECANICO LOPEZ Y ASOCIADOS', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => 'REQ-002108', 'importe' => 4500.00, 'estatus' => 'PENDIENTE'],

    // ACTAS ADMINISTRATIVAS - Dependencia 3 (Tránsito)
    ['folio' => 111001, 'tipo' => 'acta', 'fecha' => '2025-01-10', 'contrib' => 'JUAN CARLOS MARTINEZ LOPEZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001234', 'importe' => 1500.00, 'estatus' => 'ACTIVA'],
    ['folio' => 111002, 'tipo' => 'acta', 'fecha' => '2025-01-15', 'contrib' => 'MARIA ELENA RODRIGUEZ GARCIA', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001235', 'importe' => 2000.00, 'estatus' => 'CERRADA'],
    ['folio' => 111003, 'tipo' => 'acta', 'fecha' => '2025-02-05', 'contrib' => 'ROBERTO SANCHEZ HERNANDEZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001236', 'importe' => 1800.00, 'estatus' => 'ACTIVA'],
    ['folio' => 111004, 'tipo' => 'acta', 'fecha' => '2025-02-28', 'contrib' => 'LAURA PATRICIA MENDEZ FLORES', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001237', 'importe' => 3500.00, 'estatus' => 'ACTIVA'],
    ['folio' => 111005, 'tipo' => 'acta', 'fecha' => '2025-03-08', 'contrib' => 'JOSE LUIS GOMEZ RAMIREZ', 'dep' => '3 - Tránsito', 'id_dep' => 3, 'axo' => 2025, 'num' => '001238', 'importe' => 2500.00, 'estatus' => 'CERRADA'],

    // ACTAS ADMINISTRATIVAS - Dependencia 7 (Reglamentos)
    ['folio' => 211001, 'tipo' => 'acta', 'fecha' => '2025-01-20', 'contrib' => 'COMERCIAL LA GUADALUPANA SA DE CV', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002100', 'importe' => 5000.00, 'estatus' => 'ACTIVA'],
    ['folio' => 211002, 'tipo' => 'acta', 'fecha' => '2025-02-10', 'contrib' => 'RESTAURANTE EL TAPATIO SC', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002101', 'importe' => 3500.00, 'estatus' => 'CERRADA'],
    ['folio' => 211003, 'tipo' => 'acta', 'fecha' => '2025-03-15', 'contrib' => 'TIENDA DE ABARROTES DON JOSE', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002102', 'importe' => 2500.00, 'estatus' => 'ACTIVA'],
    ['folio' => 211004, 'tipo' => 'acta', 'fecha' => '2025-04-05', 'contrib' => 'FARMACIA GUADALAJARA SA', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002103', 'importe' => 4000.00, 'estatus' => 'CERRADA'],
    ['folio' => 211005, 'tipo' => 'acta', 'fecha' => '2025-05-01', 'contrib' => 'BAR Y CANTINA LA PERLA', 'dep' => '7 - Reglamentos', 'id_dep' => 7, 'axo' => 2025, 'num' => '002104', 'importe' => 8500.00, 'estatus' => 'ACTIVA'],
];

// Insertar datos
$stmt = $pdo->prepare("
    INSERT INTO publico.documentos_reimprimir
    (folio, tipo_documento, fecha, contribuyente, dependencia, id_dependencia, axo_acta, num_acta, importe, estatus)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
");

$count = 0;
foreach ($documentos as $doc) {
    $stmt->execute([
        $doc['folio'],
        $doc['tipo'],
        $doc['fecha'],
        $doc['contrib'],
        $doc['dep'],
        $doc['id_dep'],
        $doc['axo'],
        $doc['num'],
        $doc['importe'],
        $doc['estatus']
    ]);
    $count++;
}

echo "✅ Insertados $count documentos de prueba\n\n";

// Estadísticas
$stats = $pdo->query("
    SELECT
        tipo_documento,
        COUNT(*) as cantidad,
        SUM(importe) as total_importe
    FROM publico.documentos_reimprimir
    GROUP BY tipo_documento
    ORDER BY tipo_documento
")->fetchAll(PDO::FETCH_ASSOC);

echo "=== ESTADÍSTICAS ===\n";
foreach ($stats as $stat) {
    echo "  {$stat['tipo_documento']}: {$stat['cantidad']} documentos, Total: $" . number_format($stat['total_importe'], 2) . "\n";
}

echo "\n✅ Tabla documentos_reimprimir lista!\n";
