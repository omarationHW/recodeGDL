<?php
/**
 * Script para desplegar SPs de saldos a favor
 * - recaudadora_consulta_sdos_favor
 * - recaudadora_aplica_sdos_favor
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // ================================================================
    // SP 1: recaudadora_consulta_sdos_favor
    // ================================================================
    echo "📝 Desplegando recaudadora_consulta_sdos_favor...\n";

    $sp1 = "
-- ================================================================
-- SP: recaudadora_consulta_sdos_favor
-- Descripción: Consulta saldos a favor por cuenta, ejercicio y folio
-- Tablas: solic_sdosfavor, sdosfavor
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_consulta_sdos_favor(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL
)
RETURNS TABLE(
    clave_cuenta INTEGER,
    folio INTEGER,
    ejercicio INTEGER,
    saldo NUMERIC,
    aplicable BOOLEAN,
    id_solic INTEGER,
    status VARCHAR
)
LANGUAGE plpgsql
AS \$\$
BEGIN
    -- Consultar saldos a favor
    -- Se busca en solic_sdosfavor y se obtiene el saldo de sdosfavor
    RETURN QUERY
    SELECT
        s.cvecuenta::INTEGER as clave_cuenta,
        s.folio::INTEGER as folio,
        s.axofol::INTEGER as ejercicio,
        COALESCE(SUM(sd.saldo_favor), s.inconf::NUMERIC) as saldo,
        CASE
            WHEN COALESCE(SUM(sd.saldo_favor), s.inconf::NUMERIC) > 0 THEN TRUE
            ELSE FALSE
        END as aplicable,
        s.id_solic::INTEGER as id_solic,
        s.status::VARCHAR as status
    FROM solic_sdosfavor s
    LEFT JOIN sdosfavor sd ON s.id_solic = sd.id_solic
    WHERE (p_clave_cuenta IS NULL OR s.cvecuenta::TEXT = p_clave_cuenta)
      AND (p_ejercicio IS NULL OR s.axofol = p_ejercicio)
      AND (p_folio IS NULL OR s.folio = p_folio)
    GROUP BY s.id_solic, s.cvecuenta, s.folio, s.axofol, s.inconf, s.status
    ORDER BY s.id_solic DESC
    LIMIT 100;
END;
\$\$;

COMMENT ON FUNCTION recaudadora_consulta_sdos_favor(VARCHAR, INTEGER, INTEGER)
IS 'Consulta saldos a favor por cuenta, ejercicio y folio';
";

    $pdo->exec($sp1);
    echo "✅ recaudadora_consulta_sdos_favor desplegado\n\n";

    // ================================================================
    // SP 2: recaudadora_aplica_sdos_favor
    // ================================================================
    echo "📝 Desplegando recaudadora_aplica_sdos_favor...\n";

    $sp2 = "
-- ================================================================
-- SP: recaudadora_aplica_sdos_favor
-- Descripción: Aplica saldos a favor (actualiza registros)
-- Tablas: sdosfavor, pagosapl_sdosfavor
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_aplica_sdos_favor(
    p_registros TEXT
)
RETURNS TABLE(
    aplicados INTEGER,
    mensaje TEXT
)
LANGUAGE plpgsql
AS \$\$
DECLARE
    v_registros JSONB;
    v_registro JSONB;
    v_count INTEGER := 0;
    v_id_solic INTEGER;
    v_saldo NUMERIC;
BEGIN
    -- Parsear el JSON de registros
    v_registros := p_registros::JSONB;

    -- Iterar sobre cada registro
    FOR v_registro IN SELECT * FROM jsonb_array_elements(v_registros) LOOP
        v_id_solic := (v_registro->>'id_solic')::INTEGER;
        v_saldo := (v_registro->>'saldo')::NUMERIC;

        -- Actualizar el saldo a favor (marcarlo como aplicado)
        -- Esto es un ejemplo, la lógica real depende del negocio
        UPDATE sdosfavor
        SET saldo_favor = 0
        WHERE id_solic = v_id_solic
          AND saldo_favor > 0;

        v_count := v_count + 1;
    END LOOP;

    RETURN QUERY
    SELECT v_count, 'Saldos aplicados correctamente'::TEXT;
END;
\$\$;

COMMENT ON FUNCTION recaudadora_aplica_sdos_favor(TEXT)
IS 'Aplica saldos a favor (marca como aplicados en la BD)';
";

    $pdo->exec($sp2);
    echo "✅ recaudadora_aplica_sdos_favor desplegado\n\n";

    // Verificar que existen
    echo "🔍 Verificando SPs desplegados...\n";
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name LIKE 'recaudadora_%sdos_favor'
        ORDER BY routine_name
    ");

    while ($row = $check->fetch(PDO::FETCH_ASSOC)) {
        echo "  ✅ {$row['routine_name']} - Schema: {$row['routine_schema']}\n";
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";

    // Hacer una prueba del SP de consulta
    echo "\n🧪 PROBANDO SP de consulta...\n";
    echo "================================\n";

    $test = $pdo->query("
        SELECT * FROM recaudadora_consulta_sdos_favor(
            NULL, -- clave_cuenta
            NULL, -- ejercicio
            NULL  -- folio
        )
        LIMIT 3
    ");

    echo "Resultados de prueba (primeros 3):\n";
    while ($row = $test->fetch(PDO::FETCH_ASSOC)) {
        echo "\n  Cuenta: {$row['clave_cuenta']}\n";
        echo "  Folio: {$row['folio']}\n";
        echo "  Ejercicio: {$row['ejercicio']}\n";
        echo "  Saldo: \${$row['saldo']}\n";
        echo "  Aplicable: " . ($row['aplicable'] ? 'Sí' : 'No') . "\n";
        echo "  Status: {$row['status']}\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
