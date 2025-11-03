<?php
// Script para encontrar anuncios vigentes

$host = '192.168.6.146';
$port = 5432;
$dbname = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host={$host};port={$port};dbname={$dbname}";
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conexión exitosa\n\n";

    // Buscar anuncios vigentes
    echo "=== BUSCANDO ANUNCIOS VIGENTES ===\n\n";

    $query = "
        SELECT
            a.anuncio,
            a.id_anuncio,
            a.id_licencia,
            a.texto_anuncio,
            a.vigente,
            a.fecha_otorgamiento,
            l.propietario,
            (SELECT COUNT(*) FROM comun.detsal_lic d WHERE d.id_anuncio = a.id_anuncio AND d.cvepago = 0) as adeudos_count
        FROM comun.anuncios a
        LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
        WHERE a.vigente = 'V'
        ORDER BY a.anuncio
        LIMIT 10
    ";

    $stmt = $pdo->query($query);
    $anuncios = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($anuncios) > 0) {
        echo "Encontrados " . count($anuncios) . " anuncios vigentes:\n\n";

        foreach ($anuncios as $anuncio) {
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "No. Anuncio: {$anuncio['anuncio']}\n";
            echo "ID Anuncio: {$anuncio['id_anuncio']}\n";
            echo "ID Licencia: {$anuncio['id_licencia']}\n";
            echo "Texto: " . substr($anuncio['texto_anuncio'] ?? 'N/A', 0, 50) . "\n";
            echo "Estado: {$anuncio['vigente']} (Vigente)\n";
            echo "Fecha otorgamiento: {$anuncio['fecha_otorgamiento']}\n";
            echo "Propietario: " . substr($anuncio['propietario'] ?? 'N/A', 0, 30) . "\n";
            echo "Adeudos pendientes: {$anuncio['adeudos_count']}\n";
            echo "\n";
        }

        // Buscar uno sin adeudos
        echo "\n=== ANUNCIOS VIGENTES SIN ADEUDOS ===\n\n";
        $sinAdeudos = array_filter($anuncios, function($a) {
            return $a['adeudos_count'] == 0;
        });

        if (count($sinAdeudos) > 0) {
            $primero = reset($sinAdeudos);
            echo "✅ ANUNCIO IDEAL PARA PRUEBA:\n";
            echo "   No. Anuncio: {$primero['anuncio']}\n";
            echo "   Sin adeudos, listo para dar de baja\n\n";
        }

        // Buscar uno con adeudos para probar validación
        $conAdeudos = array_filter($anuncios, function($a) {
            return $a['adeudos_count'] > 0;
        });

        if (count($conAdeudos) > 0) {
            $primero = reset($conAdeudos);
            echo "⚠️  ANUNCIO CON ADEUDOS (para probar validación):\n";
            echo "   No. Anuncio: {$primero['anuncio']}\n";
            echo "   Tiene {$primero['adeudos_count']} adeudo(s) pendiente(s)\n\n";
        }

    } else {
        echo "⚠️  No se encontraron anuncios vigentes\n\n";

        // Buscar todos los anuncios
        echo "Buscando TODOS los anuncios (cualquier estado)...\n\n";
        $query = "
            SELECT anuncio, id_anuncio, vigente, fecha_otorgamiento
            FROM comun.anuncios
            ORDER BY anuncio
            LIMIT 5
        ";
        $todos = $pdo->query($query)->fetchAll(PDO::FETCH_ASSOC);

        foreach ($todos as $a) {
            echo "- Anuncio {$a['anuncio']}: Estado='{$a['vigente']}', Fecha={$a['fecha_otorgamiento']}\n";
        }
    }

    // Query SQL para copiar/pegar
    echo "\n=== QUERY SQL PARA COPIAR ===\n\n";
    echo "-- Buscar anuncios vigentes sin adeudos\n";
    echo "SELECT a.anuncio, a.id_anuncio, a.texto_anuncio, a.vigente,\n";
    echo "       (SELECT COUNT(*) FROM comun.detsal_lic d WHERE d.id_anuncio = a.id_anuncio AND d.cvepago = 0) as adeudos\n";
    echo "FROM comun.anuncios a\n";
    echo "WHERE a.vigente = 'V'\n";
    echo "ORDER BY a.anuncio LIMIT 10;\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
