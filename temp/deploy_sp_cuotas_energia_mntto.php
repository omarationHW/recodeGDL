<?php
/**
 * Script para desplegar los 4 SPs de CuotasEnergiaMntto a la base de datos mercados
 * Fecha: 2025-12-02
 */

echo "=== DESPLIEGUE DE SPs CUOTAS ENERGÍA MNTTO ===\n\n";

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a la base de datos '$dbname'\n\n";
    $pdo->exec("SET search_path TO public");
    echo "✓ search_path establecido a 'public'\n\n";

    $stored_procedures = [
        [
            'name' => 'sp_insert_cuota_energia',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
DECLARE
    v_id_kilowhatts integer;
    v_axo integer;
    v_periodo integer;
    v_importe numeric;
    v_fecha_alta timestamp;
    v_id_usuario integer;
BEGIN
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario
    INTO v_id_kilowhatts, v_axo, v_periodo, v_importe, v_fecha_alta, v_id_usuario;

    RETURN QUERY SELECT v_id_kilowhatts, v_axo, v_periodo, v_importe, v_fecha_alta, v_id_usuario;
END;
\$\$ LANGUAGE plpgsql;
            "
        ],
        [
            'name' => 'sp_update_cuota_energia',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo integer, p_periodo integer, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
DECLARE
    v_id_kilowhatts integer;
    v_axo integer;
    v_periodo integer;
    v_importe numeric;
    v_fecha_alta timestamp;
    v_id_usuario integer;
BEGIN
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE ta_11_kilowhatts.id_kilowhatts = p_id_kilowhatts
      AND ta_11_kilowhatts.axo = p_axo
      AND ta_11_kilowhatts.periodo = p_periodo
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario
    INTO v_id_kilowhatts, v_axo, v_periodo, v_importe, v_fecha_alta, v_id_usuario;

    RETURN QUERY SELECT v_id_kilowhatts, v_axo, v_periodo, v_importe, v_fecha_alta, v_id_usuario;
END;
\$\$ LANGUAGE plpgsql;
            "
        ],
        [
            'name' => 'sp_get_cuota_energia',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT k.id_kilowhatts, k.axo, k.periodo, k.importe, k.fecha_alta, k.id_usuario
    FROM public.ta_11_kilowhatts k
    WHERE k.id_kilowhatts = p_id_kilowhatts;
END;
\$\$ LANGUAGE plpgsql;
            "
        ],
        [
            'name' => 'sp_list_cuotas_energia',
            'sql' => "
CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo integer DEFAULT NULL, p_periodo integer DEFAULT NULL)
RETURNS TABLE (
    id_kilowhatts integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'N/A') AS usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN padron_licencias.comun.ta_12_passwords u ON k.id_usuario = u.id_usuario
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
\$\$ LANGUAGE plpgsql;
            "
        ]
    ];

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

    echo "\n=== VERIFICACIÓN DE SPs DESPLEGADOS ===\n\n";

    $verify_sql = "
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name IN ('sp_insert_cuota_energia', 'sp_update_cuota_energia', 'sp_get_cuota_energia', 'sp_list_cuotas_energia')
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
