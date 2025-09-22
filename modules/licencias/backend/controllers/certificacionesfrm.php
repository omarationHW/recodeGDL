<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CertificacionesController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'certificaciones.list':
                return $this->list($params);
            case 'certificaciones.create':
                return $this->create($params, $user);
            case 'certificaciones.update':
                return $this->update($params, $user);
            case 'certificaciones.cancel':
                return $this->cancel($params, $user);
            case 'certificaciones.print':
                return $this->print($params);
            case 'certificaciones.search':
                return $this->search($params);
            case 'certificaciones.listado':
                return $this->listado($params);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    public function list($params)
    {
        $tipo = $params['tipo'] ?? 'L';
        $result = DB::select('SELECT * FROM certificaciones WHERE tipo = ? ORDER BY axo DESC, folio DESC', [$tipo]);
        return response()->json(['data' => $result]);
    }

    public function create($params, $user)
    {
        $validator = Validator::make($params, [
            'tipo' => 'required|in:L,A',
            'id_licencia' => 'required|integer',
            'observacion' => 'nullable|string',
            'partidapago' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $folio = DB::selectOne('SELECT certificacion FROM parametros_lic');
        $newFolio = $folio->certificacion + 1;
        DB::beginTransaction();
        try {
            DB::update('UPDATE parametros_lic SET certificacion = ?', [$newFolio]);
            $id = DB::table('certificaciones')->insertGetId([
                'tipo' => $params['tipo'],
                'id_licencia' => $params['id_licencia'],
                'axo' => date('Y'),
                'folio' => $newFolio,
                'vigente' => 'V',
                'observacion' => $params['observacion'] ?? '',
                'partidapago' => $params['partidapago'] ?? '',
                'feccap' => now(),
                'capturista' => $user ? $user->username : 'system',
            ]);
            DB::commit();
            return response()->json(['success' => true, 'id' => $id, 'folio' => $newFolio]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function update($params, $user)
    {
        $validator = Validator::make($params, [
            'id' => 'required|integer',
            'observacion' => 'nullable|string',
            'partidapago' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $affected = DB::table('certificaciones')
            ->where('id', $params['id'])
            ->update([
                'observacion' => $params['observacion'] ?? '',
                'partidapago' => $params['partidapago'] ?? '',
                'capturista' => $user ? $user->username : 'system',
            ]);
        return response()->json(['success' => $affected > 0]);
    }

    public function cancel($params, $user)
    {
        $validator = Validator::make($params, [
            'id' => 'required|integer',
            'motivo' => 'required|string',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $affected = DB::table('certificaciones')
            ->where('id', $params['id'])
            ->update([
                'vigente' => 'C',
                'observacion' => $params['motivo'],
                'capturista' => $user ? $user->username : 'system',
            ]);
        return response()->json(['success' => $affected > 0]);
    }

    public function print($params)
    {
        // Aquí se puede generar un PDF o devolver los datos para impresión
        // Por simplicidad, devolvemos los datos de la certificación y pagos
        $id = $params['id'] ?? null;
        if (!$id) {
            return response()->json(['error' => 'ID requerido'], 422);
        }
        $cert = DB::table('certificaciones')->where('id', $id)->first();
        if (!$cert) {
            return response()->json(['error' => 'No encontrado'], 404);
        }
        $lic = DB::table('licencias')->where('id_licencia', $cert->id_licencia)->first();
        $pagos = DB::select('SELECT * FROM pagos WHERE cvecuenta = ? AND cveconcepto = 8 ORDER BY fecha DESC, hora DESC', [$cert->id_licencia]);
        return response()->json([
            'certificacion' => $cert,
            'licencia' => $lic,
            'pagos' => $pagos
        ]);
    }

    public function search($params)
    {
        // Búsqueda avanzada por año, folio, licencia, fechas
        $query = DB::table('certificaciones');
        if (!empty($params['axo'])) {
            $query->where('axo', $params['axo']);
        }
        if (!empty($params['folio'])) {
            $query->where('folio', $params['folio']);
        }
        if (!empty($params['id_licencia'])) {
            $query->where('id_licencia', $params['id_licencia']);
        }
        if (!empty($params['feccap_ini'])) {
            $query->where('feccap', '>=', $params['feccap_ini']);
        }
        if (!empty($params['feccap_fin'])) {
            $query->where('feccap', '<=', $params['feccap_fin']);
        }
        if (!empty($params['tipo'])) {
            $query->where('tipo', $params['tipo']);
        }
        $result = $query->orderBy('axo', 'desc')->orderBy('folio', 'desc')->get();
        return response()->json(['data' => $result]);
    }

    public function listado($params)
    {
        // Listado para impresión
        return $this->search($params);
    }
}
