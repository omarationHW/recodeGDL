<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

echo "=== Recreando SPs de DatosConvenio ===\n\n";

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

// Primero eliminar las funciones existentes
$drops = [
    "DROP FUNCTION IF EXISTS sp_get_datos_convenio(integer)",
    "DROP FUNCTION IF EXISTS sp_get_convenio_parciales(integer)"
];

foreach ($drops as $sql) {
    try {
        $pdo->exec($sql);
        echo "DROP: OK\n";
    } catch (PDOException $e) {
        echo "DROP SKIP: " . $e->getMessage() . "\n";
    }
}

$sps = [
    'sp_get_datos_convenio' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_datos_convenio(p_id_conv INTEGER)
RETURNS TABLE (
    id_convenio INTEGER,
    colonia SMALLINT,
    calle SMALLINT,
    folio INTEGER,
    nombre VARCHAR(60),
    desc_calle VARCHAR(50),
    numero VARCHAR(11),
    tipo_casa VARCHAR(1),
    metros2 NUMERIC,
    pago_total NUMERIC,
    pago_inicial NUMERIC,
    pago_quincenal NUMERIC,
    pagos_parciales SMALLINT,
    fecha_firma DATE,
    fecha_vencimiento DATE,
    observacion VARCHAR(60),
    vigencia CHAR(1),
    estado VARCHAR(20),
    tipodesc VARCHAR(20),
    periodos VARCHAR(50),
    recargos_conv NUMERIC,
    saldo_insoluto NUMERIC,
    impobra_conv NUMERIC,
    usuario VARCHAR(20),
    fecha_actual TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_convenio,
        c.colonia,
        c.calle,
        c.folio,
        c.nombre,
        c.desc_calle,
        c.numero,
        c.tipo_casa,
        c.metros2,
        c.pago_total,
        c.pago_inicial,
        c.pago_quincenal,
        c.pagos_parciales,
        c.fecha_firma,
        c.fecha_vencimiento,
        c.observacion,
        c.vigencia,
        CASE
            WHEN c.vigencia = 'V' THEN 'VIGENTE'
            WHEN c.vigencia = 'C' THEN 'CANCELADO'
            WHEN c.vigencia = 'P' THEN 'PAGADO'
            WHEN c.vigencia = 'B' THEN 'BAJA'
            ELSE 'VIGENTE'
        END::VARCHAR(20) as estado,
        'QUINCENAL'::VARCHAR(20) as tipodesc,
        (COALESCE(c.fecha_firma::text, '') || ' - ' || COALESCE(c.fecha_vencimiento::text, ''))::VARCHAR(50) as periodos,
        c.recargos_conv,
        c.saldo_insoluto,
        c.impobra_conv,
        COALESCE(u.usuario, 'N/A')::VARCHAR(20) as usuario,
        c.fecha_actual
    FROM ta_17_convenios c
    LEFT JOIN usuarios u ON c.id_usuario = u.id
    WHERE c.id_convenio = p_id_conv;
END;
$$ LANGUAGE plpgsql;
SQL,

    'sp_get_convenio_parciales' => <<<'SQL'
CREATE OR REPLACE FUNCTION sp_get_convenio_parciales(p_id_conv INTEGER)
RETURNS TABLE (
    id_pago INTEGER,
    pago_parcial SMALLINT,
    total_parciales SMALLINT,
    importe NUMERIC,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER,
    descparc VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_pago,
        p.pago_parcial,
        p.total_parciales,
        p.importe,
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.operacion_pago,
        CASE
            WHEN p.pago_parcial = 1 THEN 'INICIAL'
            WHEN p.pago_parcial = p.total_parciales THEN 'FINAL'
            ELSE 'PARCIAL'
        END::VARCHAR(20) as descparc
    FROM ta_17_pagos p
    WHERE p.id_convenio = p_id_conv
    ORDER BY p.pago_parcial;
END;
$$ LANGUAGE plpgsql;
SQL

];

foreach ($sps as $nombre => $sql) {
    echo "Creando {$nombre}... ";
    try {
        $pdo->exec($sql);
        echo "OK\n";
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}

// Probar con un convenio existente
echo "\n=== Probando con un convenio existente ===\n";
$stmt = $pdo->query("SELECT id_convenio FROM ta_17_convenios LIMIT 1");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if ($row) {
    $id = $row['id_convenio'];
    echo "Probando con id_convenio = {$id}\n";

    echo "\n--- sp_get_datos_convenio({$id}) ---\n";
    try {
        $stmt = $pdo->query("SELECT * FROM sp_get_datos_convenio({$id})");
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($data) {
            echo "Nombre: {$data['nombre']}\n";
            echo "Calle: {$data['desc_calle']} #{$data['numero']}\n";
            echo "Pago Total: {$data['pago_total']}\n";
            echo "Estado: {$data['estado']}\n";
        } else {
            echo "(sin datos)\n";
        }
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }

    echo "\n--- sp_get_convenio_parciales({$id}) ---\n";
    try {
        $stmt = $pdo->query("SELECT * FROM sp_get_convenio_parciales({$id})");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Parcialidades encontradas: " . count($rows) . "\n";
    } catch (PDOException $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}
