<?php
/**
 * Script para desplegar stored procedures de reqmultas400frm
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

try {
    $pdo = DB::connection()->getPdo();

    echo "=== DESPLEGANDO STORED PROCEDURES REQMULTAS400FRM ===\n\n";

    // SP 1: Buscar por acta
    echo "1. Creando req_mul_400_by_acta...\n";
    $sql1 = "
    CREATE OR REPLACE FUNCTION req_mul_400_by_acta(
        p_dep VARCHAR,
        p_axo INTEGER,
        p_numacta INTEGER,
        p_tipo INTEGER
    )
    RETURNS TABLE (
        cvelet VARCHAR,
        cvenum INTEGER,
        ctarfc INTEGER,
        cveapl INTEGER,
        axoreq INTEGER,
        folreq INTEGER,
        nombre VARCHAR,
        domicilio VARCHAR,
        importe NUMERIC,
        fecha DATE
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            r.cvelet,
            r.cvenum,
            r.ctarfc,
            r.cveapl,
            r.axoreq,
            r.folreq,
            r.nombre,
            r.domicilio,
            r.importe,
            r.fecha
        FROM comun.req_mul_400 r
        WHERE SUBSTRING(r.cvelet FROM 4 FOR 3) = p_dep
          AND r.cvenum = p_axo
          AND r.ctarfc = p_numacta
          AND r.cveapl = p_tipo
        ORDER BY r.axoreq, r.folreq;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql1);
    echo "   ✓ req_mul_400_by_acta creado\n\n";

    // SP 2: Buscar por folio
    echo "2. Creando req_mul_400_by_folio...\n";
    $sql2 = "
    CREATE OR REPLACE FUNCTION req_mul_400_by_folio(
        p_axo INTEGER,
        p_folio INTEGER,
        p_tipo INTEGER
    )
    RETURNS TABLE (
        cvelet VARCHAR,
        cvenum INTEGER,
        ctarfc INTEGER,
        cveapl INTEGER,
        axoreq INTEGER,
        folreq INTEGER,
        nombre VARCHAR,
        domicilio VARCHAR,
        importe NUMERIC,
        fecha DATE
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            r.cvelet,
            r.cvenum,
            r.ctarfc,
            r.cveapl,
            r.axoreq,
            r.folreq,
            r.nombre,
            r.domicilio,
            r.importe,
            r.fecha
        FROM comun.req_mul_400 r
        WHERE r.axoreq = p_axo
          AND r.folreq = p_folio
          AND r.cveapl = p_tipo
        ORDER BY r.axoreq, r.folreq;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql2);
    echo "   ✓ req_mul_400_by_folio creado\n\n";

    // SP 3: Principal - búsqueda general
    echo "3. Creando recaudadora_reqmultas400frm...\n";
    $sql3 = "
    CREATE OR REPLACE FUNCTION recaudadora_reqmultas400frm(
        p_clave_cuenta VARCHAR DEFAULT NULL
    )
    RETURNS TABLE (
        cvelet VARCHAR,
        cvenum INTEGER,
        ctarfc INTEGER,
        cveapl INTEGER,
        axoreq INTEGER,
        folreq INTEGER,
        nombre VARCHAR,
        domicilio VARCHAR,
        importe NUMERIC,
        fecha DATE
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            r.cvelet,
            r.cvenum,
            r.ctarfc,
            r.cveapl,
            r.axoreq,
            r.folreq,
            r.nombre,
            r.domicilio,
            r.importe,
            r.fecha
        FROM comun.req_mul_400 r
        WHERE p_clave_cuenta IS NULL
           OR r.cvelet ILIKE '%' || p_clave_cuenta || '%'
           OR CAST(r.folreq AS VARCHAR) = p_clave_cuenta
        ORDER BY r.axoreq DESC, r.folreq DESC
        LIMIT 100;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql3);
    echo "   ✓ recaudadora_reqmultas400frm creado\n\n";

    // Verificar que exista la tabla y obtener ejemplos
    echo "4. Verificando tabla y obteniendo ejemplos...\n";

    $checkTable = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'req_mul_400'
        LIMIT 1
    ")->fetch(PDO::FETCH_ASSOC);

    if ($checkTable) {
        echo "   ✓ Tabla encontrada: {$checkTable['table_schema']}.{$checkTable['table_name']}\n\n";

        // Obtener 3 ejemplos
        echo "5. Obteniendo ejemplos de datos:\n";
        $examples = $pdo->query("
            SELECT * FROM comun.req_mul_400
            ORDER BY axoreq DESC, folreq DESC
            LIMIT 3
        ")->fetchAll(PDO::FETCH_ASSOC);

        foreach ($examples as $i => $row) {
            echo "\nEjemplo " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: " . (is_null($value) ? 'NULL' : $value) . "\n";
            }
        }

        // Contar registros
        $count = $pdo->query("SELECT COUNT(*) FROM comun.req_mul_400")->fetchColumn();
        echo "\n\nTotal de registros en req_mul_400: $count\n";

    } else {
        echo "   ⚠ Tabla req_mul_400 no encontrada en schemas comunes\n";
        echo "   Buscando en otros schemas...\n";

        $allTables = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name ILIKE '%req%mul%'
            ORDER BY table_schema, table_name
        ")->fetchAll(PDO::FETCH_ASSOC);

        foreach ($allTables as $table) {
            echo "   - {$table['table_schema']}.{$table['table_name']}\n";
        }
    }

    echo "\n✅ DESPLIEGUE COMPLETADO\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
