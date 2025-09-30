<template>
  <div class="municipal-form-page">
    <!-- Header -->
    <div class="municipal-header">
      <div class="container-fluid">
        <div class="row align-items-center">
          <div class="col">
            <div class="d-flex align-items-center">
              <div class="municipal-icon me-3">
                <i class="fas fa-shield-check"></i>
              </div>
              <div>
                <h1 class="municipal-title mb-1">Sistema de Validación de Datos Reales</h1>
                <p class="municipal-subtitle mb-0">
                  <i class="fas fa-database me-2"></i>
                  Verificación contra fuentes oficiales (SAT, RENAPO, INEGI)
                </p>
              </div>
            </div>
          </div>
          <div class="col-auto">
            <div class="municipal-stats">
              <div class="stat-item">
                <div class="stat-number">{{ estadisticas.total_validaciones || 0 }}</div>
                <div class="stat-label">Validaciones</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ estadisticas.promedio_score || 0 }}%</div>
                <div class="stat-label">Score Promedio</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Búsqueda y Validación -->
    <div class="container-fluid py-4">
      <div class="row">
        <!-- Panel de Búsqueda -->
        <div class="col-lg-6">
          <div class="municipal-card h-100">
            <div class="card-header municipal-card-header">
              <h5 class="mb-0">
                <i class="fas fa-search me-2"></i>
                Búsqueda de Contribuyente
              </h5>
            </div>
            <div class="card-body">
              <form @submit.prevent="buscarContribuyente">
                <div class="row g-3">
                  <div class="col-md-4">
                    <label class="form-label fw-bold">Tipo de Búsqueda</label>
                    <select v-model="formBusqueda.tipo" class="form-select municipal-select" required>
                      <option value="">Seleccionar...</option>
                      <option value="RFC">RFC</option>
                      <option value="CURP">CURP</option>
                      <option value="LICENCIA">No. Licencia</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-bold">Valor a Buscar</label>
                    <input
                      v-model="formBusqueda.valor"
                      type="text"
                      class="form-control municipal-input"
                      :placeholder="getPlaceholderBusqueda()"
                      required
                      :maxlength="getMaxLength()"
                      @input="validateInput"
                    >
                    <div v-if="validationMessage" class="invalid-feedback d-block">
                      {{ validationMessage }}
                    </div>
                  </div>
                  <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <button
                      type="submit"
                      class="btn btn-municipal-primary w-100"
                      :disabled="loading || !isFormValid()"
                    >
                      <i v-if="loading" class="fas fa-spinner fa-spin me-2"></i>
                      <i v-else class="fas fa-search me-2"></i>
                      {{ loading ? 'Buscando...' : 'Buscar' }}
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Panel de Acciones Rápidas -->
        <div class="col-lg-6">
          <div class="municipal-card h-100">
            <div class="card-header municipal-card-header">
              <h5 class="mb-0">
                <i class="fas fa-bolt me-2"></i>
                Acciones Rápidas
              </h5>
            </div>
            <div class="card-body">
              <div class="row g-2">
                <div class="col-6">
                  <button @click="mostrarHistorial" class="btn btn-outline-municipal w-100">
                    <i class="fas fa-history me-2"></i>
                    Historial
                  </button>
                </div>
                <div class="col-6">
                  <button @click="mostrarEstadisticas" class="btn btn-outline-municipal w-100">
                    <i class="fas fa-chart-bar me-2"></i>
                    Estadísticas
                  </button>
                </div>
                <div class="col-6">
                  <button @click="validacionCruzada" class="btn btn-outline-municipal w-100" :disabled="!datosValidacion.rfc">
                    <i class="fas fa-check-double me-2"></i>
                    Val. Cruzada
                  </button>
                </div>
                <div class="col-6">
                  <button @click="generarCertificado" class="btn btn-outline-municipal w-100" :disabled="!certificadoDisponible">
                    <i class="fas fa-certificate me-2"></i>
                    Certificado
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados de Validación -->
      <div v-if="datosValidacion.rfc" class="row mt-4">
        <div class="col-12">
          <div class="municipal-card">
            <div class="card-header municipal-card-header">
              <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                  <i class="fas fa-user-check me-2"></i>
                  Datos del Contribuyente
                </h5>
                <div class="d-flex align-items-center">
                  <span class="municipal-badge municipal-badge-score me-2">
                    Score: {{ datosValidacion.score_confiabilidad }}%
                  </span>
                  <span :class="getStatusClass(datosValidacion.score_confiabilidad)">
                    {{ getStatusText(datosValidacion.score_confiabilidad) }}
                  </span>
                </div>
              </div>
            </div>
            <div class="card-body">
              <div class="row">
                <!-- Información Básica -->
                <div class="col-lg-6">
                  <h6 class="text-muted mb-3">
                    <i class="fas fa-id-card me-2"></i>
                    Información Básica
                  </h6>
                  <table class="table table-sm table-borderless">
                    <tbody>
                      <tr>
                        <td class="fw-bold text-muted" style="width: 40%">RFC:</td>
                        <td><code class="bg-light p-1 rounded">{{ datosValidacion.rfc }}</code></td>
                      </tr>
                      <tr>
                        <td class="fw-bold text-muted">CURP:</td>
                        <td><code class="bg-light p-1 rounded">{{ datosValidacion.curp }}</code></td>
                      </tr>
                      <tr>
                        <td class="fw-bold text-muted">Nombre:</td>
                        <td>{{ datosValidacion.nombre_completo }}</td>
                      </tr>
                      <tr>
                        <td class="fw-bold text-muted">Domicilio:</td>
                        <td>{{ datosValidacion.domicilio_fiscal }}</td>
                      </tr>
                      <tr>
                        <td class="fw-bold text-muted">Actividad:</td>
                        <td>{{ datosValidacion.actividad_economica }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <!-- Estados de Validación -->
                <div class="col-lg-6">
                  <h6 class="text-muted mb-3">
                    <i class="fas fa-check-circle me-2"></i>
                    Estados de Validación
                  </h6>
                  <div class="validation-status">
                    <div class="status-item">
                      <span class="status-label">SAT:</span>
                      <span :class="getValidationBadgeClass(datosValidacion.estatus_sat)">
                        <i class="fas fa-check-circle me-1"></i>
                        {{ datosValidacion.estatus_sat }}
                      </span>
                    </div>
                    <div class="status-item">
                      <span class="status-label">RENAPO:</span>
                      <span :class="getValidationBadgeClass(datosValidacion.estatus_renapo)">
                        <i class="fas fa-check-circle me-1"></i>
                        {{ datosValidacion.estatus_renapo }}
                      </span>
                    </div>
                    <div class="status-item">
                      <span class="status-label">Última Validación:</span>
                      <span class="text-muted">
                        <i class="fas fa-clock me-1"></i>
                        {{ formatearFecha(datosValidacion.ultima_validacion) }}
                      </span>
                    </div>
                    <div class="status-item">
                      <span class="status-label">Discrepancias:</span>
                      <span :class="datosValidacion.discrepancias_encontradas === 0 ? 'text-success' : 'text-warning'">
                        <i :class="datosValidacion.discrepancias_encontradas === 0 ? 'fas fa-check' : 'fas fa-exclamation-triangle'" class="me-1"></i>
                        {{ datosValidacion.discrepancias_encontradas }} encontradas
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Acciones del Contribuyente -->
              <div class="row mt-3">
                <div class="col-12">
                  <div class="d-flex gap-2 flex-wrap">
                    <button @click="validarRFC" class="btn btn-outline-primary btn-sm">
                      <i class="fas fa-building me-1"></i>
                      Validar RFC (SAT)
                    </button>
                    <button @click="validarCURP" class="btn btn-outline-info btn-sm">
                      <i class="fas fa-id-badge me-1"></i>
                      Validar CURP (RENAPO)
                    </button>
                    <button @click="validarDomicilio" class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-map-marker-alt me-1"></i>
                      Validar Domicilio (INEGI)
                    </button>
                    <button @click="exportarDatos" class="btn btn-outline-success btn-sm">
                      <i class="fas fa-file-export me-1"></i>
                      Exportar Datos
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Historial -->
    <div class="modal fade" id="modalHistorial" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-history me-2"></i>
              Historial de Validaciones
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <!-- Filtros -->
            <div class="row g-3 mb-4">
              <div class="col-md-3">
                <label class="form-label">Filtrar por:</label>
                <select v-model="filtrosHistorial.tipo" class="form-select">
                  <option value="TODOS">Todos</option>
                  <option value="RFC">RFC</option>
                  <option value="CURP">CURP</option>
                  <option value="FECHA">Fecha</option>
                </select>
              </div>
              <div class="col-md-3">
                <label class="form-label">Valor:</label>
                <input v-model="filtrosHistorial.valor" type="text" class="form-control">
              </div>
              <div class="col-md-2">
                <label class="form-label">Desde:</label>
                <input v-model="filtrosHistorial.fechaInicio" type="date" class="form-control">
              </div>
              <div class="col-md-2">
                <label class="form-label">Hasta:</label>
                <input v-model="filtrosHistorial.fechaFin" type="date" class="form-control">
              </div>
              <div class="col-md-2">
                <label class="form-label">&nbsp;</label>
                <button @click="cargarHistorial" class="btn btn-municipal-primary w-100">
                  <i class="fas fa-search me-1"></i>
                  Filtrar
                </button>
              </div>
            </div>

            <!-- Tabla de Historial -->
            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-light">
                  <tr>
                    <th>ID</th>
                    <th>Tipo</th>
                    <th>Identificador</th>
                    <th>Nombre</th>
                    <th>Score</th>
                    <th>Resultado</th>
                    <th>Certificado</th>
                    <th>Fecha</th>
                    <th>Usuario</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in historial" :key="item.id_historial">
                    <td>{{ item.id_historial }}</td>
                    <td>
                      <span class="municipal-badge municipal-badge-secondary">
                        {{ item.tipo_validacion }}
                      </span>
                    </td>
                    <td><code>{{ item.identificador }}</code></td>
                    <td>{{ item.nombre_validado }}</td>
                    <td>
                      <span class="municipal-badge municipal-badge-score">
                        {{ item.score_obtenido.toFixed(1) }}%
                      </span>
                    </td>
                    <td>
                      <span :class="getResultadoBadgeClass(item.resultado)">
                        {{ item.resultado }}
                      </span>
                    </td>
                    <td>
                      <span v-if="item.certificado_emitido" class="text-success">
                        <i class="fas fa-certificate me-1"></i>
                        {{ item.folio_certificado }}
                      </span>
                      <span v-else class="text-muted">
                        <i class="fas fa-minus"></i>
                        Sin certificado
                      </span>
                    </td>
                    <td>{{ formatearFecha(item.fecha_validacion) }}</td>
                    <td>{{ item.usuario_validador }}</td>
                    <td>
                      <button @click="verDetalleHistorial(item)" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Paginación -->
            <nav v-if="paginacionHistorial.totalPaginas > 1">
              <ul class="pagination justify-content-center">
                <li class="page-item" :class="{ disabled: paginacionHistorial.paginaActual === 1 }">
                  <button class="page-link" @click="cambiarPagina(paginacionHistorial.paginaActual - 1)">
                    <i class="fas fa-chevron-left"></i>
                  </button>
                </li>
                <li v-for="pagina in getPaginasVisibles()" :key="pagina"
                    class="page-item"
                    :class="{ active: pagina === paginacionHistorial.paginaActual }">
                  <button class="page-link" @click="cambiarPagina(pagina)">{{ pagina }}</button>
                </li>
                <li class="page-item" :class="{ disabled: paginacionHistorial.paginaActual === paginacionHistorial.totalPaginas }">
                  <button class="page-link" @click="cambiarPagina(paginacionHistorial.paginaActual + 1)">
                    <i class="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Estadísticas -->
    <div class="modal fade" id="modalEstadisticas" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-chart-bar me-2"></i>
              Estadísticas del Sistema
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <!-- Estadísticas Generales -->
            <div class="row g-4 mb-4">
              <div class="col-md-3">
                <div class="stat-card bg-primary text-white">
                  <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ estadisticas.total_validaciones || 0 }}</div>
                    <div class="stat-label">Total Validaciones</div>
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <div class="stat-card bg-success text-white">
                  <div class="stat-icon">
                    <i class="fas fa-thumbs-up"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ estadisticas.validaciones_exitosas || 0 }}</div>
                    <div class="stat-label">Exitosas</div>
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <div class="stat-card bg-warning text-white">
                  <div class="stat-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ estadisticas.validaciones_fallidas || 0 }}</div>
                    <div class="stat-label">Con Observaciones</div>
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <div class="stat-card bg-info text-white">
                  <div class="stat-icon">
                    <i class="fas fa-certificate"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ estadisticas.certificados_emitidos || 0 }}</div>
                    <div class="stat-label">Certificados</div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Métricas Adicionales -->
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-muted mb-3">Promedio de Score</h6>
                <div class="progress mb-3" style="height: 25px;">
                  <div class="progress-bar bg-municipal" role="progressbar"
                       :style="{ width: estadisticas.promedio_score + '%' }"
                       :aria-valuenow="estadisticas.promedio_score">
                    {{ estadisticas.promedio_score }}%
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <h6 class="text-muted mb-3">Tipo Más Validado</h6>
                <div class="d-flex align-items-center">
                  <span class="municipal-badge municipal-badge-primary me-2">
                    {{ estadisticas.tipo_mas_validado }}
                  </span>
                  <span class="text-muted">Más frecuente</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Validación Cruzada -->
    <div class="modal fade" id="modalValidacionCruzada" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-check-double me-2"></i>
              Validación Cruzada
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <div v-if="loadingValidacionCruzada" class="text-center py-4">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Validando...</span>
              </div>
              <p class="mt-3">Realizando validación cruzada...</p>
            </div>
            <div v-else-if="resultadoValidacionCruzada" class="validation-result">
              <!-- Score Total -->
              <div class="score-section mb-4">
                <h6 class="text-muted mb-3">Score Total de Confiabilidad</h6>
                <div class="progress mb-2" style="height: 30px;">
                  <div class="progress-bar"
                       :class="getScoreProgressClass(resultadoValidacionCruzada.score_total)"
                       role="progressbar"
                       :style="{ width: resultadoValidacionCruzada.score_total + '%' }"
                       :aria-valuenow="resultadoValidacionCruzada.score_total">
                    {{ resultadoValidacionCruzada.score_total.toFixed(2) }}%
                  </div>
                </div>
                <div class="row text-center">
                  <div class="col-6">
                    <div class="text-success">
                      <i class="fas fa-check-circle fa-2x"></i>
                      <div class="mt-2">{{ resultadoValidacionCruzada.validaciones_exitosas }} Exitosas</div>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="text-warning">
                      <i class="fas fa-exclamation-triangle fa-2x"></i>
                      <div class="mt-2">{{ resultadoValidacionCruzada.validaciones_fallidas }} Con Observaciones</div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Recomendaciones -->
              <div v-if="resultadoValidacionCruzada.recomendaciones && resultadoValidacionCruzada.recomendaciones.length > 0" class="recommendations-section mb-4">
                <h6 class="text-muted mb-3">
                  <i class="fas fa-lightbulb me-2"></i>
                  Recomendaciones
                </h6>
                <ul class="list-group">
                  <li v-for="(recomendacion, index) in resultadoValidacionCruzada.recomendaciones"
                      :key="index"
                      class="list-group-item d-flex align-items-center">
                    <i class="fas fa-arrow-right text-primary me-2"></i>
                    {{ recomendacion }}
                  </li>
                </ul>
              </div>

              <!-- Certificado -->
              <div v-if="resultadoValidacionCruzada.certificado_generado" class="certificate-section">
                <div class="alert alert-success">
                  <div class="d-flex align-items-center">
                    <i class="fas fa-certificate fa-2x text-success me-3"></i>
                    <div>
                      <h6 class="alert-heading mb-1">Certificado Generado</h6>
                      <p class="mb-0">
                        Folio: <strong>{{ resultadoValidacionCruzada.folio_certificado }}</strong>
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            <button v-if="resultadoValidacionCruzada && resultadoValidacionCruzada.certificado_generado"
                    @click="descargarCertificado"
                    class="btn btn-municipal-primary">
              <i class="fas fa-download me-2"></i>
              Descargar Certificado
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'

