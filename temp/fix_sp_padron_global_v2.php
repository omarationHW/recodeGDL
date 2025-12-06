<?php
$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n=== CORRIGIENDO sp_padron_global V2 ===\n\n";

    $sql = "
DROP FUNCTION IF EXISTS sp_padron_global(INTEGER, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION sp_padron_global(
    p_year INTEGER,
    p_month INTEGER,
    p_status VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local VARCHAR(3),
    bloque VARCHAR(5),
    nombre VARCHAR(60),
    descripcion_local VARCHAR(60),
    superficie NUMERIC(7,2),
    vigencia CHAR(1),
    clave_cuota SMALLINT,
    descripcion VARCHAR(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(100)
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta
        CASE
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN (l.superficie * COALESCE(c.importe_cuota, 0))::NUMERIC(10,2)
            WHEN l.seccion = 'PS' THEN ((COALESCE(c.importe_cuota, 0) * l.superficie) * 30)::NUMERIC(10,2)
            WHEN l.num_mercado = 214 THEN ((l.superficie * COALESCE(c.importe_cuota, 0)) * COALESCE(fd.sabadosacum, 1))::NUMERIC(10,2)
            ELSE (l.superficie * COALESCE(c.importe_cuota, 0))::NUMERIC(10,2)
        END AS renta,
        -- Leyenda y adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::VARCHAR(50)
            ELSE 'Local al Corriente de Pagos'::VARCHAR(50)
        END AS leyenda,
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END AS adeudo,
        -- Registro
        (l.oficina::TEXT || ' ' || l.num_mercado::TEXT || ' ' || l.categoria::TEXT || ' ' ||
         l.seccion || ' ' || l.local::TEXT || ' ' || COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::VARCHAR(100) AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT ade.id_local, COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local ade
        WHERE (ade.axo = p_year AND ade.periodo <= p_month) OR (ade.axo < p_year)
        GROUP BY ade.id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY l.vigencia, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
\$\$ LANGUAGE plpgsql;
";

    $pdo->exec($sql);
    echo "✅ sp_padron_global corregido\n\n";

    // Probar
    echo "Probando SP...\n";
    echo str_repeat("-", 80) . "\n";

    $axo = date('Y');
    $mes = date('n');
    $vig = 'A';

    $stmt = $pdo->prepare("SELECT * FROM sp_padron_global(?, ?, ?) LIMIT 5");
    $stmt->execute([$axo, $mes, $vig]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        echo "✅ SP funciona correctamente\n";
        echo "Total de registros (primeros 5):\n\n";
        foreach ($result as $i => $row) {
            echo "  " . ($i+1) . ". Mercado {$row['num_mercado']} - Local {$row['local']}: {$row['nombre']}\n";
            echo "      Renta: $" . number_format($row['renta'], 2) . " - {$row['leyenda']}\n";
        }
    } else {
        echo "⚠️  No hay datos con estos filtros\n";
    }

    echo "\n✅ CORRECCIÓN COMPLETADA\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
