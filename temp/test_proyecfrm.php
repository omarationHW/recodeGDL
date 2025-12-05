<?php
// Probar Stored Procedure: recaudadora_proyecfrm con 3 ejemplos reales
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== PROBANDO SP: recaudadora_proyecfrm ===\n\n";

    // Primero, obtener algunos ejercicios y proyectos reales
    echo "--- Obteniendo datos de muestra de ta_proyectos ---\n\n";
    $sampleSql = "
        SELECT DISTINCT ejercicio, proyecto, TRIM(descripcion) as descripcion
        FROM comun.ta_proyectos
        WHERE descripcion IS NOT NULL AND descripcion != ''
        ORDER BY ejercicio DESC, proyecto
        LIMIT 5
    ";
    $stmt = $pdo->query($sampleSql);
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Datos de muestra encontrados:\n";
    foreach ($samples as $idx => $sample) {
        echo ($idx + 1) . ". Ejercicio: {$sample['ejercicio']}, Proyecto: {$sample['proyecto']}, Desc: {$sample['descripcion']}\n";
    }
    echo "\n";

    // EJEMPLO 1: Sin filtro (obtener proyectos más recientes)
    echo "=== EJEMPLO 1: SIN FILTRO (Proyectos más recientes) ===\n\n";
    $sql1 = "SELECT * FROM public.recaudadora_proyecfrm('')";
    $stmt1 = $pdo->query($sql1);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros obtenidos: " . count($result1) . "\n";
    if (count($result1) > 0) {
        echo "\nPrimeros 3 registros:\n";
        for ($i = 0; $i < min(3, count($result1)); $i++) {
            $r = $result1[$i];
            echo "\nRegistro " . ($i + 1) . ":\n";
            echo "  Ejercicio: {$r['ejercicio']}\n";
            echo "  Proyecto: {$r['proyecto']}\n";
            echo "  Descripción: {$r['descripcion']}\n";
            echo "  Dependencia: {$r['dependencia']}\n";
            echo "  Partida: {$r['partida']}\n";
            echo "  Programa: {$r['programa']}\n";
            echo "  Fecha Alta: {$r['fecha_alta']}\n";
            echo "  Pres. Actual: {$r['presactual']}\n";
            echo "  Pres. Operativo: {$r['pres_oper']}\n";
            echo "  Pres. Inversión: {$r['pres_inver']}\n";
            echo "  Pres. Otros: {$r['pres_otros']}\n";
            echo "  Total Anual: {$r['total_anual']}\n";
        }
    }
    echo "\n" . str_repeat("=", 80) . "\n\n";

    // EJEMPLO 2: Filtro por ejercicio (usar el ejercicio más reciente encontrado)
    if (count($samples) > 0) {
        $ejercicioTest = $samples[0]['ejercicio'];
        echo "=== EJEMPLO 2: FILTRO POR EJERCICIO ({$ejercicioTest}) ===\n\n";

        $sql2 = "SELECT * FROM public.recaudadora_proyecfrm('{$ejercicioTest}')";
        $stmt2 = $pdo->query($sql2);
        $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        echo "Registros obtenidos: " . count($result2) . "\n";
        if (count($result2) > 0) {
            echo "\nPrimeros 2 registros:\n";
            for ($i = 0; $i < min(2, count($result2)); $i++) {
                $r = $result2[$i];
                echo "\nRegistro " . ($i + 1) . ":\n";
                echo "  Ejercicio: {$r['ejercicio']}\n";
                echo "  Proyecto: {$r['proyecto']}\n";
                echo "  Descripción: {$r['descripcion']}\n";
                echo "  Total Anual: {$r['total_anual']}\n";
            }
        }
        echo "\n" . str_repeat("=", 80) . "\n\n";
    }

    // EJEMPLO 3: Filtro por texto en descripción
    echo "=== EJEMPLO 3: FILTRO POR TEXTO ('OBRA' o primer término de descripción) ===\n\n";

    // Intentar con un término común en las descripciones
    $textSearch = 'OBRA';
    $sql3 = "SELECT * FROM public.recaudadora_proyecfrm('{$textSearch}')";
    $stmt3 = $pdo->query($sql3);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros obtenidos con '{$textSearch}': " . count($result3) . "\n";

    if (count($result3) == 0 && count($samples) > 0) {
        // Si no hay resultados con 'OBRA', usar la primera palabra de la primera descripción
        $firstDesc = $samples[0]['descripcion'];
        $words = explode(' ', $firstDesc);
        $textSearch = $words[0];

        echo "No se encontraron resultados con 'OBRA', probando con '{$textSearch}'...\n";
        $sql3 = "SELECT * FROM public.recaudadora_proyecfrm('{$textSearch}')";
        $stmt3 = $pdo->query($sql3);
        $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);
        echo "Registros obtenidos: " . count($result3) . "\n";
    }

    if (count($result3) > 0) {
        echo "\nPrimeros 2 registros:\n";
        for ($i = 0; $i < min(2, count($result3)); $i++) {
            $r = $result3[$i];
            echo "\nRegistro " . ($i + 1) . ":\n";
            echo "  Ejercicio: {$r['ejercicio']}\n";
            echo "  Proyecto: {$r['proyecto']}\n";
            echo "  Descripción: {$r['descripcion']}\n";
            echo "  Total Anual: {$r['total_anual']}\n";
        }
    }
    echo "\n" . str_repeat("=", 80) . "\n\n";

    // RESUMEN DE EJEMPLOS PARA EL FORMULARIO
    echo "=== RESUMEN: 3 EJEMPLOS PARA PROBAR EN EL FORMULARIO ===\n\n";
    echo "1. Filtro vacío ('') - Obtiene los 50 proyectos más recientes\n";
    if (count($samples) > 0) {
        echo "2. Filtro: '{$samples[0]['ejercicio']}' - Busca por ejercicio\n";
    }
    echo "3. Filtro: '{$textSearch}' - Busca por descripción\n\n";

    echo "Copia estos valores en el campo 'Filtro de Búsqueda' del formulario proyecfrm.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
