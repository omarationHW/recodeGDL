<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO STORED PROCEDURE recaudadora_reimpfrm ===\n\n";

$sql = "
CREATE OR REPLACE FUNCTION publico.recaudadora_reimpfrm(
    p_folio INTEGER,
    p_tipo_documento VARCHAR,
    p_id_dependencia INTEGER,
    p_formato VARCHAR
)
RETURNS TABLE (
    folio INTEGER,
    tipo_documento VARCHAR,
    fecha DATE,
    contribuyente VARCHAR,
    dependencia VARCHAR,
    axo_acta INTEGER,
    num_acta VARCHAR,
    importe NUMERIC,
    estatus VARCHAR
)
LANGUAGE plpgsql AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        d.folio,
        d.tipo_documento::VARCHAR,
        d.fecha,
        d.contribuyente::VARCHAR,
        d.dependencia::VARCHAR,
        d.axo_acta,
        d.num_acta::VARCHAR,
        d.importe,
        d.estatus::VARCHAR
    FROM publico.documentos_reimprimir d
    WHERE
        -- Filtro por folio específico
        (p_folio IS NULL OR d.folio = p_folio)
        -- Filtro por tipo de documento
        AND (p_tipo_documento IS NULL OR p_tipo_documento = '' OR d.tipo_documento = p_tipo_documento)
        -- Filtro por dependencia
        AND (p_id_dependencia IS NULL OR d.id_dependencia = p_id_dependencia)
    ORDER BY d.fecha DESC, d.folio DESC;
END; \$\$;
";

try {
    $pdo->exec($sql);
    echo "✅ Stored Procedure 'recaudadora_reimpfrm' creado exitosamente\n\n";

    // Verificar que el SP existe
    $check = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'publico'
        AND routine_name = 'recaudadora_reimpfrm'
    ")->fetch(PDO::FETCH_ASSOC);

    if ($check) {
        echo "✅ Verificación: SP existe en el esquema publico\n";
        echo "   Nombre: {$check['routine_name']}\n";
        echo "   Tipo: {$check['routine_type']}\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
