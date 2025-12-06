<?php
// Script para encontrar combinaciones válidas de filtros para CargaPagLocales

$conn = pg_connect("host=192.168.6.146 port=5432 dbname=padron_licencias user=refact password=FF)-BQk2");

if (!$conn) {
    echo "Error al conectar\n";
    exit;
}

echo "====== BUSCANDO COMBINACIONES VÁLIDAS ======\n\n";

// Primero, buscar locales que existen en comun.ta_11_locales
$query = "
    SELECT DISTINCT
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.nombre
    FROM comun.ta_11_locales l
    WHERE l.oficina IS NOT NULL
      AND l.num_mercado IS NOT NULL
      AND l.categoria IS NOT NULL
      AND l.seccion IS NOT NULL
      AND l.local IS NOT NULL
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local
    LIMIT 10
";

$result = pg_query($conn, $query);

if ($result) {
    echo "Primeros 10 locales encontrados:\n";
    echo str_repeat("-", 100) . "\n";
    printf("%-8s %-10s %-10s %-10s %-8s %-12s %-30s\n", "Oficina", "Mercado", "Categoría", "Sección", "Local", "Letra", "Nombre");
    echo str_repeat("-", 100) . "\n";

    $locales = [];
    while ($row = pg_fetch_assoc($result)) {
        printf("%-8s %-10s %-10s %-10s %-8s %-12s %-30s\n",
            $row['oficina'],
            $row['num_mercado'],
            $row['categoria'],
            $row['seccion'],
            $row['local'],
            $row['letra_local'] ?: 'N/A',
            substr($row['nombre'], 0, 30)
        );
        $locales[] = $row;
    }

    // Ahora verificar cuál de estos tiene adeudos
    echo "\n\n====== VERIFICANDO ADEUDOS ======\n\n";

    foreach ($locales as $index => $local) {
        if ($index >= 3) break; // Solo verificar los primeros 3

        echo "Local #{$local['oficina']}-{$local['num_mercado']}-{$local['categoria']}-{$local['seccion']}-{$local['local']}:\n";

        // Buscar adeudos en ta_11_adeudo_local
        $query_adeudos = "
            SELECT COUNT(*) as total_adeudos
            FROM comun.ta_11_adeudo_local
            WHERE oficina = {$local['oficina']}
              AND num_mercado = {$local['num_mercado']}
              AND categoria = {$local['categoria']}
              AND seccion = '{$local['seccion']}'
              AND local = {$local['local']}
        ";

        $result_adeudos = pg_query($conn, $query_adeudos);
        if ($result_adeudos) {
            $adeudos = pg_fetch_assoc($result_adeudos);
            echo "  Adeudos: {$adeudos['total_adeudos']}\n";

            if ($adeudos['total_adeudos'] > 0) {
                echo "\n  ✓ COMBINACIÓN VÁLIDA ENCONTRADA:\n";
                echo "    Oficina: {$local['oficina']}\n";
                echo "    Mercado: {$local['num_mercado']}\n";
                echo "    Categoría: {$local['categoria']}\n";
                echo "    Sección: {$local['seccion']}\n";
                echo "    Local: {$local['local']}\n";
                echo "    Nombre: {$local['nombre']}\n";
                break;
            }
        }
        echo "\n";
    }
}

pg_close($conn);
?>
