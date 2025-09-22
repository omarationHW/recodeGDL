<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CMultFolioController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario CMultFolio
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|search|detail|individual",
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
        $response = [];
        try {
            switch ($action) {
                case 'list_recaudadoras':
                    $response = $this->listRecaudadoras();
                    break;
                case 'search_folios':
                    $response = $this->searchFolios($params);
                    break;
                case 'folio_detail':
                    $response = $this->folioDetail($params);
                    break;
                case 'individual_detail':
                    $response = $this->individualDetail($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada'
                    ]], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $ex) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => $ex->getMessage()
            ]], 500);
        }
    }

    private function listRecaudadoras()
    {
        $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return [
            'success' => true,
            'recaudadoras' => $data
        ];
    }

    private function searchFolios($params)
    {
        $validator = Validator::make($params, [
            'modulo' => 'required|integer',
            'zona' => 'required|integer',
            'folio' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $modulo = $params['modulo'];
        $zona = $params['zona'];
        $folio = $params['folio'];
        $folio2 = $folio + 100;
        $folios = DB::select('SELECT * FROM sp_cmultfolio_search(?, ?, ?)', [$modulo, $zona, $folio]);
        return [
            'success' => true,
            'folios' => $folios
        ];
    }

    private function folioDetail($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $id_control = $params['id_control'];
        $detail = DB::select('SELECT * FROM sp_cmultfolio_detail(?)', [$id_control]);
        return [
            'success' => true,
            'detail' => $detail[0] ?? null
        ];
    }

    private function individualDetail($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $id_control = $params['id_control'];
        $detail = DB::select('SELECT * FROM sp_cmultfolio_individual(?)', [$id_control]);
        return [
            'success' => true,
            'detail' => $detail[0] ?? null
        ];
    }
}