export default {
  name: 'ValidacionRealData',
  setup() {
    // Estado reactivo
    const loading = ref(false)
    const loadingValidacionCruzada = ref(false)
    const validationMessage = ref('')

    const formBusqueda = reactive({
      tipo: '',
      valor: ''
    })

    const datosValidacion = reactive({
      id_validacion: null,
      rfc: '',
      curp: '',
      nombre_completo: '',
      domicilio_fiscal: '',
      actividad_economica: '',
      estatus_sat: '',
      estatus_renapo: '',
      score_confiabilidad: 0,
      ultima_validacion: null,
      discrepancias_encontradas: 0
    })

    const estadisticas = reactive({
      total_validaciones: 0,
      validaciones_exitosas: 0,
      validaciones_fallidas: 0,
      promedio_score: 0,
      certificados_emitidos: 0,
      tipo_mas_validado: ''
    })

    const historial = ref([])
    const filtrosHistorial = reactive({
      tipo: 'TODOS',
      valor: '',
      fechaInicio: '',
      fechaFin: ''
    })

    const paginacionHistorial = reactive({
      paginaActual: 1,
      registrosPorPagina: 20,
      totalRegistros: 0,
      totalPaginas: 0
    })

    const resultadoValidacionCruzada = ref(null)

    // Computed
    const certificadoDisponible = computed(() => {
      return datosValidacion.score_confiabilidad >= 80
    })

    // Funciones utilitarias
    const formatearFecha = (fecha) => {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleString('es-MX', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const getPlaceholderBusqueda = () => {
      switch (formBusqueda.tipo) {
        case 'RFC': return 'XAXX010101000'
        case 'CURP': return 'XAXX010101HDFXXX00'
        case 'LICENCIA': return '12345'
        default: return 'Ingrese el valor...'
      }
    }

    const getMaxLength = () => {
      switch (formBusqueda.tipo) {
        case 'RFC': return 13
        case 'CURP': return 18
        case 'LICENCIA': return 10
        default: return 50
      }
    }

    const validateInput = () => {
      const valor = formBusqueda.valor.toUpperCase()
      formBusqueda.valor = valor

      switch (formBusqueda.tipo) {
        case 'RFC':
          if (valor.length > 0 && !/^[A-Z0-9]{0,13}$/.test(valor)) {
            validationMessage.value = 'RFC debe contener solo letras y números'
          } else {
            validationMessage.value = ''
          }
          break
        case 'CURP':
          if (valor.length > 0 && !/^[A-Z0-9]{0,18}$/.test(valor)) {
            validationMessage.value = 'CURP debe contener solo letras y números'
          } else {
            validationMessage.value = ''
          }
          break
        default:
          validationMessage.value = ''
      }
    }

    const isFormValid = () => {
      return formBusqueda.tipo && formBusqueda.valor && !validationMessage.value
    }

    const getStatusClass = (score) => {
      if (score >= 90) return 'municipal-badge municipal-badge-success'
      if (score >= 80) return 'municipal-badge municipal-badge-warning'
      return 'municipal-badge municipal-badge-danger'
    }

    const getStatusText = (score) => {
      if (score >= 90) return 'CONFIABLE'
      if (score >= 80) return 'ACEPTABLE'
      return 'REQUIERE REVISIÓN'
    }

    const getValidationBadgeClass = (status) => {
      switch (status) {
        case 'ACTIVO':
        case 'VERIFICADO':
          return 'municipal-badge municipal-badge-success'
        default:
          return 'municipal-badge municipal-badge-secondary'
      }
    }

    const getResultadoBadgeClass = (resultado) => {
      switch (resultado) {
        case 'APROBADO':
          return 'municipal-badge municipal-badge-success'
        case 'CON OBSERVACIONES':
          return 'municipal-badge municipal-badge-warning'
        default:
          return 'municipal-badge municipal-badge-secondary'
      }
    }

    const getScoreProgressClass = (score) => {
      if (score >= 90) return 'bg-success'
      if (score >= 80) return 'bg-warning'
      return 'bg-danger'
    }

    // Funciones API
    const realizarPeticionAPI = async (operacion, parametros) => {
      try {
        const eRequest = {
          Operacion: operacion,
          Base: 'licencias',
          Parametros: parametros.map(param => ({
            nombre: param.nombre,
            valor: param.valor,
            tipo: param.tipo || 'varchar'
          })),
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(eRequest)
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse && data.eResponse.EsExitoso) {
          return data.eResponse.Respuesta
        } else {
          throw new Error(data.eResponse?.MensajeError || 'Error en la respuesta del servidor')
        }
      } catch (error) {
        console.error('Error en petición API:', error)
        throw error
      }
    }

    // Funciones principales
    const buscarContribuyente = async () => {
      if (!isFormValid()) return

      loading.value = true
      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_BUSCAR_CONTRIBUYENTE', [
          { nombre: 'p_tipo_busqueda', valor: formBusqueda.tipo },
          { nombre: 'p_valor_busqueda', valor: formBusqueda.valor },
          { nombre: 'p_usuario', valor: 'admin' }
        ])

        if (resultado && resultado.length > 0) {
          const datos = resultado[0]
          Object.assign(datosValidacion, datos)

          mostrarToast('Contribuyente encontrado exitosamente', 'success')
        } else {
          mostrarToast('No se encontraron datos para el contribuyente', 'warning')
        }
      } catch (error) {
        mostrarToast('Error al buscar contribuyente: ' + error.message, 'error')
      } finally {
        loading.value = false
      }
    }

    const validarRFC = async () => {
      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_RFC_SAT', [
          { nombre: 'p_rfc', valor: datosValidacion.rfc },
          { nombre: 'p_nombre', valor: datosValidacion.nombre_completo },
          { nombre: 'p_usuario', valor: 'admin' }
        ])

        if (resultado && resultado.length > 0) {
          mostrarToast('RFC validado correctamente contra SAT', 'success')
        }
      } catch (error) {
        mostrarToast('Error al validar RFC: ' + error.message, 'error')
      }
    }

    const validarCURP = async () => {
      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_CURP_RENAPO', [
          { nombre: 'p_curp', valor: datosValidacion.curp },
          { nombre: 'p_usuario', valor: 'admin' }
        ])

        if (resultado && resultado.length > 0) {
          mostrarToast('CURP validado correctamente contra RENAPO', 'success')
        }
      } catch (error) {
        mostrarToast('Error al validar CURP: ' + error.message, 'error')
      }
    }

    const validarDomicilio = async () => {
      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_DOMICILIO_INEGI', [
          { nombre: 'p_codigo_postal', valor: '44100' },
          { nombre: 'p_colonia', valor: 'CENTRO' },
          { nombre: 'p_municipio', valor: 'GUADALAJARA' },
          { nombre: 'p_usuario', valor: 'admin' }
        ])

        if (resultado && resultado.length > 0) {
          mostrarToast('Domicilio validado correctamente contra INEGI', 'success')
        }
      } catch (error) {
        mostrarToast('Error al validar domicilio: ' + error.message, 'error')
      }
    }

    const validacionCruzada = async () => {
      if (!datosValidacion.rfc) {
        mostrarToast('Debe buscar un contribuyente primero', 'warning')
        return
      }

      const modal = new bootstrap.Modal(document.getElementById('modalValidacionCruzada'))
      modal.show()

      loadingValidacionCruzada.value = true
      resultadoValidacionCruzada.value = null

      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_CRUZADA', [
          { nombre: 'p_rfc', valor: datosValidacion.rfc },
          { nombre: 'p_curp', valor: datosValidacion.curp },
          { nombre: 'p_nombre', valor: datosValidacion.nombre_completo },
          { nombre: 'p_domicilio', valor: datosValidacion.domicilio_fiscal },
          { nombre: 'p_actividad', valor: datosValidacion.actividad_economica },
          { nombre: 'p_usuario', valor: 'admin' }
        ])

        if (resultado && resultado.length > 0) {
          resultadoValidacionCruzada.value = resultado[0]
          mostrarToast('Validación cruzada completada', 'success')
        }
      } catch (error) {
        mostrarToast('Error en validación cruzada: ' + error.message, 'error')
      } finally {
        loadingValidacionCruzada.value = false
      }
    }

    const generarCertificado = async () => {
      if (!certificadoDisponible.value) {
        mostrarToast('Score insuficiente para generar certificado (mínimo 80%)', 'warning')
        return
      }

      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_GENERAR_CERTIFICADO', [
          { nombre: 'p_id_validacion', valor: datosValidacion.id_validacion, tipo: 'integer' },
          { nombre: 'p_tipo_certificado', valor: 'VALIDACION_COMPLETA' },
          { nombre: 'p_vigencia_dias', valor: 365, tipo: 'integer' },
          { nombre: 'p_usuario', valor: 'admin' }
        ])

        if (resultado && resultado.length > 0) {
          const certificado = resultado[0]
          mostrarToast(`Certificado generado: ${certificado.folio_certificado}`, 'success')
        }
      } catch (error) {
        mostrarToast('Error al generar certificado: ' + error.message, 'error')
      }
    }

    const cargarEstadisticas = async () => {
      try {
        const fechaInicio = new Date()
        fechaInicio.setMonth(fechaInicio.getMonth() - 1)

        const resultado = await realizarPeticionAPI('SP_VALIDACION_ESTADISTICAS', [
          { nombre: 'p_fecha_inicio', valor: fechaInicio.toISOString().split('T')[0], tipo: 'date' },
          { nombre: 'p_fecha_fin', valor: new Date().toISOString().split('T')[0], tipo: 'date' }
        ])

        if (resultado && resultado.length > 0) {
          Object.assign(estadisticas, resultado[0])
        }
      } catch (error) {
        console.error('Error al cargar estadísticas:', error)
      }
    }

    const cargarHistorial = async () => {
      try {
        const resultado = await realizarPeticionAPI('SP_VALIDACION_HISTORIAL', [
          { nombre: 'p_tipo_filtro', valor: filtrosHistorial.tipo },
          { nombre: 'p_valor_filtro', valor: filtrosHistorial.valor || '' },
          { nombre: 'p_fecha_inicio', valor: filtrosHistorial.fechaInicio || '2025-01-01', tipo: 'date' },
          { nombre: 'p_fecha_fin', valor: filtrosHistorial.fechaFin || new Date().toISOString().split('T')[0], tipo: 'date' },
          { nombre: 'p_pagina', valor: paginacionHistorial.paginaActual, tipo: 'integer' },
          { nombre: 'p_registros_por_pagina', valor: paginacionHistorial.registrosPorPagina, tipo: 'integer' }
        ])

        historial.value = resultado || []

        if (resultado && resultado.length > 0) {
          paginacionHistorial.totalRegistros = resultado[0].total_registros
          paginacionHistorial.totalPaginas = Math.ceil(paginacionHistorial.totalRegistros / paginacionHistorial.registrosPorPagina)
        }
      } catch (error) {
        console.error('Error al cargar historial:', error)
      }
    }

    // Funciones de UI
    const mostrarHistorial = () => {
      const modal = new bootstrap.Modal(document.getElementById('modalHistorial'))
      modal.show()
      cargarHistorial()
    }

    const mostrarEstadisticas = () => {
      const modal = new bootstrap.Modal(document.getElementById('modalEstadisticas'))
      modal.show()
    }

    const cambiarPagina = (nuevaPagina) => {
      if (nuevaPagina >= 1 && nuevaPagina <= paginacionHistorial.totalPaginas) {
        paginacionHistorial.paginaActual = nuevaPagina
        cargarHistorial()
      }
    }

    const getPaginasVisibles = () => {
      const total = paginacionHistorial.totalPaginas
      const actual = paginacionHistorial.paginaActual
      const paginas = []

      let inicio = Math.max(1, actual - 2)
      let fin = Math.min(total, actual + 2)

      for (let i = inicio; i <= fin; i++) {
        paginas.push(i)
      }

      return paginas
    }

    const verDetalleHistorial = (item) => {
      // Implementar vista de detalle
      console.log('Ver detalle:', item)
    }

    const exportarDatos = () => {
      const datos = JSON.stringify(datosValidacion, null, 2)
      const blob = new Blob([datos], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `validacion_${datosValidacion.rfc}_${new Date().toISOString().split('T')[0]}.json`
      a.click()
      URL.revokeObjectURL(url)

      mostrarToast('Datos exportados correctamente', 'success')
    }

    const descargarCertificado = () => {
      if (!resultadoValidacionCruzada.value) return

      const contenido = `
CERTIFICADO DE VALIDACIÓN DE DATOS REALES
==========================================

Folio: ${resultadoValidacionCruzada.value.folio_certificado}
RFC: ${datosValidacion.rfc}
CURP: ${datosValidacion.curp}
Nombre: ${datosValidacion.nombre_completo}
Score de Confiabilidad: ${resultadoValidacionCruzada.value.score_total.toFixed(2)}%

Este certificado avala la veracidad de los datos proporcionados
según validación contra fuentes oficiales.

Gobierno Municipal de Guadalajara
Fecha: ${new Date().toLocaleDateString('es-MX')}
      `

      const blob = new Blob([contenido], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `certificado_${resultadoValidacionCruzada.value.folio_certificado}.txt`
      a.click()
      URL.revokeObjectURL(url)

      mostrarToast('Certificado descargado', 'success')
    }

    const mostrarToast = (mensaje, tipo = 'info') => {
      // Implementación de toast usando Bootstrap
      const toastContainer = document.getElementById('toast-container') || createToastContainer()

      const toastEl = document.createElement('div')
      toastEl.className = `toast align-items-center text-bg-${tipo === 'error' ? 'danger' : tipo} border-0`
      toastEl.setAttribute('role', 'alert')

      toastEl.innerHTML = `
        <div class="d-flex">
          <div class="toast-body">${mensaje}</div>
          <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
      `

      toastContainer.appendChild(toastEl)

      const toast = new bootstrap.Toast(toastEl, {
        delay: tipo === 'error' ? 5000 : 3000
      })
      toast.show()

      toastEl.addEventListener('hidden.bs.toast', () => {
        toastEl.remove()
      })
    }

    const createToastContainer = () => {
      const container = document.createElement('div')
      container.id = 'toast-container'
      container.className = 'toast-container position-fixed bottom-0 end-0 p-3'
      container.style.zIndex = '1080'
      document.body.appendChild(container)
      return container
    }

    // Lifecycle
    onMounted(() => {
      cargarEstadisticas()
    })

    return {
      // Estado
      loading,
      loadingValidacionCruzada,
      validationMessage,
      formBusqueda,
      datosValidacion,
      estadisticas,
      historial,
      filtrosHistorial,
      paginacionHistorial,
      resultadoValidacionCruzada,

      // Computed
      certificadoDisponible,

      // Funciones
      formatearFecha,
      getPlaceholderBusqueda,
      getMaxLength,
      validateInput,
      isFormValid,
      getStatusClass,
      getStatusText,
      getValidationBadgeClass,
      getResultadoBadgeClass,
      getScoreProgressClass,
      buscarContribuyente,
      validarRFC,
      validarCURP,
      validarDomicilio,
      validacionCruzada,
      generarCertificado,
      cargarHistorial,
      mostrarHistorial,
      mostrarEstadisticas,
      cambiarPagina,
      getPaginasVisibles,
      verDetalleHistorial,
      exportarDatos,
      descargarCertificado
    }
  }
}
</script>

