<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Estado de Cuenta Detallado</h1>
        <p>Aseo Contratado - Consulta detallada de adeudos y movimientos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Contrato</label>
              <div class="input-group">
                <input type="number" v-model="numContrato" class="municipal-form-control"
                  placeholder="Ingrese número de contrato" @keyup.enter="buscarContrato" />
                <button class="btn-municipal-secondary" @click="buscarContrato" :disabled="loading" type="button">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                </button>
              </div>
            </div>
          </div>

          <div v-if="contratoInfo" class="alert alert-success mt-3">
            <div class="detail-grid">
              <div class="detail-item">
                <label class="detail-label">Empresa</label>
                <p class="detail-value">{{ contratoInfo.nom_emp }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Representante</label>
                <p class="detail-value">{{ contratoInfo.representante }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Tipo Aseo</label>
                <p class="detail-value">{{ contratoInfo.desc_aseo }}</p>
              </div>
              <div class="detail-item">
                <label class="detail-label">Status</label>
                <p class="detail-value">
                  <span :class="['badge', contratoInfo.status_vigencia === 'V' ? 'badge-success' : 'badge-info']">
                    {{ getStatusLabel(contratoInfo.status_vigencia) }}
                  </span>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div v-if="contratoInfo" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Periodo Desde</label>
              <input type="month" v-model="filtros.periodo_desde" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo Hasta</label>
              <input type="month" v-model="filtros.periodo_hasta" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Movimiento</label>
              <select v-model="filtros.tipo_movimiento" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="C">Cuota Normal</option>
                <option value="R">Recargo</option>
                <option value="M">Multa</option>
                <option value="G">Gastos</option>
                <option value="A">Actualización</option>
                <option value="P">Pago</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="consultarEstadoCuenta" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Consultar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar Filtros
            </button>
            <button v-if="estadoCuenta.length > 0" class="btn-municipal-info" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" /> Exportar PDF
            </button>
            <button v-if="estadoCuenta.length > 0" class="btn-municipal-primary" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Exportar Excel
            </button>
          </div>
        </div>
      </div>

      <!-- Resumen General -->
      <div v-if="estadoCuenta.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-pie" /> Resumen de Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-warning">
                <font-awesome-icon icon="exclamation-triangle" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Adeudo</p>
                <p class="summary-value">{{ formatCurrency(totales.adeudo) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-danger">
                <font-awesome-icon icon="percent" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Recargos</p>
                <p class="summary-value">{{ formatCurrency(totales.recargo) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-primary">
                <font-awesome-icon icon="gavel" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Multas</p>
                <p class="summary-value">{{ formatCurrency(totales.multa) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-secondary">
                <font-awesome-icon icon="file-invoice" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Gastos</p>
                <p class="summary-value">{{ formatCurrency(totales.gastos) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-info">
                <font-awesome-icon icon="chart-line" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Actualización</p>
                <p class="summary-value">{{ formatCurrency(totales.actualizacion) }}</p>
              </div>
            </div>
            <div class="summary-card highlight">
              <div class="summary-icon bg-success">
                <font-awesome-icon icon="dollar-sign" />
              </div>
              <div class="summary-info">
                <p class="summary-label">TOTAL</p>
                <p class="summary-value">{{ formatCurrency(totales.total) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Detalle del Estado de Cuenta -->
      <div v-if="estadoCuenta.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Detalle de Movimientos ({{ estadoCuenta.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Periodo</th>
                  <th>Concepto</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-right">Recargo</th>
                  <th class="text-right">Multa</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Actualización</th>
                  <th class="text-right">Total</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(edo, idx) in estadoCuenta" :key="idx" class="row-hover">
                  <td><strong>{{ edo.periodo }}</strong></td>
                  <td>{{ edo.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(edo.importe_adeudo) }}</td>
                  <td class="text-right">{{ formatCurrency(edo.importe_recargo) }}</td>
                  <td class="text-right">{{ formatCurrency(edo.importe_multa) }}</td>
                  <td class="text-right">{{ formatCurrency(edo.importe_gastos) }}</td>
                  <td class="text-right">{{ formatCurrency(edo.importe_actualizacion) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(edo.total_periodo) }}</strong></td>
                  <td>
                    <button class="btn-municipal-info btn-sm" @click="verDetalle(edo)" title="Ver Detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="2" class="text-right"><strong>TOTALES:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.adeudo) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.recargo) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.multa) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.gastos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.actualizacion) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.total) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div v-if="consultaRealizada && estadoCuenta.length === 0" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontraron movimientos para los criterios seleccionados</p>
        </div>
      </div>
    </div>

    <!-- Modal de Detalle -->
    <div v-if="showDetalleModal" class="modal-overlay" @click="showDetalleModal = false">
      <div class="modal-container" @click.stop>
        <div class="modal-header">
          <h5><font-awesome-icon icon="info-circle" /> Detalle del Periodo</h5>
          <button class="modal-close" @click="showDetalleModal = false">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div v-if="detalleSeleccionado" class="detail-grid">
            <div class="detail-item">
              <label class="detail-label">Periodo</label>
              <p class="detail-value">{{ detalleSeleccionado.periodo }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Concepto</label>
              <p class="detail-value">{{ detalleSeleccionado.concepto }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Fecha de Registro</label>
              <p class="detail-value">{{ detalleSeleccionado.fecha_registro || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Importe Adeudo</label>
              <p class="detail-value">{{ formatCurrency(detalleSeleccionado.importe_adeudo) }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Importe Recargo</label>
              <p class="detail-value">{{ formatCurrency(detalleSeleccionado.importe_recargo) }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Importe Multa</label>
              <p class="detail-value">{{ formatCurrency(detalleSeleccionado.importe_multa) }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Gastos de Ejecución</label>
              <p class="detail-value">{{ formatCurrency(detalleSeleccionado.importe_gastos) }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Actualización</label>
              <p class="detail-value">{{ formatCurrency(detalleSeleccionado.importe_actualizacion) }}</p>
            </div>
            <div class="detail-item full-width">
              <label class="detail-label">Total del Periodo</label>
              <p class="detail-value"><strong>{{ formatCurrency(detalleSeleccionado.total_periodo) }}</strong></p>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="showDetalleModal = false">
            <font-awesome-icon icon="times" /> Cerrar
          </button>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Estado de Cuenta">
      <h3>Estado de Cuenta Detallado</h3>
      <p>Este módulo permite consultar el estado de cuenta completo de un contrato con todos sus movimientos y adeudos.</p>

      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Búsqueda:</strong> Ingrese el número de contrato para consultar</li>
        <li><strong>Filtros:</strong> Filtre por periodo (desde/hasta) y tipo de movimiento</li>
        <li><strong>Resumen:</strong> Visualice totales por concepto en tarjetas</li>
        <li><strong>Detalle:</strong> Tabla completa con todos los movimientos</li>
        <li><strong>Exportación:</strong> Genere PDF o Excel del estado de cuenta</li>
      </ul>

      <h4>Tipos de Movimiento:</h4>
      <ul>
        <li><strong>Cuota Normal (C):</strong> Adeudo por servicio regular mensual</li>
        <li><strong>Recargo (R):</strong> Recargo moratorio por pago tardío</li>
        <li><strong>Multa (M):</strong> Multa por infracción administrativa</li>
        <li><strong>Gastos (G):</strong> Gastos de ejecución y administrativos</li>
        <li><strong>Actualización (A):</strong> Actualización por inflación</li>
        <li><strong>Pago (P):</strong> Pagos realizados (abonos)</li>
      </ul>

      <h4>Notas:</h4>
      <ul>
        <li>Los totales se calculan automáticamente</li>
        <li>Puede consultar periodos históricos o actuales</li>
        <li>El estado de cuenta se actualiza en tiempo real</li>
        <li>Use los filtros para consultas específicas</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Adeudos_EdoCta'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const showDocumentation = ref(false)
const numContrato = ref(null)
const contratoInfo = ref(null)
const estadoCuenta = ref([])
const consultaRealizada = ref(false)
const showDetalleModal = ref(false)
const detalleSeleccionado = ref(null)

const filtros = ref({
  periodo_desde: '',
  periodo_hasta: '',
  tipo_movimiento: ''
})

const totales = computed(() => {
  return estadoCuenta.value.reduce((acc, edo) => {
    return {
      adeudo: acc.adeudo + parseFloat(edo.importe_adeudo || 0),
      recargo: acc.recargo + parseFloat(edo.importe_recargo || 0),
      multa: acc.multa + parseFloat(edo.importe_multa || 0),
      gastos: acc.gastos + parseFloat(edo.importe_gastos || 0),
      actualizacion: acc.actualizacion + parseFloat(edo.importe_actualizacion || 0),

const { showLoading, hideLoading } = useGlobalLoading()
      total: acc.total + parseFloat(edo.total_periodo || 0)
    }
  }, { adeudo: 0, recargo: 0, multa: 0, gastos: 0, actualizacion: 0, total: 0 })
})

const buscarContrato = async () => {
  if (!numContrato.value) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  showLoading()
  try {
    const response = await execute('SP_ASEO_ADEUDOS_BUSCAR_CONTRATO', 'aseo_contratado', {
      p_num_contrato: numContrato.value,
      p_num_empresa: null,
      p_nombre_empresa: null
    })

    if (response && response.length > 0) {
      contratoInfo.value = response[0]
      // Consultar automáticamente el estado de cuenta
      await consultarEstadoCuenta()
    } else {
      showToast('Contrato no encontrado', 'warning')
      contratoInfo.value = null
      estadoCuenta.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al buscar contrato', 'error')
    contratoInfo.value = null
  } finally {
    hideLoading()
  }
}

const consultarEstadoCuenta = async () => {
  if (!contratoInfo.value) return

  showLoading()
  consultaRealizada.value = true
  try {
    // Preparar fecha hasta si se especificó periodo_hasta
    let fechaHasta = null
    if (filtros.value.periodo_hasta) {
      const [year, month] = filtros.value.periodo_hasta.split('-')
      fechaHasta = `${year}-${month}-01`
    }

    const response = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
      p_control_contrato: contratoInfo.value.control_contrato,
      p_status_vigencia: 'D', // Todos los movimientos
      p_fecha_hasta: fechaHasta
    })

    if (response) {
      let datos = response

      // Aplicar filtros locales
      if (filtros.value.periodo_desde) {
        datos = datos.filter(edo => edo.periodo >= filtros.value.periodo_desde)
      }
      if (filtros.value.periodo_hasta) {
        datos = datos.filter(edo => edo.periodo <= filtros.value.periodo_hasta)
      }
      if (filtros.value.tipo_movimiento) {
        datos = datos.filter(edo => edo.cve_operacion === filtros.value.tipo_movimiento)
      }

      estadoCuenta.value = datos

      if (estadoCuenta.value.length === 0) {
        showToast('No se encontraron movimientos', 'info')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al consultar estado de cuenta', 'error')
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    periodo_desde: '',
    periodo_hasta: '',
    tipo_movimiento: ''
  }
  if (contratoInfo.value) {
    consultarEstadoCuenta()
  }
}

const verDetalle = (edo) => {
  detalleSeleccionado.value = edo
  showDetalleModal.value = true
}

const exportarPDF = () => {
  showToast('Funcionalidad de exportación a PDF en desarrollo', 'info')
}

const exportarExcel = () => {
  showToast('Funcionalidad de exportación a Excel en desarrollo', 'info')
}

const getStatusLabel = (status) => {
  const labels = { V: 'Vigente', N: 'Nuevo', B: 'Baja', C: 'Cancelado' }
  return labels[status] || status
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

