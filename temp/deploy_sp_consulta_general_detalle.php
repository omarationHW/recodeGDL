<?php
/**
 * Script para desplegar SPs de detalle de Consulta General
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n=== DESPLEGANDO SPs DE CONSULTA GENERAL - DETALLE ===\n\n";

    // Verificar si ta_usuario existe para el JOIN
    echo "1. Verificando tabla ta_usuario...\n";
    $sql = "SELECT to_regclass('publico.ta_usuario')";
    $result = $pdo->query($sql)->fetchColumn();
    $tiene_ta_usuario = ($result !== null);
    echo ($tiene_ta_usuario ? "✅" : "⚠️ ") . " Tabla ta_usuario " . ($tiene_ta_usuario ? "existe" : "no existe - se usará id_usuario directamente") . "\n\n";

    // SP 1: Adeudos
    echo "2. Desplegando sp_consulta_general_adeudos...\n";
    $sql_adeudos = "
    DROP FUNCTION IF EXISTS sp_consulta_general_adeudos(INTEGER);

    CREATE OR REPLACE FUNCTION sp_consulta_general_adeudos(
        p_id_local INTEGER
    ) RETURNS TABLE(
        axo SMALLINT,
        periodo SMALLINT,
        importe NUMERIC(10,2),
        recargos NUMERIC(10,2)
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            a.axo::SMALLINT,
            a.periodo::SMALLINT,
            COALESCE(a.importe, 0)::NUMERIC(10,2) as importe,
            0::NUMERIC(10,2) as recargos
        FROM publico.ta_11_adeudo_local a
        WHERE a.id_local = p_id_local
        ORDER BY a.axo DESC, a.periodo DESC
        LIMIT 100;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql_adeudos);
    echo "✅ sp_consulta_general_adeudos desplegado\n\n";

    // SP 2: Pagos (con o sin JOIN según disponibilidad)
    echo "3. Desplegando sp_consulta_general_pagos...\n";

    if ($tiene_ta_usuario) {
        $sql_pagos = "
        DROP FUNCTION IF EXISTS sp_consulta_general_pagos(INTEGER);

        CREATE OR REPLACE FUNCTION sp_consulta_general_pagos(
            p_id_local INTEGER
        ) RETURNS TABLE(
            axo SMALLINT,
            periodo SMALLINT,
            fecha_pago DATE,
            importe_pago NUMERIC(10,2),
            folio VARCHAR(30),
            usuario VARCHAR(30)
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                p.axo::SMALLINT,
                p.periodo::SMALLINT,
                p.fecha_pago::DATE,
                COALESCE(p.importe_pago, 0)::NUMERIC(10,2) as importe_pago,
                COALESCE(TRIM(p.folio), '')::VARCHAR(30) as folio,
                COALESCE(u.usuario, p.id_usuario::VARCHAR)::VARCHAR(30) as usuario
            FROM publico.ta_11_pagos_local p
            LEFT JOIN publico.ta_usuario u ON p.id_usuario = u.id_usuario
            WHERE p.id_local = p_id_local
            ORDER BY p.fecha_pago DESC, p.axo DESC, p.periodo DESC
            LIMIT 100;
        END;
        \$\$ LANGUAGE plpgsql;
        ";
    } else {
        $sql_pagos = "
        DROP FUNCTION IF EXISTS sp_consulta_general_pagos(INTEGER);

        CREATE OR REPLACE FUNCTION sp_consulta_general_pagos(
            p_id_local INTEGER
        ) RETURNS TABLE(
            axo SMALLINT,
            periodo SMALLINT,
            fecha_pago DATE,
            importe_pago NUMERIC(10,2),
            folio VARCHAR(30),
            usuario VARCHAR(30)
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                p.axo::SMALLINT,
                p.periodo::SMALLINT,
                p.fecha_pago::DATE,
                COALESCE(p.importe_pago, 0)::NUMERIC(10,2) as importe_pago,
                COALESCE(TRIM(p.folio), '')::VARCHAR(30) as folio,
                COALESCE(p.id_usuario::VARCHAR, '')::VARCHAR(30) as usuario
            FROM publico.ta_11_pagos_local p
            WHERE p.id_local = p_id_local
            ORDER BY p.fecha_pago DESC, p.axo DESC, p.periodo DESC
            LIMIT 100;
        END;
        \$\$ LANGUAGE plpgsql;
        ";
    }

    $pdo->exec($sql_pagos);
    echo "✅ sp_consulta_general_pagos desplegado\n\n";

    // SP 3: Requerimientos (stub)
    echo "4. Desplegando sp_consulta_general_requerimientos...\n";
    $sql_requerimientos = "
    DROP FUNCTION IF EXISTS sp_consulta_general_requerimientos(INTEGER);

    CREATE OR REPLACE FUNCTION sp_consulta_general_requerimientos(
        p_id_local INTEGER
    ) RETURNS TABLE(
        folio VARCHAR(20),
        fecha_emision DATE,
        importe_multa NUMERIC(10,2),
        importe_gastos NUMERIC(10,2),
        vigencia VARCHAR(10)
    ) AS \$\$
    BEGIN
        -- Por ahora retorna vacío
        RETURN;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql_requerimientos);
    echo "✅ sp_consulta_general_requerimientos desplegado\n\n";

    // Verificar despliegue
    echo "5. Verificando SPs creados...\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT
            proname as nombre_sp,
            pg_get_function_arguments(oid) as argumentos
        FROM pg_proc
        WHERE proname IN (
            'sp_consulta_general_adeudos',
            'sp_consulta_general_pagos',
            'sp_consulta_general_requerimientos'
        )
        ORDER BY proname
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll();

    foreach ($sps as $sp) {
        echo "✅ {$sp['nombre_sp']}({$sp['argumentos']})\n";
    }

    // Probar los SPs con datos reales
    echo "\n6. PROBANDO LOS SPs CON DATOS REALES...\n";
    echo str_repeat("-", 80) . "\n";

    $id_local = 11256;

    echo "\nTEST: sp_consulta_general_adeudos($id_local)\n";
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_adeudos($id_local) LIMIT 3");
    $adeudos = $stmt->fetchAll();
    if (count($adeudos) > 0) {
        echo "✅ Retornó " . count($adeudos) . " adeudos\n";
        foreach ($adeudos as $a) {
            echo "   - Año: {$a['axo']}, Periodo: {$a['periodo']}, Importe: \${$a['importe']}\n";
        }
    } else {
        echo "⚠️  No hay adeudos para este local\n";
    }

    echo "\nTEST: sp_consulta_general_pagos($id_local)\n";
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_pagos($id_local) LIMIT 3");
    $pagos = $stmt->fetchAll();
    if (count($pagos) > 0) {
        echo "✅ Retornó " . count($pagos) . " pagos\n";
        foreach ($pagos as $p) {
            echo "   - Año: {$p['axo']}, Periodo: {$p['periodo']}, Fecha: {$p['fecha_pago']}, Importe: \${$p['importe_pago']}\n";
        }
    } else {
        echo "⚠️  No hay pagos para este local\n";
    }

    echo "\nTEST: sp_consulta_general_requerimientos($id_local)\n";
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_requerimientos($id_local)");
    $reqs = $stmt->fetchAll();
    echo "✅ Retornó " . count($reqs) . " requerimientos (esperado: 0)\n";

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
