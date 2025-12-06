<?php
chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "TEST: Modificar con valores largos (truncación)\n";
echo "==============================================\n\n";

try {
    // 1. Buscar el local
    echo "1. Buscando local id_local=11257...\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM sp_localesmodif_buscar_local(1, 2, 1, 'SS', 1, 'B', null)
    ");

    if (empty($result)) {
        echo "   ✗ Local no encontrado\n";
        exit(1);
    }

    echo "   ✓ Local encontrado\n";
    $local = $result[0];
    echo "   Datos actuales:\n";
    echo "     - sector: '{$local->sector}'\n";
    echo "     - vigencia: '{$local->vigencia}'\n\n";

    // 2. Intentar modificar con valores que causan el error
    echo "2. Modificando con valores largos que deben truncarse...\n";
    echo "   - sector: '01' (debe truncarse a '0')\n";
    echo "   - vigencia: 'ABC' (debe truncarse a 'A')\n";
    echo "   - domicilio: '222222'\n\n";

    $modifyResult = DB::connection('pgsql')->select("
        SELECT * FROM sp_localesmodif_modificar_local(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ", [
        11257,                              // p_id_local
        $local->nombre,                     // p_nombre
        '222222',                           // p_domicilio
        '01',                               // p_sector (2 chars → se truncará a '0')
        $local->zona,                       // p_zona
        $local->descripcion_local,          // p_descripcion_local
        $local->superficie,                 // p_superficie
        $local->giro,                       // p_giro
        $local->fecha_alta,                 // p_fecha_alta
        $local->fecha_baja,                 // p_fecha_baja
        'ABC',                              // p_vigencia (3 chars → se truncará a 'A')
        $local->clave_cuota,                // p_clave_cuota
        1,                                  // p_tipo_movimiento
        $local->bloqueo,                    // p_bloqueo
        null,                               // p_cve_bloqueo
        null,                               // p_fecha_inicio_bloqueo
        null,                               // p_fecha_final_bloqueo
        ''                                  // p_observacion
    ]);

    if (!empty($modifyResult)) {
        echo "   ✓ Modificación exitosa\n";
        echo "   Resultado: {$modifyResult[0]->result}\n\n";
    } else {
        echo "   ✗ No se pudo modificar\n\n";
        exit(1);
    }

    // 3. Verificar cambios
    echo "3. Verificando cambios guardados...\n";
    $verify = DB::connection('pgsql')->selectOne("
        SELECT sector, vigencia, domicilio
        FROM publico.ta_11_locales
        WHERE id_local = 11257
    ");

    if ($verify) {
        echo "   Valores guardados:\n";
        echo "   - sector: '{$verify->sector}' (longitud: " . strlen($verify->sector) . ")\n";
        echo "   - vigencia: '{$verify->vigencia}' (longitud: " . strlen($verify->vigencia) . ")\n";
        echo "   - domicilio: '{$verify->domicilio}'\n\n";

        if (strlen($verify->sector) <= 1 && strlen($verify->vigencia) <= 1) {
            echo "   ✓✓✓ TRUNCACIÓN FUNCIONÓ CORRECTAMENTE ✓✓✓\n";
            echo "   ✓ No hubo error 'value too long'\n";
            echo "   ✓ Los cambios se guardaron correctamente\n";
        } else {
            echo "   ✗ Valores no fueron truncados correctamente\n";
        }
    }

    echo "\n==============================================\n";
    echo "✓ TEST COMPLETADO\n";
    echo "==============================================\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
