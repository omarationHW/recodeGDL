<?php
// Actualizar SP con límite razonable por defecto

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ACTUALIZAR SP CON LÍMITE RAZONABLE ===\n\n";

    echo "🗑️  Eliminando función existente...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_list(TIMESTAMP, TIMESTAMP)");
    echo "✅ Función eliminada\n\n";

    echo "1️⃣  Creando sp_fechaseg_list con límite de 50,000 registros...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_list(
            p_fecha_inicio TIMESTAMP DEFAULT NULL,
            p_fecha_fin TIMESTAMP DEFAULT NULL
        )
        RETURNS TABLE (
            id INTEGER,
            t42_doctos_id INTEGER,
            t42_centros_id INTEGER,
            usuario_seg INTEGER,
            fec_seg TIMESTAMP,
            t42_statusseg_id INTEGER,
            observacion VARCHAR,
            usuario_mov CHAR(10)
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                s.id,
                s.t42_doctos_id,
                s.t42_centros_id,
                s.usuario_seg,
                s.fec_seg,
                s.t42_statusseg_id,
                s.observacion,
                s.usuario_mov
            FROM comun.t42_seguimiento s
            WHERE 1=1
                AND (p_fecha_inicio IS NULL OR s.fec_seg >= p_fecha_inicio)
                AND (p_fecha_fin IS NULL OR s.fec_seg <= p_fecha_fin)
            ORDER BY s.fec_seg DESC NULLS LAST, s.id DESC
            LIMIT 50000;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_list creado con límite de 50,000 registros\n\n";

    echo "🧪 Probando SP...\n";
    $stmt = $db->query("SELECT COUNT(*) FROM comun.sp_fechaseg_list(NULL, NULL)");
    $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    echo "📊 Total registros retornados: " . number_format($count) . "\n\n";

    echo "✅ SP ACTUALIZADO EXITOSAMENTE\n";
    echo "\n💡 El límite de 50,000 registros es razonable para:\n";
    echo "  - Evitar timeout de PHP\n";
    echo "  - No saturar la memoria\n";
    echo "  - Permitir filtrado por fechas para rangos más específicos\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
