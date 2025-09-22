<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\eRequest;
use App\Models\eResponse;
use App\Services\DatabaseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UnifiedController extends Controller
{
    private DatabaseService $dbService;
    
    public function __construct(DatabaseService $dbService)
    {
        $this->dbService = $dbService;
    }
    
    public function execute(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'Tipo' => 'required|integer|in:0,1',
                'Base' => 'required|string',
                'Operacion' => 'required|string',
                'Parametros' => 'nullable|array',
                'Tiempo' => 'nullable|integer'
            ]);
            
            if ($validator->fails()) {
                return response()->json(
                    eResponse::error(400, 'Parámetros inválidos'),
                    400
                );
            }
            
            $eRequest = new eRequest($request->all());
            
            // Construir automáticamente el nombre del stored procedure
            $storedProcedure = $this->buildStoredProcedureName($eRequest->Operacion);
            
            // Validar que la operación sea válida (seguridad)
            if (!$this->isValidOperation($eRequest->Operacion)) {
                return response()->json(
                    eResponse::error(404, 'Operación no encontrada: ' . $eRequest->Operacion),
                    404
                );
            }
            
            $result = $this->dbService->executeProcedure($eRequest, $storedProcedure);
            
            if ($eRequest->Tipo === 0) {
                return response()->json(eResponse::success(0, $result));
            } else {
                $id = $result['id'] ?? 0;
                return response()->json(eResponse::success($id));
            }
            
        } catch (\Exception $e) {
            return response()->json(
                eResponse::error(500, 'Error interno: ' . $e->getMessage()),
                500
            );
        }
    }
    
    public function health()
    {
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now(),
            'service' => 'Unified API'
        ]);
    }
    
    /**
     * Construye automáticamente el nombre del stored procedure basado en la operación
     */
    private function buildStoredProcedureName(string $operacion): string
    {
        return 'sp_' . strtolower($operacion);
    }
    
    /**
     * Valida que la operación solicitada sea permitida (lista blanca para seguridad)
     */
    private function isValidOperation(string $operacion): bool
    {
        $validOperations = [
            'log_aviso_acknowledgement',
            'get_propietarios',
            'get_calidades',
            'update_porcentajes',
            'exento_en_saldos',
            'calc_dpp',
            'calc_saldos',
            'calc_recargos',
            'get_catastro_by_cuenta',
            'cancel_account',
            'calc_sdos',
            'get_movimientos',
            'get_departamentos',
            'get_comprobantes_report',
            'get_comprobantes_totales_dia',
            'condueños_list',
            'condueños_show',
            'condueños_create',
            'condueños_update',
            'condueños_delete',
            'condueños_restore',
            'condueños_porcentajes',
            'condueños_history',
            'condueños_validate_rfc',
            'condueños_add_colonia',
            'consreq400_search',
            'constp_query',
            'consultar_transmision_por_folio',
            'consultar_transmisiones_por_fechas',
            'contar_folios_por_fechas',
            'consultar_transmisiones_totales_por_fecha',
            'consultar_pagos_transmisiones_patrimoniales',
            'consultar_transmisiones_patrimoniales',
            'consume400_search',
            'consulta_predial_get_cuenta',
            'consulta_predial_get_saldos',
            'consulta_predial_get_recibos',
            'consulta_predial_get_requerimientos',
            'consulta_predial_get_regimen_propiedad',
            'consulta_predial_get_valores',
            'consulta_predial_get_ubicacion',
            'get_cvecatdup_list',
            'add_cvecatdup',
            'delete_cvecatdup',
            'get_cvecat_info',
            'validate_cvecat',
            'update_cvecat',
            'check_blocked_manzana',
            'actualiza_catastro_ubicacion',
            'get_ubicacion_by_cuenta',
            'get_calles',
            'get_colonias',
            'registrar_exencion',
            'eliminar_exencion',
            'exento_en_saldos',
            'construc_list',
            'construc_show',
            'construc_create',
            'construc_update',
            'construc_delete',
            'construc_list',
            'construc_get',
            'construc_create',
            'construc_update',
            'construc_delete',
            'get_observa_comprobante',
            'update_observa_comprobante',
            'get_historico_comprobante',
            'funcion_abstencion_get_abstenciones',
            'funcion_abstencion_get_by_cuenta',
            'funcion_abstencion_add',
            'funcion_abstencion_remove',
            'validate_hasta_form',
            'impno_get_notification_data',
            'update_investcta',
            'loctp_search',
            'loctp_municipios',
            'loctp_detalle',
            'loctp_update_observacion',
            'muestradup_list',
            'muestradup_show',
            'muestradup_create',
            'muestradup_update',
            'muestradup_delete',
            'muestradup_report',
            'muestradup_integrate',
            'observa_transm_list',
            'observa_transm_get',
            'observa_transm_create',
            'observa_transm_update',
            'observa_transm_delete',
            'observa_transm_create',
            'observa_transm_update',
            'observa_transm_delete',
            'observa_transm_lock',
            'observa_transm_unlock',
            'passpropietario_login',
            'passpropietario_validate',
            'passwdfrm_login',
            'passwdfrm_get_user',
            'get_preferencial_list',
            'get_tasas_validas',
            'add_preferencial',
            'update_preferencial',
            'baja_preferencial',
            'prepago_get_resumen',
            'prepago_get_periodos',
            'prepago_get_ultimo_requerimiento',
            'prepago_get_descuentos',
            'prepago_liquidacion_parcial',
            'prepago_calcula_multa_virtual',
            'calc_sdos',
            'propuestatab1_list',
            'propuestatab1_show',
            'propuestatab1_create',
            'propuestatab1_update',
            'propuestatab1_delete',
            'propuestatab1_history',
            'propuestatab1_regimen',
            'propuestatab1_valores',
            'propuestatab1_pagos',
            'propuestatab1_diferencias',
            'propuestatab1_obs400',
            'propuestatab1_cfs400',
            'propuestatab1_escrituras',
            'propuestatab1_condominio',
            'psplash_get_splash_info',
            'psplash_log_splash_view',
            'extractos_rango_cuentas',
            'extractos_rango_capturista',
            'reactivar_cuenta',
            'get_cuenta',
            'get_observacion',
            'rechazar_transmision',
            'get_motivo_rechazo',
            'reghfrm_list_history',
            'reghfrm_show_record',
            'reghfrm_search_history',
            'reghfrm_filter_history',
            'reghfrm_account_history',
            'upd_firma',
            'chgpass_validate_current',
            'chgpass_validate_new',
            'chgpass_update',
            'buscar_cuenta',
            'login_usuario',
            'cambiar_clave',
            'consultar_propietarios',
            'guardar_propietario',
            'consultar_liquidacion',
            'autorizar_transmision',
            'consultar_horario_usuario',
            'consultar_version',
            'login',
            'calc_impto_transpat',
            'save_adquiriente',
            'get_porcentaje_total',
            'get_encabeza',
            'save_transmision_pat',
            'get_avaluos_externos',
            'get_valoresref',
            'get_notarios',
            'get_municipios',
            'get_naturalezas_acto',
            'crea_tmpvalade',
            'upd_tmpvalade',
            'get_tasas',
            'get_valores_aux_list',
            'get_valores_aux_by_id',
            'create_valores_aux',
            'update_valores_aux',
            'delete_valores_aux'
        ];
        
        return in_array(strtolower($operacion), $validOperations);
    }
}