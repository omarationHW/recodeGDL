<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DerechosLicController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumimos autenticación JWT o similar

        switch ($action) {
            case 'buscarLicencia':
                return $this->buscarLicencia($params);
            case 'buscarAnuncio':
                return $this->buscarAnuncio($params);
            case 'buscarForma':
                return $this->buscarForma($params);
            case 'buscarCampania':
                return $this->buscarCampania($params);
            case 'buscarDescuento':
                return $this->buscarDescuento($params);
            case 'altaDescuento':
                return $this->altaDescuento($params, $user);
            case 'cancelarDescuento':
                return $this->cancelarDescuento($params, $user);
            case 'reporteEdoCtaLic':
                return $this->reporteEdoCtaLic($params);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    private function buscarLicencia($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            return response()->json(['error' => 'Folio requerido'], 422);
        }
        $result = DB::select('SELECT * FROM sp_buscar_licencia(?)', [$folio]);
        return response()->json(['data' => $result]);
    }

    private function buscarAnuncio($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            return response()->json(['error' => 'Folio requerido'], 422);
        }
        $result = DB::select('SELECT * FROM sp_buscar_anuncio(?)', [$folio]);
        return response()->json(['data' => $result]);
    }

    private function buscarForma($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            return response()->json(['error' => 'Folio requerido'], 422);
        }
        $result = DB::select('SELECT * FROM sp_buscar_forma(?)', [$folio]);
        return response()->json(['data' => $result]);
    }

    private function buscarCampania($params)
    {
        $fecha = $params['fecha'] ?? date('Y-m-d');
        $result = DB::select('SELECT * FROM sp_buscar_campania(?)', [$fecha]);
        return response()->json(['data' => $result]);
    }

    private function buscarDescuento($params)
    {
        $tipo = $params['tipo'] ?? null;
        $folio = $params['folio'] ?? null;
        if (!$tipo || !$folio) {
            return response()->json(['error' => 'Tipo y folio requeridos'], 422);
        }
        $result = DB::select('SELECT * FROM sp_buscar_descuento(?, ?)', [$tipo, $folio]);
        return response()->json(['data' => $result]);
    }

    private function altaDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'tipo' => 'required|string',
            'licencia' => 'required|integer',
            'porcentaje' => 'required|numeric|min:1|max:100',
            'axoini' => 'required|integer',
            'axofin' => 'required|integer',
            'autoriza' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('SELECT * FROM sp_alta_descuento(?,?,?,?,?,?,?)', [
            $params['tipo'],
            $params['licencia'],
            $params['porcentaje'],
            $params['axoini'],
            $params['axofin'],
            $params['autoriza'],
            $user->username ?? 'sistema'
        ]);
        return response()->json(['result' => $result]);
    }

    private function cancelarDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_descto' => 'required|integer',
            'licencia' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('SELECT * FROM sp_cancelar_descuento(?,?,?)', [
            $params['id_descto'],
            $params['licencia'],
            $user->username ?? 'sistema'
        ]);
        return response()->json(['result' => $result]);
    }

    private function reporteEdoCtaLic($params)
    {
        $tipo = $params['tipo'] ?? 'L';
        $numero = $params['numero'] ?? null;
        if (!$numero) {
            return response()->json(['error' => 'Número requerido'], 422);
        }
        $result = DB::select('SELECT * FROM sp_reporte_edocta_lic(?, ?)', [$tipo, $numero]);
        return response()->json(['data' => $result]);
    }
}
