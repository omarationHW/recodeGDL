<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class BloqueoRfcController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'getBloqueosRfc':
                return $this->getBloqueosRfc($params);
            case 'searchBloqueosRfc':
                return $this->searchBloqueosRfc($params);
            case 'getTramiteInfo':
                return $this->getTramiteInfo($params);
            case 'addBloqueoRfc':
                return $this->addBloqueoRfc($params, $user);
            case 'editBloqueoRfc':
                return $this->editBloqueoRfc($params, $user);
            case 'desbloquearRfc':
                return $this->desbloquearRfc($params, $user);
            case 'exportBloqueosRfc':
                return $this->exportBloqueosRfc($params);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    public function getBloqueosRfc($params)
    {
        $result = DB::select('SELECT * FROM bloqueo_rfc_lic ORDER BY rfc');
        return response()->json(['data' => $result]);
    }

    public function searchBloqueosRfc($params)
    {
        $rfc = strtoupper(trim($params['rfc'] ?? ''));
        if ($rfc === '') {
            return $this->getBloqueosRfc($params);
        }
        $result = DB::select('SELECT * FROM bloqueo_rfc_lic WHERE rfc ILIKE ?', ["%$rfc%"]);
        return response()->json(['data' => $result]);
    }

    public function getTramiteInfo($params)
    {
        $id_tramite = $params['id_tramite'] ?? null;
        if (!$id_tramite) {
            return response()->json(['error' => 'id_tramite requerido'], 400);
        }
        $result = DB::select('SELECT t.*, a.rfc, a.id_tramite, a.id_licencia, a.hora, a.vig, a.observacion, a.capturista, ' .
            'trim(trim(coalesce(t.primer_ap, '')) || ' ' || trim(coalesce(t.segundo_ap, '')) || ' ' || trim(t.propietario)) as propietarionvo ' .
            'FROM lic_autoev a JOIN tramites t ON t.id_tramite = a.id_tramite WHERE a.id_tramite = ?', [$id_tramite]);
        if (count($result) === 0) {
            return response()->json(['error' => 'Trámite no encontrado'], 404);
        }
        return response()->json(['data' => $result[0]]);
    }

    public function addBloqueoRfc($params, $user)
    {
        $validator = Validator::make($params, [
            'rfc' => 'required|string|max:13',
            'id_tramite' => 'required|integer',
            'licencia' => 'required|integer',
            'observacion' => 'nullable|string|max:255',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $rfc = strtoupper($params['rfc']);
        $id_tramite = $params['id_tramite'];
        $licencia = $params['licencia'];
        $observacion = $params['observacion'] ?? '';
        $capturista = $user ? $user->username : 'sistema';
        $now = now();
        // Verifica que no exista ya un bloqueo vigente
        $exists = DB::selectOne('SELECT 1 FROM bloqueo_rfc_lic WHERE rfc = ? AND vig = ? LIMIT 1', [$rfc, 'V']);
        if ($exists) {
            return response()->json(['error' => 'Ya existe un bloqueo vigente para este RFC'], 409);
        }
        DB::insert('INSERT INTO bloqueo_rfc_lic (rfc, id_tramite, licencia, hora, vig, observacion, capturista) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [$rfc, $id_tramite, $licencia, $now, 'V', $observacion, $capturista]);
        return response()->json(['success' => true]);
    }

    public function editBloqueoRfc($params, $user)
    {
        $validator = Validator::make($params, [
            'rfc' => 'required|string|max:13',
            'observacion' => 'nullable|string|max:255',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $rfc = strtoupper($params['rfc']);
        $observacion = $params['observacion'] ?? '';
        $capturista = $user ? $user->username : 'sistema';
        $now = now();
        $updated = DB::update('UPDATE bloqueo_rfc_lic SET observacion = ?, hora = ?, capturista = ? WHERE rfc = ? AND vig = ?',
            [$observacion, $now, $capturista, $rfc, 'V']);
        if ($updated === 0) {
            return response()->json(['error' => 'No se encontró el registro para editar'], 404);
        }
        return response()->json(['success' => true]);
    }

    public function desbloquearRfc($params, $user)
    {
        $validator = Validator::make($params, [
            'rfc' => 'required|string|max:13',
            'observacion' => 'nullable|string|max:255',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $rfc = strtoupper($params['rfc']);
        $observacion = $params['observacion'] ?? '';
        $capturista = $user ? $user->username : 'sistema';
        $now = now();
        $updated = DB::update('UPDATE bloqueo_rfc_lic SET observacion = ?, vig = ?, hora = ?, capturista = ? WHERE rfc = ? AND vig = ?',
            [$observacion, 'C', $now, $capturista, $rfc, 'V']);
        if ($updated === 0) {
            return response()->json(['error' => 'No se encontró el registro para desbloquear'], 404);
        }
        return response()->json(['success' => true]);
    }

    public function exportBloqueosRfc($params)
    {
        // Exportar a Excel (CSV)
        $result = DB::select('SELECT * FROM bloqueo_rfc_lic ORDER BY rfc');
        $csv = "rfc,id_tramite,licencia,hora,vig,observacion,capturista\n";
        foreach ($result as $row) {
            $csv .= sprintf("%s,%d,%d,%s,%s,%s,%s\n",
                $row->rfc, $row->id_tramite, $row->licencia, $row->hora, $row->vig, str_replace(["\n", ","], [" ", ";"], $row->observacion), $row->capturista
            );
        }
        return response($csv, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="bloqueos_rfc.csv"'
        ]);
    }
}
