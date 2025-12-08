<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Estado de Cuenta</h1>
        <p>Aseo Contratado - Estado de cuenta detallado por contrato</p>
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
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Contrato</label>
              <input
                type="number"
                v-model="numContrato"
                class="municipal-form-control"
                placeholder="Ingrese número de contrato"
                @keyup.enter="buscarContrato"
                required
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Corte (opcional)</label>
              <input type="date" v-model="fechaCorte" class="municipal-form-control" />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarContrato" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar Contrato
            </button>
            <button class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-primary" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" /> Exportar PDF
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-secondary" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && contratoInfo" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-contract" /> Datos del Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Contrato:</strong>
              <span>{{ contratoInfo.num_contrato }}</span>
            </div>
            <div class="info-item">
              <strong>Empresa:</strong>
              <span>{{ contratoInfo.empresa }}</span>
            </div>
            <div class="info-item">
              <strong>RFC:</strong>
              <span>{{ contratoInfo.rfc_empresa || 'N/A' }}</span>
            </div>
            <div class="info-item">
              <strong>Tipo de Aseo:</strong>
              <span>{{ formatTipoAseo(contratoInfo.tipo_aseo) }}</span>
            </div>
            <div class="info-item">
              <strong>Dirección:</strong>
              <span>{{ formatDireccion(contratoInfo) }}</span>
            </div>
            <div class="info-item">
              <strong>Periodo Vigente:</strong>
              <span>{{ formatPeriodo(contratoInfo.inicio_oblig) }} - {{ formatPeriodo(contratoInfo.fin_oblig) }}</span>
            </div>
            <div class="info-item">
              <strong>Unidades:</strong>
              <span>{{ contratoInfo.cantidad_recoleccion }}</span>
            </div>
            <div class="info-item">
              <strong>Status:</strong>
              <span :class="contratoInfo.status_contrato === 'N' ? 'badge-success' : 'badge-danger'">
                {{ contratoInfo.status_contrato === 'N' ? 'ACTIVO' : 'INACTIVO' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-pie" /> Resumen del Estado de Cuenta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-warning"><font-awesome-icon icon="exclamation-triangle" /></div>
              <div class="summary-info">
                <p class="summary-label">Periodos Adeudados</p>
                <p class="summary-value">{{ adeudos.length }}</p>
              </div>
            </div>
            <div class="summary-card highlight-danger">
              <div class="summary-icon bg-danger"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Adeudado</p>
                <p class="summary-value">{{ formatCurrency(totales.total_adeudo) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-success"><font-awesome-icon icon="check-circle" /></div>
              <div class="summary-info">
                <p class="summary-label">Pagos Realizados</p>
                <p class="summary-value">{{ pagos.length }}</p>
              </div>
            </div>
            <div class="summary-card highlight-success">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="money-bill-wave" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Pagado</p>
                <p class="summary-value">{{ formatCurrency(totales.total_pagado) }}</p>
              </div>
            </div>
          </div>

          <div class="total-balance mt-3" :class="totales.saldo >= 0 ? 'saldo-positivo' : 'saldo-negativo'">
            <div class="balance-label">SALDO {{ totales.saldo >= 0 ? 'A FAVOR' : 'ADEUDADO' }}:</div>
            <div class="balance-amount">{{ formatCurrency(Math.abs(totales.saldo)) }}</div>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && adeudos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="exclamation-circle" /> Detalle de Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Periodo</th>
                  <th>Antigüedad</th>
                  <th class="text-right">Cuota Base</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudos" :key="adeudo.periodo">
                  <td><strong>{{ formatPeriodo(adeudo.periodo) }}</strong></td>
                  <td>
                    <span class="badge" :class="getAntiguedadClass(adeudo.periodo)">
                      {{ calcularAntiguedad(adeudo.periodo) }}
                    </span>
                  </td>
                  <td class="text-right">{{ formatCurrency(adeudo.cuota_base) }}</td>
                  <td class="text-right text-danger">{{ formatCurrency(adeudo.recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="2"><strong>TOTAL ADEUDOS:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.suma_cuotas) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.suma_recargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.suma_gastos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.total_adeudo) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && pagos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="money-check-alt" /> Historial de Pagos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Fecha Pago</th>
                  <th>Periodo(s) Cubierto(s)</th>
                  <th>Recaudadora</th>
                  <th class="text-right">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.folio">
                  <td><strong>{{ pago.folio }}</strong></td>
                  <td>{{ formatDate(pago.fecha) }}</td>
                  <td>{{ pago.periodos_cubiertos || 'N/A' }}</td>
                  <td>{{ pago.recaudadora }}</td>
                  <td class="text-right text-success"><strong>{{ formatCurrency(pago.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="4"><strong>TOTAL PAGADO:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.total_pagado) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && adeudos.length === 0 && pagos.length === 0" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No hay movimientos registrados para este contrato</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Estado de Cuenta">
      <h3>Estado de Cuenta por Contrato</h3>
      <p>Genera un estado de cuenta detallado para un contrato específico, mostrando todos sus adeudos pendientes y pagos realizados.</p>

      <h4>Información que muestra:</h4>
      <ul>
        <li><strong>Datos del contrato:</strong> Número, empresa, dirección, vigencia, tipo de aseo</li>
        <li><strong>Adeudos pendientes:</strong> Desglose por periodo con cuota base, recargos y gastos</li>
        <li><strong>Historial de pagos:</strong> Todos los pagos realizados con fecha y folio</li>
        <li><strong>Saldo actual:</strong> Diferencia entre total adeudado y total pagado</li>
      </ul>

      <h4>Fecha de corte:</h4>
      <p>Opcionalmente puede especificar una fecha de corte para ver el estado de cuenta histórico a esa fecha. Si no se especifica, se muestra el estado actual.</p>

      <h4>Exportación:</h4>
      <p>Puede exportar el estado de cuenta a PDF o imprimirlo directamente.</p>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rpt_EstadoCuenta'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const showDocumentation = ref(false)
const reporteGenerado = ref(false)
const numContrato = ref(null)
const fechaCorte = ref('')
const contratoInfo = ref(null)
const adeudos = ref([])
const pagos = ref([])

const totales = computed(() => {
  const suma_cuotas = adeudos.value.reduce((sum, a) => sum + parseFloat(a.cuota_base || 0), 0)
  const suma_recargos = adeudos.value.reduce((sum, a) => sum + parseFloat(a.recargos || 0), 0)
  const suma_gastos = adeudos.value.reduce((sum, a) => sum + parseFloat(a.gastos_cobranza || 0), 0)
  const total_adeudo = adeudos.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
  const total_pagado = pagos.value.reduce((sum, p) => sum + parseFloat(p.importe || 0), 0)

const { showLoading, hideLoading } = useGlobalLoading()
  const saldo = total_pagado - total_adeudo

  return {
    suma_cuotas,
    suma_recargos,
    suma_gastos,
    total_adeudo,
    total_pagado,
    saldo
  }
})

const buscarContrato = async () => {
  if (!numContrato.value) {
    showToast('Ingrese el número de contrato', 'warning')
    return
  }

  showLoading()
  try {
    // 1. Buscar información del contrato
    const responseContrato = await execute('sp16_contratos_buscar', 'aseo_contratado', {
      parContrato: numContrato.value,
      parTipo: 'T',
      parVigencia: 'T'
    })

    if (!responseContrato || !responseContrato || responseContrato.length === 0) {
      showToast('Contrato no encontrado', 'warning')
      return
    }

    contratoInfo.value = responseContrato[0]

    // 2. Obtener adeudos del contrato
    const responseAdeudos = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
      p_control_contrato: contratoInfo.value.control_contrato,
      p_status_vigencia: 'D', // Solo adeudos pendientes
      p_fecha_hasta: fechaCorte.value || null
    })

    adeudos.value = responseAdeudos || []

    // 3. Obtener pagos del contrato (SP a implementar)
    try {
      const responsePagos = await execute('SP_ASEO_PAGOS_BY_CONTRATO', 'aseo_contratado', {
        p_control_contrato: contratoInfo.value.control_contrato,
        p_fecha_hasta: fechaCorte.value || null
      })
      pagos.value = responsePagos || []
    } catch (error) {
      hideLoading()
      // SP no existe aún, simular datos vacíos
      pagos.value = []
    }

    reporteGenerado.value = true
    showToast('Estado de cuenta generado correctamente', 'success')
  } catch (error) {
    hideLoading()
    showToast('Error al generar estado de cuenta', 'error')
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  numContrato.value = null
  fechaCorte.value = ''
  contratoInfo.value = null
  adeudos.value = []
  pagos.value = []
  reporteGenerado.value = false
}

const exportarPDF = () => {
  showToast('Exportación a PDF en desarrollo', 'info')
}

const imprimir = () => {
  showToast('Impresión en desarrollo', 'info')
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-')
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return `${meses[parseInt(month) - 1]} ${year}`
}

const formatTipoAseo = (tipo) => {
  const tipos = {
    'C': 'COMERCIAL',
    'R': 'RESIDENCIAL',
    'I': 'INDUSTRIAL',
    'M': 'MIXTO'
  }
  return tipos[tipo] || tipo
}

const formatDireccion = (contrato) => {
  if (!contrato) return 'N/A'
  return `${contrato.calle || ''} ${contrato.numext || ''}, ${contrato.colonia || ''}, ${contrato.municipio || ''}, ${contrato.estado || ''}`.trim()
}

const calcularAntiguedad = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-').map(Number)
  const fechaPeriodo = new Date(year, month - 1)
  const fechaActual = new Date()
  const mesesDiferencia = (fechaActual.getFullYear() - fechaPeriodo.getFullYear()) * 12 +
                          (fechaActual.getMonth() - fechaPeriodo.getMonth())

  if (mesesDiferencia === 0) return 'Actual'
  if (mesesDiferencia === 1) return '1 mes'
  return `${mesesDiferencia} meses`
}

const getAntiguedadClass = (periodo) => {
  if (!periodo) return 'badge-secondary'
  const [year, month] = periodo.split('-').map(Number)
  const fechaPeriodo = new Date(year, month - 1)
  const fechaActual = new Date()
  const mesesDiferencia = (fechaActual.getFullYear() - fechaPeriodo.getFullYear()) * 12 +
                          (fechaActual.getMonth() - fechaPeriodo.getMonth())

  if (mesesDiferencia === 0) return 'badge-success'
  if (mesesDiferencia <= 3) return 'badge-warning'
  if (mesesDiferencia <= 6) return 'badge-orange'
  return 'badge-danger'
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

