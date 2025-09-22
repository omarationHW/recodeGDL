<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute endpoint.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'buscar_actividades':
                    // params: scian (int), descripcion (string, opcional)
                    $scian = isset($params['scian']) ? (int)$params['scian'] : null;
                    $descripcion = isset($params['descripcion']) ? $params['descripcion'] : '';
                    $result = DB::select('SELECT * FROM buscar_actividades(:scian, :descripcion)', [
                        'scian' => $scian,
                        'descripcion' => $descripcion
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_actividad_por_id':
                    // params: id_giro (int)
                    $id_giro = isset($params['id_giro']) ? (int)$params['id_giro'] : null;
                    $result = DB::select('SELECT * FROM buscar_actividad_por_id(:id_giro)', [
                        'id_giro' => $id_giro
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'eRequest no soportado';
            }
        } catch (\Exception $e) {
            $eResponse['error'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
