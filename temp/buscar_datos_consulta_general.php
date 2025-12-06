<?php
/**
 * Script para buscar datos de prueba para ConsultaGeneral
 * Busca locales en publico.ta_11_locales con datos completos
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "\n=== BÚSQUEDA DE DATOS PARA CONSULTA GENERAL ===\n\n";

    // Buscar locales con datos completos en publico.ta_11_locales
    echo "1. BUSCANDO LOCALES CON DATOS COMPLETOS...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            oficina,
            num_mercado,
            categoria,
            seccion,
            local,
            letra_local,
            bloque,
            nombre,
            arrendatario,
            domicilio
        FROM publico.ta_11_locales
        WHERE oficina IS NOT NULL
          AND num_mercado IS NOT NULL
          AND categoria IS NOT NULL
          AND seccion IS NOT NULL
          AND local IS NOT NULL
          AND nombre IS NOT NULL
        ORDER BY oficina, num_mercado, categoria, seccion, local
        LIMIT 10
    ";

    $stmt = $pdo->query($sql);
    $locales = $stmt->fetchAll();

    if (count($locales) > 0) {
        echo "Se encontraron " . count($locales) . " locales con datos completos:\n\n";

        foreach ($locales as $idx => $local) {
            echo "LOCAL " . ($idx + 1) . ":\n";
            echo "  Oficina (Recaudadora): " . $local['oficina'] . "\n";
            echo "  Mercado: " . $local['num_mercado'] . "\n";
            echo "  Categoría: " . $local['categoria'] . "\n";
            echo "  Sección: " . $local['seccion'] . "\n";
            echo "  Local: " . $local['local'] . "\n";
            echo "  Letra: " . ($local['letra_local'] ?: 'NULL') . "\n";
            echo "  Bloque: " . ($local['bloque'] ?: 'NULL') . "\n";
            echo "  Nombre: " . ($local['nombre'] ?: 'N/A') . "\n";
            echo "  Arrendatario: " . ($local['arrendatario'] ?: 'N/A') . "\n";
            echo "  Domicilio: " . ($local['domicilio'] ?: 'N/A') . "\n";
            echo "\n";
        }

        // Mostrar combinaciones sugeridas
        echo "\n" . str_repeat("=", 80) . "\n";
        echo "COMBINACIONES SUGERIDAS PARA PROBAR:\n";
        echo str_repeat("=", 80) . "\n\n";

        for ($i = 0; $i < min(3, count($locales)); $i++) {
            $local = $locales[$i];
            echo "OPCIÓN " . ($i + 1) . ":\n";
            echo "  Recaudadora: " . $local['oficina'] . "\n";
            echo "  Mercado: " . $local['num_mercado'] . "\n";
            echo "  Categoría: " . $local['categoria'] . "\n";
            echo "  Sección: " . $local['seccion'] . "\n";
            echo "  Local: " . $local['local'] . "\n";
            if ($local['letra_local']) {
                echo "  Letra: " . $local['letra_local'] . "\n";
            }
            if ($local['bloque']) {
                echo "  Bloque: " . $local['bloque'] . "\n";
            }
            echo "\n";
        }

    } else {
        echo "❌ No se encontraron locales con datos completos\n\n";
    }

    // Buscar estadísticas de la tabla
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "2. ESTADÍSTICAS DE LA TABLA publico.ta_11_locales:\n";
    echo str_repeat("=", 80) . "\n\n";

    $sql = "
        SELECT
            COUNT(*) as total,
            COUNT(DISTINCT oficina) as oficinas_distintas,
            COUNT(DISTINCT num_mercado) as mercados_distintos,
            COUNT(DISTINCT categoria) as categorias_distintas,
            COUNT(DISTINCT seccion) as secciones_distintas
        FROM publico.ta_11_locales
    ";

    $stmt = $pdo->query($sql);
    $stats = $stmt->fetch();

    echo "Total de registros: " . $stats['total'] . "\n";
    echo "Oficinas distintas: " . $stats['oficinas_distintas'] . "\n";
    echo "Mercados distintos: " . $stats['mercados_distintos'] . "\n";
    echo "Categorías distintas: " . $stats['categorias_distintas'] . "\n";
    echo "Secciones distintas: " . $stats['secciones_distintas'] . "\n\n";

    // Listar oficinas disponibles
    echo "Oficinas disponibles:\n";
    $sql = "SELECT DISTINCT oficina FROM publico.ta_11_locales WHERE oficina IS NOT NULL ORDER BY oficina";
    $stmt = $pdo->query($sql);
    $oficinas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "  " . implode(", ", $oficinas) . "\n\n";

    // Listar mercados disponibles
    echo "Mercados disponibles:\n";
    $sql = "SELECT DISTINCT num_mercado FROM publico.ta_11_locales WHERE num_mercado IS NOT NULL ORDER BY num_mercado LIMIT 20";
    $stmt = $pdo->query($sql);
    $mercados = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "  " . implode(", ", $mercados) . "\n\n";

    // Listar secciones disponibles
    echo "Secciones disponibles:\n";
    $sql = "SELECT DISTINCT seccion FROM publico.ta_11_locales WHERE seccion IS NOT NULL ORDER BY seccion LIMIT 30";
    $stmt = $pdo->query($sql);
    $secciones = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "  " . implode(", ", $secciones) . "\n\n";

    echo "\n✅ ANÁLISIS COMPLETADO\n\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
