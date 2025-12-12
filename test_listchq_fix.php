<?php
// Script para crear tabla cheques y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listchq(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de cheques
    echo "2. Creando tabla publico.cheques...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.cheques CASCADE");

    $sql = "
    CREATE TABLE publico.cheques (
        id_cheque SERIAL PRIMARY KEY,
        fecha DATE NOT NULL,
        banco VARCHAR(100) NOT NULL,
        cheque VARCHAR(50) NOT NULL,
        cuenta VARCHAR(50) NOT NULL,
        importe NUMERIC(12,2) NOT NULL,
        tipo_pag VARCHAR(50) NOT NULL,
        folio_completo VARCHAR(100) NOT NULL,
        id_rec VARCHAR(50) NOT NULL,
        caja VARCHAR(50) NOT NULL,
        operacion INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de cheques
    echo "3. Insertando 50 registros de cheques...\n";

    $bancos = [
        'BBVA BANCOMER',
        'SANTANDER',
        'BANAMEX',
        'HSBC',
        'SCOTIABANK',
        'BANORTE',
        'INBURSA',
        'AZTECA'
    ];

    $tipos_pago = ['Efectivo', 'Cheque', 'Tarjeta', 'Transferencia'];
    $cajas = ['CAJA-01', 'CAJA-02', 'CAJA-03', 'CAJA-04', 'CAJA-05'];

    $stmt = $pdo->prepare("
        INSERT INTO publico.cheques
        (fecha, banco, cheque, cuenta, importe, tipo_pag, folio_completo, id_rec, caja, operacion)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 50; $i++) {
        // Fecha: últimos 60 días
        $fecha = clone $hoy;
        $dias_atras = rand(1, 60);
        $fecha->modify("-{$dias_atras} days");

        $banco = $bancos[$i % 8];

        // Número de cheque (solo para tipo Cheque)
        $tipo_pag = $tipos_pago[$i % 4];
        if ($tipo_pag === 'Cheque') {
            $cheque = str_pad(1000 + $i, 8, '0', STR_PAD_LEFT);
        } else {
            $cheque = 'N/A';
        }

        $cuenta = "CTA-" . str_pad(100 + ($i % 20), 6, '0', STR_PAD_LEFT);

        // Importe aleatorio entre 500 y 10000
        $importe = 500.00 + ($i * 185.50);
        if ($importe > 10000) $importe = 10000 - (($i % 10) * 50);

        $folio_completo = "FOL-" . date('Y') . "-" . str_pad($i, 6, '0', STR_PAD_LEFT);
        $id_rec = "REC-" . str_pad($i * 10, 5, '0', STR_PAD_LEFT);
        $caja = $cajas[$i % 5];
        $operacion = 1000 + $i;

        $stmt->execute([
            $fecha->format('Y-m-d'),
            $banco,
            $cheque,
            $cuenta,
            $importe,
            $tipo_pag,
            $folio_completo,
            $id_rec,
            $caja,
            $operacion
        ]);
    }
    echo "   ✓ 50 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - 8 bancos diferentes\n";
    echo "   - Tipos de pago: Efectivo, Cheque, Tarjeta, Transferencia\n";
    echo "   - 5 cajas diferentes\n";
    echo "   - Fechas de los últimos 60 días\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_cheques_fecha ON publico.cheques(fecha DESC)");
    $pdo->exec("CREATE INDEX idx_cheques_banco ON publico.cheques(banco)");
    $pdo->exec("CREATE INDEX idx_cheques_cheque ON publico.cheques(cheque)");
    $pdo->exec("CREATE INDEX idx_cheques_cuenta ON publico.cheques(cuenta)");
    $pdo->exec("CREATE INDEX idx_cheques_folio ON publico.cheques(folio_completo)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_listchq...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listchq(
        p_filtro VARCHAR
    )
    RETURNS TABLE (
        fecha DATE,
        banco VARCHAR,
        cheque VARCHAR,
        cuenta VARCHAR,
        importe NUMERIC,
        tipo_pag VARCHAR,
        folio_completo VARCHAR,
        id_rec VARCHAR,
        caja VARCHAR,
        operacion INTEGER
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            c.fecha,
            c.banco,
            c.cheque,
            c.cuenta,
            c.importe,
            c.tipo_pag,
            c.folio_completo,
            c.id_rec,
            c.caja,
            c.operacion
        FROM publico.cheques c
        WHERE
            p_filtro = '' OR p_filtro IS NULL
            OR c.banco ILIKE '%' || p_filtro || '%'
            OR c.cheque ILIKE '%' || p_filtro || '%'
            OR c.cuenta ILIKE '%' || p_filtro || '%'
            OR c.folio_completo ILIKE '%' || p_filtro || '%'
            OR c.tipo_pag ILIKE '%' || p_filtro || '%'
            OR CAST(c.operacion AS TEXT) ILIKE '%' || p_filtro || '%'
        ORDER BY c.fecha DESC, c.id_cheque DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todos los cheques (sin filtro)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Filtrar por banco BBVA',
            'filtro' => 'BBVA'
        ],
        [
            'nombre' => 'Filtrar por tipo de pago Cheque',
            'filtro' => 'Cheque'
        ],
        [
            'nombre' => 'Filtrar por cuenta CTA-000100',
            'filtro' => 'CTA-000100'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listchq(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " cheque(s)\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - Fecha: " . $row['fecha'] .
                     " | Banco: " . $row['banco'] .
                     " | Cheque: " . $row['cheque'] .
                     " | Cuenta: " . $row['cuenta'] .
                     " | Importe: $" . number_format($row['importe'], 2) .
                     " | Tipo: " . $row['tipo_pag'] .
                     " | Folio: " . $row['folio_completo'] .
                     " | Caja: " . $row['caja'] .
                     " | Op: " . $row['operacion'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla cheques creada con 50 registros\n";
    echo "   - Bancos: BBVA, Santander, Banamex, HSBC, Scotiabank, Banorte, Inbursa, Azteca\n";
    echo "   - Tipos de pago: Efectivo, Cheque, Tarjeta, Transferencia\n";
    echo "   - Importes variados desde $500 hasta $10,000\n";
    echo "   - 5 cajas diferentes (CAJA-01 a CAJA-05)\n";
    echo "   - SP recaudadora_listchq creado\n";
    echo "   - Búsqueda por: banco, cheque, cuenta, folio, tipo de pago, operación\n";
    echo "   - Ordenado por fecha más reciente primero\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
