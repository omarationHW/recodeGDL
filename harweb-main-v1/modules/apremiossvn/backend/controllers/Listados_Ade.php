<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ListadosAdeController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Listados_Ade
     * Entrada: {
     *   "eRequest": {
     *     "action": "mercados|aseo|publicos|exclusivos|infracciones",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $result = null;
        $error = null;
        try {
            switch ($action) {
                case 'mercados':
                    $result = $this->mercados($params);
                    break;
                case 'aseo':
                    $result = $this->aseo($params);
                    break;
                case 'publicos':
                    $result = $this->publicos($params);
                    break;
                case 'exclusivos':
                    $result = $this->exclusivos($params);
                    break;
                case 'infracciones':
                    $result = $this->infracciones($params);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error($ex);
            $error = $ex->getMessage();
        }
        return response()->json([
            'eResponse' => $error ? ['error' => $error] : $result
        ]);
    }

    private function mercados($params)
    {
        // Llama al SP correspondiente
        $res = DB::select('CALL sp_listados_ade_mercados(?,?,?,?,?,?,?,?)', [
            $params['oficina'] ?? null,
            $params['num_mercado1'] ?? null,
            $params['num_mercado2'] ?? null,
            $params['local1'] ?? null,
            $params['local2'] ?? null,
            $params['seccion'] ?? null,
            $params['axo'] ?? null,
            $params['mes'] ?? null
        ]);
        return ['data' => $res];
    }

    private function aseo($params)
    {
        $res = DB::select('CALL sp_listados_ade_aseo(?,?,?,?,?,?)', [
            $params['tipo_aseo'] ?? null,
            $params['contrato1'] ?? null,
            $params['contrato2'] ?? null,
            $params['id_rec'] ?? null,
            $params['axo'] ?? null,
            $params['mes'] ?? null
        ]);
        return ['data' => $res];
    }

    private function publicos($params)
    {
        $res = DB::select('CALL sp_listados_ade_publicos(?,?,?,?,?,?,?)', [
            $params['numesta1'] ?? null,
            $params['numesta2'] ?? null,
            $params['axo'] ?? null,
            $params['mes'] ?? null,
            $params['impd'] ?? null,
            $params['imph'] ?? null,
            $params['id_rec'] ?? null
        ]);
        return ['data' => $res];
    }

    private function exclusivos($params)
    {
        $res = DB::select('CALL sp_listados_ade_exclusivos(?,?,?,?,?,?,?)', [
            $params['no_exclusivo1'] ?? null,
            $params['no_exclusivo2'] ?? null,
            $params['axo'] ?? null,
            $params['mes'] ?? null,
            $params['impd'] ?? null,
            $params['imph'] ?? null,
            $params['id_rec'] ?? null
        ]);
        return ['data' => $res];
    }

    private function infracciones($params)
    {
        $res = DB::select('CALL sp_listados_ade_infracciones(?,?,?,?,?,?,?,?)', [
            $params['propietario'] ?? null,
            $params['placa'] ?? null,
            $params['axo1'] ?? null,
            $params['axo2'] ?? null,
            $params['impd'] ?? null,
            $params['imph'] ?? null,
            $params['tipo'] ?? null,
            $params['id_rec'] ?? null
        ]);
        return ['data' => $res];
    }
}