<style scoped>
.municipal-form-page {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  min-height: 100vh;
}

.municipal-header {
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  color: white;
  padding: 2rem 0;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.municipal-icon {
  width: 60px;
  height: 60px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.8rem;
}

.municipal-title {
  font-size: 1.8rem;
  font-weight: 700;
  margin: 0;
}

.municipal-subtitle {
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;
}

.municipal-stats {
  display: flex;
  gap: 2rem;
}

.stat-item {
  text-align: center;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 700;
  line-height: 1;
}

.stat-label {
  font-size: 0.85rem;
  opacity: 0.8;
}

.municipal-card {
  background: white;
  border: none;
  border-radius: 15px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.municipal-card-header {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-bottom: 2px solid #ea8215;
  padding: 1rem 1.5rem;
}

.municipal-input {
  border: 2px solid #e9ecef;
  border-radius: 8px;
  padding: 0.75rem;
  transition: all 0.3s ease;
}

.municipal-input:focus {
  border-color: #ea8215;
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.municipal-select {
  border: 2px solid #e9ecef;
  border-radius: 8px;
  padding: 0.75rem;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23ea8215' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m1 6 7 7 7-7'/%3e%3c/svg%3e");
}

.btn-municipal-primary {
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  border: none;
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-municipal-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(234, 130, 21, 0.3);
}

.btn-outline-municipal {
  border: 2px solid #ea8215;
  color: #ea8215;
  border-radius: 8px;
  padding: 0.5rem 1rem;
  transition: all 0.3s ease;
}

.btn-outline-municipal:hover {
  background: #ea8215;
  color: white;
  transform: translateY(-2px);
}

.municipal-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-flex;
  align-items: center;
}

.municipal-badge-primary {
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  color: white;
}

.municipal-badge-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
}

.municipal-badge-warning {
  background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
  color: white;
}

.municipal-badge-danger {
  background: linear-gradient(135deg, #dc3545 0%, #e83e8c 100%);
  color: white;
}

.municipal-badge-secondary {
  background: linear-gradient(135deg, #6c757d 0%, #adb5bd 100%);
  color: white;
}

.municipal-badge-score {
  background: linear-gradient(135deg, #17a2b8 0%, #6f42c1 100%);
  color: white;
  font-weight: 700;
}

.validation-status {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.status-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.status-label {
  font-weight: 600;
  color: #6c757d;
}

.municipal-modal-header {
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  color: white;
}

.stat-card {
  padding: 1.5rem;
  border-radius: 15px;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  font-size: 2rem;
  opacity: 0.8;
}

.stat-info .stat-number {
  font-size: 2rem;
  font-weight: 700;
  line-height: 1;
}

.stat-info .stat-label {
  font-size: 0.9rem;
  opacity: 0.9;
}

.validation-result .score-section {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 10px;
}

.recommendations-section .list-group-item {
  border: none;
  background: #f8f9fa;
  margin-bottom: 0.5rem;
  border-radius: 8px;
}

.certificate-section {
  background: #d4edda;
  border-radius: 10px;
  padding: 0;
}

.page-link {
  border-radius: 8px;
  margin: 0 2px;
  border: none;
  color: #ea8215;
}

.page-link:hover {
  background: #ea8215;
  color: white;
}

.page-item.active .page-link {
  background: #ea8215;
  border-color: #ea8215;
}

@media (max-width: 768px) {
  .municipal-header {
    padding: 1rem 0;
  }

  .municipal-title {
    font-size: 1.4rem;
  }

  .municipal-stats {
    flex-direction: column;
    gap: 1rem;
  }

  .validation-status {
    gap: 0.5rem;
  }

  .status-item {
    flex-direction: column;
    text-align: center;
    gap: 0.25rem;
  }
}
</style>