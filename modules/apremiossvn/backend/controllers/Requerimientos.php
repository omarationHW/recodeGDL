<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RequerimientosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario de requerimientos.
     * Recibe eRequest con acción y parámetros.
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getMercados':
                    $eResponse['data'] = DB::select('SELECT * FROM sp_get_mercados(?)', [$params['user_id']]);
                    $eResponse['success'] = true;
                    break;
                case 'getSecciones':
                    $eResponse['data'] = DB::select('SELECT * FROM sp_get_secciones()');
                    $eResponse['success'] = true;
                    break;
                case 'getTiposAseo':
                    $eResponse['data'] = DB::select('SELECT * FROM sp_get_tipos_aseo()');
                    $eResponse['success'] = true;
                    break;
                case 'buscarMercadosAdeudos':
                    $eResponse['data'] = DB::select('SELECT * FROM sp_buscar_mercados_adeudos(?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado_desde'],
                        $params['num_mercado_hasta'],
                        $params['local_desde'],
                        $params['local_hasta'],
                        $params['seccion'],
                        $params['filtro_tipo'],
                        $params['filtro_valor'],
                        $params['adeudo_desde'],
                        $params['adeudo_hasta'],
                        $params['user_id']
                    ]);
                    $eResponse['success'] = true;
                    break;
                case 'buscarAseoAdeudos':
                    $eResponse['data'] = DB::select('SELECT * FROM sp_buscar_aseo_adeudos(?,?,?,?,?,?,?,?)', [
                        $params['tipo_aseo'],
                        $params['contrato_desde'],
                        $params['contrato_hasta'],
                        $params['filtro_tipo'],
                        $params['filtro_valor'],
                        $params['adeudo_desde'],
                        $params['adeudo_hasta'],
                        $params['user_id']
                    ]);
                    $eResponse['success'] = true;
                    break;
                case 'emitirRequerimientosMercado':
                    $result = DB::select('SELECT * FROM sp_emitir_requerimientos_mercado(?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado_desde'],
                        $params['num_mercado_hasta'],
                        $params['local_desde'],
                        $params['local_hasta'],
                        $params['seccion'],
                        $params['filtro_tipo'],
                        $params['filtro_valor'],
                        $params['adeudo_desde'],
                        $params['adeudo_hasta'],
                        $params['user_id']
                    ]);
                    $eResponse['data'] = $result;
                    $eResponse['success'] = true;
                    break;
                case 'emitirRequerimientosAseo':
                    $result = DB::select('SELECT * FROM sp_emitir_requerimientos_aseo(?,?,?,?,?,?,?,?)', [
                        $params['tipo_aseo'],
                        $params['contrato_desde'],
                        $params['contrato_hasta'],
                        $params['filtro_tipo'],
                        $params['filtro_valor'],
                        $params['adeudo_desde'],
                        $params['adeudo_hasta'],
                        $params['user_id']
                    ]);
                    $eResponse['data'] = $result;
                    $eResponse['success'] = true;
                    break;
                // ...otros casos para públicos, exclusivos, etc.
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
