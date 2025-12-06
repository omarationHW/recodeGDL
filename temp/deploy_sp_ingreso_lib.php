<?php
/**
 * Script para desplegar los 4 SPs de IngresoLib a la base de datos mercados
 * Fecha: 2025-12-01
 */

echo "=== DESPLIEGUE DE SPs INGRESO LIBERTAD ===\n\n";

// Configuración de conexión desde el archivo de Laravel
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    // Conectar a PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a la base de datos '$dbname'\n\n";

    // Establecer search_path
    $pdo->exec("SET search_path TO public");
    echo "✓ search_path establecido a 'public'\n\n";

    // Array con los 4 SPs
    $stored_procedures = [
        [
            'name' => 'sp_get_mercados',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    descripcion varchar,
    cuenta_ingreso integer
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT ta.oficina, ta.num_mercado_nvo, ta.descripcion, ta.cuenta_ingreso
    FROM padron_licencias.comun.ta_11_mercados ta
    WHERE ta.tipo_emision = 'D'
    ORDER BY ta.num_mercado_nvo;
END;
\$\$ LANGUAGE plpgsql;
            "
        ],
        [
            'name' => 'sp_get_ingresos_libertad',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_get_ingresos_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    fecha_pago date,
    caja_pago varchar,
    pagos integer,
    importe numeric
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT b.fecha_pago, b.caja_pago, CAST(COUNT(*) AS INTEGER) AS pagos, SUM(b.importe_pago) AS importe
    FROM padron_licencias.comun.ta_11_locales a
    JOIN padron_licencias.comun.ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio
    GROUP BY b.fecha_pago, b.caja_pago
    ORDER BY b.fecha_pago, b.caja_pago;
END;
\$\$ LANGUAGE plpgsql;
            "
        ],
        [
            'name' => 'sp_get_cajas_libertad',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_get_cajas_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    caja_pago varchar,
    pagos integer,
    importe numeric
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT b.caja_pago, CAST(COUNT(*) AS INTEGER) AS pagos, SUM(b.importe_pago) AS importe
    FROM padron_licencias.comun.ta_11_locales a
    JOIN padron_licencias.comun.ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio
    GROUP BY b.caja_pago
    ORDER BY b.caja_pago;
END;
\$\$ LANGUAGE plpgsql;
            "
        ],
        [
            'name' => 'sp_get_totals_libertad',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_get_totals_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    total_pagos integer,
    total_importe numeric
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT CAST(COUNT(*) AS INTEGER) AS total_pagos, COALESCE(SUM(b.importe_pago),0) AS total_importe
    FROM padron_licencias.comun.ta_11_locales a
    JOIN padron_licencias.comun.ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio;
END;
\$\$ LANGUAGE plpgsql;
            "
        ]
    ];

    // Desplegar cada SP
    $success_count = 0;
    $error_count = 0;

    foreach ($stored_procedures as $sp) {
        echo "Desplegando SP: {$sp['name']}...\n";

        try {
            $pdo->exec($sp['sql']);
            echo "  ✓ SP '{$sp['name']}' desplegado exitosamente\n";
            $success_count++;
        } catch (PDOException $e) {
            echo "  ✗ Error al desplegar '{$sp['name']}': " . $e->getMessage() . "\n";
            $error_count++;
        }

        echo "\n";
    }

    // Verificar que los SPs fueron creados
    echo "\n=== VERIFICACIÓN DE SPs DESPLEGADOS ===\n\n";

    $verify_sql = "
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name IN ('sp_get_mercados', 'sp_get_ingresos_libertad', 'sp_get_cajas_libertad', 'sp_get_totals_libertad')
        ORDER BY routine_name
    ";

    $stmt = $pdo->query($verify_sql);
    $deployed_sps = $stmt->fetchAll();

    if (count($deployed_sps) > 0) {
        echo "SPs encontrados en el esquema 'public':\n";
        foreach ($deployed_sps as $sp) {
            echo "  ✓ {$sp['routine_name']} ({$sp['routine_type']})\n";
        }
    } else {
        echo "⚠ No se encontraron SPs en el esquema 'public'\n";
    }

    // Resumen
    echo "\n=== RESUMEN DEL DESPLIEGUE ===\n";
    echo "Total SPs procesados: " . count($stored_procedures) . "\n";
    echo "SPs exitosos: $success_count\n";
    echo "SPs con error: $error_count\n";
    echo "SPs verificados en BD: " . count($deployed_sps) . "\n";

    if ($success_count == count($stored_procedures) && count($deployed_sps) == count($stored_procedures)) {
        echo "\n✓✓✓ DESPLIEGUE COMPLETADO EXITOSAMENTE ✓✓✓\n";
    } else {
        echo "\n⚠ DESPLIEGUE COMPLETADO CON ADVERTENCIAS\n";
    }

} catch (PDOException $e) {
    echo "✗ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
