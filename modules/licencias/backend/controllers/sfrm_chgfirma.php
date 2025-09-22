<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class FirmaElectronicaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones relacionadas con la firma electrónica.
     * Entrada: {
     *   "eRequest": {
     *     "action": "chg_firma",
     *     "usuario": "usuario",
     *     "firma_actual": "...",
     *     "firma_nueva": "...",
     *     "firma_conf": "...",
     *     "modulos_id": 1
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $eResponse = ["success" => false, "message" => "Acción no válida"];

        switch ($action) {
            case 'chg_firma':
                $eResponse = $this->cambiarFirma($input);
                break;
            default:
                $eResponse = ["success" => false, "message" => "Acción no soportada"];
        }
        return response()->json(["eResponse" => $eResponse]);
    }

    /**
     * Cambia la firma electrónica del usuario
     */
    private function cambiarFirma($input)
    {
        $validator = Validator::make($input, [
            'usuario' => 'required|string|max:100',
            'firma_actual' => 'required|string|max:100',
            'firma_nueva' => 'required|string|max:100',
            'firma_conf' => 'required|string|max:100',
            'modulos_id' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first()];
        }

        try {
            $result = DB::select('SELECT * FROM upd_firma(:p_usuario, :p_login, :p_firma, :p_firma_nva, :p_firma_conf, :p_modulos_id)', [
                'p_usuario' => $input['usuario'],
                'p_login' => '',
                'p_firma' => $input['firma_actual'],
                'p_firma_nva' => $input['firma_nueva'],
                'p_firma_conf' => $input['firma_conf'],
                'p_modulos_id' => $input['modulos_id'],
            ]);
            $row = $result[0] ?? null;
            if ($row && $row->acceso == 0) {
                return ["success" => true, "message" => $row->mensaje];
            } else {
                return ["success" => false, "message" => $row->mensaje ?? 'Error desconocido'];
            }
        } catch (\Exception $e) {
            return ["success" => false, "message" => $e->getMessage()];
        }
    }
}
