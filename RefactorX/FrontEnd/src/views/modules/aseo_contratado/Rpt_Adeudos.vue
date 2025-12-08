<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos</h1>
        <p>Aseo Contratado - Reporte detallado de adeudos pendientes</p>
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
      <!-- Filtros del Reporte -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros del Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control">
                <option value="">Todos</option>
                <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo" :value="tipo.tipo_aseo">
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Empresa</label>
              <select v-model="filtros.num_empresa" class="municipal-form-control">
                <option value="">Todas</option>
                <option v-for="empresa in empresas" :key="empresa.num_emp" :value="empresa.num_emp">
                  {{ empresa.nom_emp }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status de Contrato</label>
              <select v-model="filtros.status_contrato" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="V">Vigente</option>
                <option value="N">Nuevo</option>
                <option value="B">Baja</option>
              </select>
            </div>
          </div>

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
              <label class="municipal-form-label">Monto Mínimo</label>
              <div class="input-group">
                <span class="input-group-text">$</span>
                <input type="number" v-model="filtros.monto_minimo" class="municipal-form-control"
                  placeholder="0.00" step="0.01" min="0" />
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ordenar Por</label>
              <select v-model="filtros.orden" class="municipal-form-control">
                <option value="empresa">Empresa</option>
                <option value="contrato">Número de Contrato</option>
                <option value="monto">Monto de Adeudo</option>
                <option value="antiguedad">Antigüedad</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Dirección</label>
              <select v-model="filtros.direccion" class="municipal-form-control">
                <option value="ASC">Ascendente</option>
                <option value="DESC">Descendente</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="generarReporte" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'file-chart-column'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar Filtros
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-primary" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Exportar Excel
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-info" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" /> Exportar PDF
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-info" @click="imprimirReporte">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
      </div>

      <!-- Resumen del Reporte -->
      <div v-if="reporteGenerado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-bar" /> Resumen de Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-primary">
                <font-awesome-icon icon="file-contract" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Contratos con Adeudos</p>
                <p class="summary-value">{{ totales.contratos }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-warning">
                <font-awesome-icon icon="file-invoice" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Total de Adeudos</p>
                <p class="summary-value">{{ totales.registros }}</p>
              </div>
            </div>
            <div class="summary-card highlight">
              <div class="summary-icon bg-danger">
                <font-awesome-icon icon="dollar-sign" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Monto Total</p>
                <p class="summary-value">{{ formatCurrency(totales.monto_total) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-secondary">
                <font-awesome-icon icon="percent" />
              </div>
              <div class="summary-info">
                <p class="summary-label">Recargos</p>
                <p class="summary-value">{{ formatCurrency(totales.recargos) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div v-if="reporteGenerado && datos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Detalle de Adeudos ({{ datos.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table" id="tabla-reporte">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Periodo</th>
                  <th>Concepto</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-right">Recargo</th>
                  <th class="text-right">Multa</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Total</th>
                  <th>Antigüedad</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, idx) in datos" :key="idx" class="row-hover">
                  <td><strong>{{ item.num_contrato }}</strong></td>
                  <td>{{ item.nombre_empresa }}</td>
                  <td>{{ item.periodo }}</td>
                  <td>{{ item.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(item.importe_adeudo) }}</td>
                  <td class="text-right">{{ formatCurrency(item.importe_recargo) }}</td>
                  <td class="text-right">{{ formatCurrency(item.importe_multa) }}</td>
                  <td class="text-right">{{ formatCurrency(item.importe_gastos) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(item.total_periodo) }}</strong></td>
                  <td>{{ calcularAntiguedad(item.periodo) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="4" class="text-right"><strong>TOTALES:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.adeudo) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.recargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.multas) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.gastos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.monto_total) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="reporteGenerado && datos.length === 0" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontraron adeudos con los criterios seleccionados</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Reporte de Adeudos">
      <h3>Reporte de Adeudos</h3>
      <p>Este módulo genera reportes detallados de adeudos pendientes con múltiples filtros y opciones de exportación.</p>

      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Tipo de Aseo:</strong> Filtrar por categoría de servicio</li>
        <li><strong>Empresa:</strong> Filtrar por empresa específica</li>
        <li><strong>Status de Contrato:</strong> Vigente, Nuevo o Baja</li>
        <li><strong>Periodo:</strong> Rango de fechas (desde/hasta)</li>
        <li><strong>Monto Mínimo:</strong> Excluir adeudos menores al monto especificado</li>
        <li><strong>Ordenamiento:</strong> Por empresa, contrato, monto o antigüedad</li>
      </ul>

      <h4>Información del Reporte:</h4>
      <ul>
        <li>Resumen con totales por concepto</li>
        <li>Detalle completo de cada adeudo</li>
        <li>Cálculo automático de antigüedad</li>
        <li>Desglose por recargos, multas y gastos</li>
      </ul>

      <h4>Opciones de Exportación:</h4>
      <ul>
        <li><strong>Excel:</strong> Exporta a formato Excel para análisis</li>
        <li><strong>PDF:</strong> Genera documento PDF para impresión</li>
        <li><strong>Imprimir:</strong> Impresión directa desde el navegador</li>
      </ul>

      <h4>Notas:</h4>
      <ul>
        <li>Los totales se calculan en tiempo real</li>
        <li>La antigüedad se calcula en meses desde el periodo del adeudo</li>
        <li>Los filtros se pueden combinar para reportes específicos</li>
        <li>El reporte refleja el estado actual de adeudos</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rpt_Adeudos'"
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
const datos = ref([])
const tiposAseo = ref([])
const empresas = ref([])

const filtros = ref({
  tipo_aseo: '',
  num_empresa: '',
  status_contrato: '',
  periodo_desde: '',
  periodo_hasta: '',
  monto_minimo: 0,
  orden: 'empresa',
  direccion: 'ASC'
})

const totales = computed(() => {
  if (datos.value.length === 0) {
    return {
      contratos: 0,
      registros: 0,
      monto_total: 0,
      adeudo: 0,
      recargos: 0,
      multas: 0,
      gastos: 0
    }
  }

  const contratosUnicos = new Set(datos.value.map(d => d.num_contrato))

  return {
    contratos: contratosUnicos.size,
    registros: datos.value.length,
    monto_total: datos.value.reduce((sum, d) => sum + parseFloat(d.total_periodo || 0), 0),
    adeudo: datos.value.reduce((sum, d) => sum + parseFloat(d.importe_adeudo || 0), 0),
    recargos: datos.value.reduce((sum, d) => sum + parseFloat(d.importe_recargo || 0), 0),
    multas: datos.value.reduce((sum, d) => sum + parseFloat(d.importe_multa || 0), 0),
    gastos: datos.value.reduce((sum, d) => sum + parseFloat(d.importe_gastos || 0), 0)

const { showLoading, hideLoading } = useGlobalLoading()
  }
})

const generarReporte = async () => {
  showLoading()
  reporteGenerado.value = false

  try {
    // Primero obtener contratos según filtros
    const responseContratos = await execute('sp16_contratos', 'aseo_contratado', {
      parTipo: filtros.value.tipo_aseo || 'T',
      parVigencia: filtros.value.status_contrato || 'T'
    })

    if (!responseContratos || !responseContratos) {
      datos.value = []
      reporteGenerado.value = true
      return
    }

    let contratos = responseContratos.data

    // Filtrar por empresa si se especificó
    if (filtros.value.num_empresa) {
      contratos = contratos.filter(c => c.num_empresa == filtros.value.num_empresa)
    }

    // Obtener adeudos de cada contrato
    const adeudosPromises = contratos.map(async (contrato) => {
      try {
        const response = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
          p_control_contrato: contrato.control_contrato,
          p_status_vigencia: 'D',
          p_fecha_hasta: null
        })

        if (response) {
          return response.map(a => ({
            ...a,
            num_contrato: contrato.num_contrato,
            nombre_empresa: contrato.nombre_empresa
          }))
        }
        return []
      } catch (error) {
        hideLoading()
        handleApiError(error)
        return []
      }
    })

    const adeudosArrays = await Promise.all(adeudosPromises)
    let todosAdeudos = adeudosArrays.flat()

    // Aplicar filtros adicionales
    if (filtros.value.periodo_desde) {
      todosAdeudos = todosAdeudos.filter(a => a.periodo >= filtros.value.periodo_desde)
    }
    if (filtros.value.periodo_hasta) {
      todosAdeudos = todosAdeudos.filter(a => a.periodo <= filtros.value.periodo_hasta)
    }
    if (filtros.value.monto_minimo > 0) {
      todosAdeudos = todosAdeudos.filter(a => parseFloat(a.total_periodo) >= filtros.value.monto_minimo)
    }

    // Ordenar
    todosAdeudos.sort((a, b) => {
      let valA, valB

      switch (filtros.value.orden) {
        case 'empresa':
          valA = a.nombre_empresa
          valB = b.nombre_empresa
          break
        case 'contrato':
          valA = a.num_contrato
          valB = b.num_contrato
          break
        case 'monto':
          valA = parseFloat(a.total_periodo)
          valB = parseFloat(b.total_periodo)
          break
        case 'antiguedad':
          valA = a.periodo
          valB = b.periodo
          break
        default:
          valA = a.nombre_empresa
          valB = b.nombre_empresa
      }

      if (filtros.value.direccion === 'ASC') {
        return valA > valB ? 1 : -1
      } else {
        return valA < valB ? 1 : -1
      }
    })

    datos.value = todosAdeudos
    reporteGenerado.value = true

    if (datos.value.length > 0) {
      showToast(`Reporte generado: ${datos.value.length} adeudos encontrados`, 'success')
    } else {
      showToast('No se encontraron adeudos', 'info')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al generar el reporte', 'error')
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    tipo_aseo: '',
    num_empresa: '',
    status_contrato: '',
    periodo_desde: '',
    periodo_hasta: '',
    monto_minimo: 0,
    orden: 'empresa',
    direccion: 'ASC'
  }
  datos.value = []
  reporteGenerado.value = false
}

const exportarExcel = () => {
  showToast('Exportación a Excel en desarrollo', 'info')
}

const exportarPDF = () => {
  showToast('Exportación a PDF en desarrollo', 'info')
}

const imprimirReporte = () => {
  window.print()
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

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const cargarTiposAseo = async () => {
  try {
    const response = await execute('SP_ASEO_TIPOS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response) {
      tiposAseo.value = response
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const cargarEmpresas = async () => {
  try {
    const response = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 1000,
      p_search: null
    })

    if (response) {
      empresas.value = response
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  cargarTiposAseo()
  cargarEmpresas()
})
</script>

