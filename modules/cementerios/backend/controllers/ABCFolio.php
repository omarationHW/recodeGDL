<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ABCFolioController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];
        try {
            switch ($action) {
                case 'getFolio':
                    $folio = $data['folio'] ?? null;
                    $result = DB::select('SELECT a.*, c.nombre as usuario_nombre, c.id_rec FROM ta_13_datosrcm a JOIN ta_12_passwords c ON a.usuario = c.id_usuario WHERE a.control_rcm = ?', [$folio]);
                    $adicional = DB::select('SELECT * FROM ta_13_datosrcmadic WHERE control_rcm = ?', [$folio]);
                    $pagos = DB::select('SELECT * FROM ta_13_pagosrcm WHERE control_rcm = ?', [$folio]);
                    $adeudos = DB::select('SELECT * FROM ta_13_adeudosrcm WHERE control_rcm = ? AND vigencia = ?', [$folio, 'V']);
                    $response['success'] = true;
                    $response['data'] = [
                        'folio' => $result ? $result[0] : null,
                        'adicional' => $adicional ? $adicional[0] : null,
                        'pagos' => $pagos,
                        'adeudos' => $adeudos
                    ];
                    break;
                case 'updateFolio':
                    $validator = Validator::make($data, [
                        'control_rcm' => 'required|integer',
                        'cementerio' => 'required|string',
                        'clase' => 'required|integer',
                        'clase_alfa' => 'nullable|string',
                        'seccion' => 'required|integer',
                        'seccion_alfa' => 'nullable|string',
                        'linea' => 'required|integer',
                        'linea_alfa' => 'nullable|string',
                        'fosa' => 'required|integer',
                        'fosa_alfa' => 'nullable|string',
                        'axo_pagado' => 'required|integer',
                        'metros' => 'required|numeric',
                        'nombre' => 'required|string',
                        'domicilio' => 'required|string',
                        'exterior' => 'nullable|string',
                        'interior' => 'nullable|string',
                        'colonia' => 'nullable|string',
                        'observaciones' => 'nullable|string',
                        'tipo' => 'required|string',
                        'adicional' => 'nullable|array',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::beginTransaction();
                    // Llama SP para histórico
                    DB::statement('CALL sp_13_historia(?)', [$data['control_rcm']]);
                    // Actualiza datos principales
                    DB::update('UPDATE ta_13_datosrcm SET cementerio = ?, clase = ?, clase_alfa = ?, seccion = ?, seccion_alfa = ?, linea = ?, linea_alfa = ?, fosa = ?, fosa_alfa = ?, axo_pagado = ?, metros = ?, nombre = ?, domicilio = ?, exterior = ?, interior = ?, colonia = ?, observaciones = ?, usuario = ?, fecha_mov = CURRENT_DATE, tipo = ? WHERE control_rcm = ?', [
                        $data['cementerio'], $data['clase'], $data['clase_alfa'], $data['seccion'], $data['seccion_alfa'], $data['linea'], $data['linea_alfa'], $data['fosa'], $data['fosa_alfa'], $data['axo_pagado'], $data['metros'], $data['nombre'], $data['domicilio'], $data['exterior'], $data['interior'], $data['colonia'], $data['observaciones'], $userId, $data['tipo'], $data['control_rcm']
                    ]);
                    // Adicional
                    if (!empty($data['adicional'])) {
                        $ad = $data['adicional'];
                        $exists = DB::select('SELECT 1 FROM ta_13_datosrcmadic WHERE control_rcm = ?', [$data['control_rcm']]);
                        if ($exists) {
                            DB::update('UPDATE ta_13_datosrcmadic SET rfc = ?, curp = ?, telefono = ?, clave_ife = ? WHERE control_rcm = ?', [
                                $ad['rfc'] ?? null, $ad['curp'] ?? null, $ad['telefono'] ?? null, $ad['clave_ife'] ?? null, $data['control_rcm']
                            ]);
                        } else {
                            DB::insert('INSERT INTO ta_13_datosrcmadic (control_rcm, rfc, curp, telefono, clave_ife) VALUES (?, ?, ?, ?, ?)', [
                                $data['control_rcm'], $ad['rfc'] ?? null, $ad['curp'] ?? null, $ad['telefono'] ?? null, $ad['clave_ife'] ?? null
                            ]);
                        }
                    }
                    // Llama SP para recalcular adeudos
                    DB::statement('CALL spd_abc_adercm(?, ?, ?)', [$data['control_rcm'], 3, $userId]);
                    DB::commit();
                    $response['success'] = true;
                    $response['message'] = 'Registro modificado correctamente';
                    break;
                case 'deleteFolio':
                    $folio = $data['control_rcm'] ?? null;
                    if (!$folio) {
                        $response['message'] = 'Folio requerido';
                        break;
                    }
                    DB::beginTransaction();
                    DB::update('UPDATE ta_13_datosrcm SET vigencia = ?, usuario = ?, fecha_mov = CURRENT_DATE WHERE control_rcm = ?', ['B', $userId, $folio]);
                    DB::statement('CALL spd_abc_adercm(?, ?, ?)', [$folio, 2, $userId]);
                    DB::commit();
                    $response['success'] = true;
                    $response['message'] = 'Registro dado de baja correctamente';
                    break;
                case 'getCementerios':
                    $cem = DB::select('SELECT * FROM tc_13_cementerios');
                    $response['success'] = true;
                    $response['data'] = $cem;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            DB::rollBack();
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
