/**
 * =======================================================
 * LICENCIAS API SERVICE
 * =======================================================
 * Servicio centralizado para llamadas API del módulo de licencias
 * Integra los stored procedures migrados a INFORMIX
 *
 * Funcionalidades cubiertas:
 * - consultaLicenciafrm (SP_CONSULTALICENCIA_*)
 * - constanciafrm (SP_CONSTANCIA_*)
 * - consultapredial (SP_CONSULTAPREDIAL_*)
 * - consultausuariosfrm (SP_CONSULTAUSUARIOS_*)
 * - dependenciasfrm (SP_DEPENDENCIAS_*)
 * - dictamenfrm (SP_DICTAMEN_*)
 * =======================================================
 */

class LicenciasApiService {
  constructor() {
    this.baseURL = 'http://localhost:8080/api/generic'
    this.tenant = 'guadalajara'
    this.database = 'padron_licencias'
  }

  /**
   * Método genérico para llamadas API
   */
  async callAPI(operation, parameters = []) {
    const requestBody = {
      eRequest: {
        Operacion: operation,
        Base: this.database,
        Parametros: parameters,
        Tenant: this.tenant
      }
    }

    try {
      console.log(`📨 API Call: ${operation}`, requestBody)

      const response = await fetch(this.baseURL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      console.log(`✅ API Response: ${operation}`, data)

      if (data.success) {
        return data.data
      } else {
        throw new Error(data.message || 'Error en la API')
      }
    } catch (error) {
      console.error(`❌ API Error: ${operation}`, error)
      throw error
    }
  }

  // =======================================================
  // CONSULTA LICENCIAS (consultaLicenciafrm)
  // =======================================================

  /**
   * Lista todas las licencias comerciales
   */
  async getConsultaLicenciasList(filters = {}) {
    const params = [
      { nombre: 'p_numero_licencia', valor: filters.numero_licencia || null },
      { nombre: 'p_razon_social', valor: filters.razon_social || null },
      { nombre: 'p_giro', valor: filters.giro || null },
      { nombre: 'p_direccion', valor: filters.direccion || null },
      { nombre: 'p_colonia', valor: filters.colonia || null },
      { nombre: 'p_estado', valor: filters.estado || null },
      { nombre: 'p_limite', valor: filters.limite || 100 },
      { nombre: 'p_offset', valor: filters.offset || 0 }
    ]

    const result = await this.callAPI('sp_consultalicencia_list', params)

    // Transformar campos de la respuesta API a los nombres esperados por el componente Vue
    if (result && Array.isArray(result)) {
      return result.map(record => ({
        id: record.id,
        num_lic: record.numero_licencia || '',
        razon_social: record.propietario || '',
        rfc: record.rfc || '',
        nombre_giro: record.giro || '',
        direccion: record.direccion || '',
        colonia: record.colonia || '',
        telefono: record.telefono || '',
        status_lic: record.estado || 'ACTIVA',
        fecha_expedicion: record.fecha_expedicion || null,
        fecha_vencimiento: record.fecha_vencimiento || null,
        observaciones: record.observaciones || ''
      }))
    }

    return result
  }

  /**
   * Obtiene una licencia específica por ID
   */
  async getConsultaLicenciaById(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_consultalicencia_read', params)
  }

  /**
   * Crea una nueva licencia comercial
   */
  async createConsultaLicencia(licenciaData) {
    const params = [
      { nombre: 'p_numero_licencia', valor: licenciaData.numero_licencia },
      { nombre: 'p_folio', valor: licenciaData.folio || null },
      { nombre: 'p_tipo_licencia', valor: licenciaData.tipo_licencia || 'COMERCIAL' },
      { nombre: 'p_cuenta_predial', valor: licenciaData.cuenta_predial || null },
      { nombre: 'p_propietario', valor: licenciaData.propietario },
      { nombre: 'p_razon_social', valor: licenciaData.razon_social || null },
      { nombre: 'p_rfc', valor: licenciaData.rfc || null },
      { nombre: 'p_direccion', valor: licenciaData.direccion },
      { nombre: 'p_colonia', valor: licenciaData.colonia || null },
      { nombre: 'p_codigo_postal', valor: licenciaData.codigo_postal || null },
      { nombre: 'p_telefono', valor: licenciaData.telefono || null },
      { nombre: 'p_email', valor: licenciaData.email || null },
      { nombre: 'p_giro', valor: licenciaData.giro || null },
      { nombre: 'p_actividad', valor: licenciaData.actividad || null },
      { nombre: 'p_superficie_autorizada', valor: licenciaData.superficie_autorizada || null },
      { nombre: 'p_horario_operacion', valor: licenciaData.horario_operacion || null },
      { nombre: 'p_numero_empleados', valor: licenciaData.numero_empleados || null },
      { nombre: 'p_fecha_solicitud', valor: licenciaData.fecha_solicitud || null },
      { nombre: 'p_fecha_expedicion', valor: licenciaData.fecha_expedicion || null },
      { nombre: 'p_fecha_vencimiento', valor: licenciaData.fecha_vencimiento || null },
      { nombre: 'p_estado', valor: licenciaData.estado || 'VIGENTE' },
      { nombre: 'p_observaciones', valor: licenciaData.observaciones || null },
      { nombre: 'p_usuario_registro', valor: licenciaData.usuario_registro || 'SISTEMA' }
    ]

    return await this.callAPI('sp_consultalicencia_create', params)
  }

  /**
   * Actualiza una licencia comercial existente
   */
  async updateConsultaLicencia(id, licenciaData) {
    const params = [
      { nombre: 'p_id', valor: id },
      { nombre: 'p_numero_licencia', valor: licenciaData.numero_licencia },
      { nombre: 'p_folio', valor: licenciaData.folio },
      { nombre: 'p_tipo_licencia', valor: licenciaData.tipo_licencia },
      { nombre: 'p_cuenta_predial', valor: licenciaData.cuenta_predial },
      { nombre: 'p_propietario', valor: licenciaData.propietario },
      { nombre: 'p_razon_social', valor: licenciaData.razon_social },
      { nombre: 'p_rfc', valor: licenciaData.rfc },
      { nombre: 'p_direccion', valor: licenciaData.direccion },
      { nombre: 'p_colonia', valor: licenciaData.colonia },
      { nombre: 'p_codigo_postal', valor: licenciaData.codigo_postal },
      { nombre: 'p_telefono', valor: licenciaData.telefono },
      { nombre: 'p_email', valor: licenciaData.email },
      { nombre: 'p_giro', valor: licenciaData.giro },
      { nombre: 'p_actividad', valor: licenciaData.actividad },
      { nombre: 'p_superficie_autorizada', valor: licenciaData.superficie_autorizada },
      { nombre: 'p_horario_operacion', valor: licenciaData.horario_operacion },
      { nombre: 'p_numero_empleados', valor: licenciaData.numero_empleados },
      { nombre: 'p_fecha_solicitud', valor: licenciaData.fecha_solicitud },
      { nombre: 'p_fecha_expedicion', valor: licenciaData.fecha_expedicion },
      { nombre: 'p_fecha_vencimiento', valor: licenciaData.fecha_vencimiento },
      { nombre: 'p_estado', valor: licenciaData.estado },
      { nombre: 'p_observaciones', valor: licenciaData.observaciones }
    ]

    return await this.callAPI('sp_consultalicencia_update', params)
  }

  /**
   * Elimina una licencia comercial
   */
  async deleteConsultaLicencia(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_consultalicencia_delete', params)
  }

  // =======================================================
  // CONSTANCIAS (constanciafrm)
  // =======================================================

  /**
   * Lista todas las constancias con filtros
   */
  async getConstanciasList(filters = {}) {
    const params = [
      { nombre: 'p_axo', valor: filters.axo || null },
      { nombre: 'p_folio', valor: filters.folio || null },
      { nombre: 'p_solicita', valor: filters.solicita || null },
      { nombre: 'p_partidapago', valor: filters.partidapago || null },
      { nombre: 'p_vigente', valor: filters.vigente || null },
      { nombre: 'p_limite', valor: filters.limite || 100 },
      { nombre: 'p_offset', valor: filters.offset || 0 }
    ]

    return await this.callAPI('sp_constancia_list', params)
  }

  /**
   * Obtiene una constancia específica por ID
   */
  async getConstanciaById(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_constancia_read', params)
  }

  /**
   * Crea una nueva constancia
   */
  async createConstancia(constanciaData) {
    const params = [
      { nombre: 'p_id_licencia', valor: constanciaData.id_licencia },
      { nombre: 'p_solicita', valor: constanciaData.solicita },
      { nombre: 'p_partidapago', valor: constanciaData.partidapago || null },
      { nombre: 'p_observacion', valor: constanciaData.observacion || null },
      { nombre: 'p_domicilio', valor: constanciaData.domicilio || null },
      { nombre: 'p_tipo', valor: constanciaData.tipo || 1 },
      { nombre: 'p_capturista', valor: constanciaData.capturista || 'SISTEMA' }
    ]

    return await this.callAPI('sp_constancia_create', params)
  }

  /**
   * Actualiza una constancia existente
   */
  async updateConstancia(id, constanciaData) {
    const params = [
      { nombre: 'p_id', valor: id },
      { nombre: 'p_id_licencia', valor: constanciaData.id_licencia },
      { nombre: 'p_solicita', valor: constanciaData.solicita },
      { nombre: 'p_partidapago', valor: constanciaData.partidapago },
      { nombre: 'p_observacion', valor: constanciaData.observacion },
      { nombre: 'p_domicilio', valor: constanciaData.domicilio },
      { nombre: 'p_tipo', valor: constanciaData.tipo },
      { nombre: 'p_vigente', valor: constanciaData.vigente }
    ]

    return await this.callAPI('sp_constancia_update', params)
  }

  /**
   * Elimina una constancia
   */
  async deleteConstancia(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_constancia_delete', params)
  }

  // =======================================================
  // CONSULTA PREDIAL (consultapredial)
  // =======================================================

  /**
   * Lista información predial con filtros
   */
  async getConsultaPredialList(filters = {}) {
    const params = [
      { nombre: 'p_cuenta_predial', valor: filters.cuenta_predial || null },
      { nombre: 'p_propietario', valor: filters.propietario || null },
      { nombre: 'p_direccion', valor: filters.direccion || null },
      { nombre: 'p_colonia', valor: filters.colonia || null },
      { nombre: 'p_estado', valor: filters.estado || null },
      { nombre: 'p_limite', valor: filters.limite || 100 },
      { nombre: 'p_offset', valor: filters.offset || 0 }
    ]

    return await this.callAPI('sp_consultapredial_list', params)
  }

  /**
   * Obtiene información predial específica por ID
   */
  async getConsultaPredialById(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_consultapredial_read', params)
  }

  /**
   * Crea nueva información predial
   */
  async createConsultaPredial(predialData) {
    const params = [
      { nombre: 'p_cuenta_predial', valor: predialData.cuenta_predial },
      { nombre: 'p_propietario', valor: predialData.propietario || null },
      { nombre: 'p_direccion', valor: predialData.direccion || null },
      { nombre: 'p_colonia', valor: predialData.colonia || null },
      { nombre: 'p_codigo_postal', valor: predialData.codigo_postal || null },
      { nombre: 'p_superficie_terreno', valor: predialData.superficie_terreno || null },
      { nombre: 'p_superficie_construccion', valor: predialData.superficie_construccion || null },
      { nombre: 'p_uso_suelo', valor: predialData.uso_suelo || null },
      { nombre: 'p_zona', valor: predialData.zona || null },
      { nombre: 'p_valor_catastral', valor: predialData.valor_catastral || null },
      { nombre: 'p_coordenada_x', valor: predialData.coordenada_x || null },
      { nombre: 'p_coordenada_y', valor: predialData.coordenada_y || null },
      { nombre: 'p_observaciones', valor: predialData.observaciones || null }
    ]

    return await this.callAPI('sp_consultapredial_create', params)
  }

  /**
   * Actualiza información predial existente
   */
  async updateConsultaPredial(id, predialData) {
    const params = [
      { nombre: 'p_id', valor: id },
      { nombre: 'p_cuenta_predial', valor: predialData.cuenta_predial },
      { nombre: 'p_propietario', valor: predialData.propietario },
      { nombre: 'p_direccion', valor: predialData.direccion },
      { nombre: 'p_colonia', valor: predialData.colonia },
      { nombre: 'p_codigo_postal', valor: predialData.codigo_postal },
      { nombre: 'p_superficie_terreno', valor: predialData.superficie_terreno },
      { nombre: 'p_superficie_construccion', valor: predialData.superficie_construccion },
      { nombre: 'p_uso_suelo', valor: predialData.uso_suelo },
      { nombre: 'p_zona', valor: predialData.zona },
      { nombre: 'p_valor_catastral', valor: predialData.valor_catastral },
      { nombre: 'p_estado', valor: predialData.estado },
      { nombre: 'p_coordenada_x', valor: predialData.coordenada_x },
      { nombre: 'p_coordenada_y', valor: predialData.coordenada_y },
      { nombre: 'p_observaciones', valor: predialData.observaciones }
    ]

    return await this.callAPI('sp_consultapredial_update', params)
  }

  /**
   * Elimina información predial
   */
  async deleteConsultaPredial(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_consultapredial_delete', params)
  }

  // =======================================================
  // CONSULTA USUARIOS (consultausuariosfrm)
  // =======================================================

  /**
   * Lista usuarios del sistema
   */
  async getConsultaUsuariosList(filters = {}) {
    const params = [
      { nombre: 'p_nombre', valor: filters.nombre || null },
      { nombre: 'p_usuario', valor: filters.usuario || null },
      { nombre: 'p_perfil', valor: filters.perfil || null },
      { nombre: 'p_activo', valor: filters.activo || null },
      { nombre: 'p_limite', valor: filters.limite || 100 },
      { nombre: 'p_offset', valor: filters.offset || 0 }
    ]

    return await this.callAPI('sp_consultausuarios_list', params)
  }

  /**
   * Obtiene un usuario específico por ID
   */
  async getConsultaUsuarioById(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_consultausuarios_read', params)
  }

  // =======================================================
  // DEPENDENCIAS (dependenciasfrm)
  // =======================================================

  /**
   * Lista dependencias administrativas
   */
  async getDependenciasList(filters = {}) {
    const params = [
      { nombre: 'p_nombre', valor: filters.nombre || null },
      { nombre: 'p_tipo', valor: filters.tipo || null },
      { nombre: 'p_activa', valor: filters.activa || null },
      { nombre: 'p_limite', valor: filters.limite || 100 },
      { nombre: 'p_offset', valor: filters.offset || 0 }
    ]

    return await this.callAPI('sp_dependencias_list', params)
  }

  /**
   * Obtiene una dependencia específica por ID
   */
  async getDependenciaById(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_dependencias_read', params)
  }

  // =======================================================
  // DICTAMEN (dictamenfrm)
  // =======================================================

  /**
   * Lista dictámenes
   */
  async getDictamenList(filters = {}) {
    const params = [
      { nombre: 'p_numero_dictamen', valor: filters.numero_dictamen || null },
      { nombre: 'p_solicitante', valor: filters.solicitante || null },
      { nombre: 'p_tipo_dictamen', valor: filters.tipo_dictamen || null },
      { nombre: 'p_estado', valor: filters.estado || null },
      { nombre: 'p_limite', valor: filters.limite || 100 },
      { nombre: 'p_offset', valor: filters.offset || 0 }
    ]

    return await this.callAPI('sp_dictamen_list', params)
  }

  /**
   * Obtiene un dictamen específico por ID
   */
  async getDictamenById(id) {
    const params = [{ nombre: 'p_id', valor: id }]
    return await this.callAPI('sp_dictamen_read', params)
  }

  // =======================================================
  // MÉTODOS DE UTILIDAD
  // =======================================================

  /**
   * Verifica el estado del servidor API
   */
  async checkHealth() {
    try {
      const response = await fetch('http://localhost:8080/health')
      return await response.json()
    } catch (error) {
      console.error('Health check failed:', error)
      throw error
    }
  }

  /**
   * Obtiene información del sistema
   */
  async getSystemInfo() {
    return await this.callAPI('sp_system_info')
  }
}

// Exportar instancia singleton
export default new LicenciasApiService()

// También exportar la clase para casos especiales
export { LicenciasApiService }