<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Contratos</h1>
        <p>Aseo Contratado - Reporte general de contratos registrados</p>
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
          <h5><font-awesome-icon icon="filter" /> Filtros del Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="C">Comercial</option>
                <option value="R">Residencial</option>
                <option value="I">Industrial</option>
                <option value="M">Mixto</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status</label>
              <select v-model="filtros.status_contrato" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="N">Activos</option>
                <option value="B">Inactivos</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Empresa</label>
              <select v-model="filtros.num_empresa" class="municipal-form-control">
                <option value="">Todas</option>
                <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                  {{ emp.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Periodo Inicio Desde</label>
              <input type="month" v-model="filtros.inicio_desde" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo Inicio Hasta</label>
              <input type="month" v-model="filtros.inicio_hasta" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ordenar Por</label>
              <select v-model="filtros.orden" class="municipal-form-control">
                <option value="num_contrato">Número de Contrato</option>
                <option value="empresa">Empresa</option>
                <option value="fecha_alta">Fecha de Alta</option>
                <option value="inicio_oblig">Fecha de Inicio</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="generarReporte" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'file-chart-column'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-primary" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-secondary" @click="exportarPDF">
              <font-awesome-icon icon="file-pdf" /> PDF
            </button>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-bar" /> Resumen</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="file-contract" /></div>
              <div class="summary-info">
                <p class="summary-label">Total de Contratos</p>
                <p class="summary-value">{{ datos.length }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-success"><font-awesome-icon icon="check-circle" /></div>
              <div class="summary-info">
                <p class="summary-label">Contratos Activos</p>
                <p class="summary-value">{{ totales.activos }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-danger"><font-awesome-icon icon="times-circle" /></div>
              <div class="summary-info">
                <p class="summary-label">Contratos Inactivos</p>
                <p class="summary-value">{{ totales.inactivos }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-info"><font-awesome-icon icon="building" /></div>
              <div class="summary-info">
                <p class="summary-label">Empresas Diferentes</p>
                <p class="summary-value">{{ totales.empresas }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-warning"><font-awesome-icon icon="dumpster" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Unidades</p>
                <p class="summary-value">{{ totales.unidades }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && datos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Detalle de Contratos ({{ datos.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Tipo Aseo</th>
                  <th>Dirección</th>
                  <th>Inicio Oblig.</th>
                  <th>Fin Oblig.</th>
                  <th class="text-center">Unidades</th>
                  <th class="text-center">Status</th>
                  <th>Fecha Alta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in datos" :key="contrato.num_contrato">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.empresa }}</td>
                  <td>
                    <span class="badge" :class="getTipoAseoClass(contrato.tipo_aseo)">
                      {{ formatTipoAseo(contrato.tipo_aseo) }}
                    </span>
                  </td>
                  <td class="text-small">{{ formatDireccion(contrato) }}</td>
                  <td>{{ formatPeriodo(contrato.inicio_oblig) }}</td>
                  <td>{{ formatPeriodo(contrato.fin_oblig) }}</td>
                  <td class="text-center">{{ contrato.cantidad_recoleccion }}</td>
                  <td class="text-center">
                    <span class="badge" :class="contrato.status_contrato === 'N' ? 'badge-success' : 'badge-danger'">
                      {{ contrato.status_contrato === 'N' ? 'ACTIVO' : 'INACTIVO' }}
                    </span>
                  </td>
                  <td>{{ formatDate(contrato.fecha_alta) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && datos.length === 0" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontraron contratos con los filtros seleccionados</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Reporte de Contratos">
      <h3>Reporte de Contratos</h3>
      <p>Genera un reporte detallado de todos los contratos registrados en el sistema.</p>

      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Tipo de Aseo:</strong> Comercial, Residencial, Industrial o Mixto</li>
        <li><strong>Status:</strong> Activos o Inactivos</li>
        <li><strong>Empresa:</strong> Filtrar por una empresa específica</li>
        <li><strong>Rango de fechas:</strong> Periodo de inicio de obligaciones</li>
        <li><strong>Ordenamiento:</strong> Por contrato, empresa, fecha alta o fecha inicio</li>
      </ul>

      <h4>Información Mostrada:</h4>
      <ul>
        <li>Número de contrato</li>
        <li>Empresa contratante</li>
        <li>Tipo de servicio de aseo</li>
        <li>Dirección del servicio</li>
        <li>Periodo de vigencia (inicio y fin)</li>
        <li>Cantidad de unidades contratadas</li>
        <li>Status actual del contrato</li>
        <li>Fecha de registro</li>
      </ul>

      <h4>Resumen Estadístico:</h4>
      <p>El reporte incluye un resumen con:</p>
      <ul>
        <li>Total de contratos encontrados</li>
        <li>Cantidad de contratos activos e inactivos</li>
        <li>Número de empresas diferentes</li>
        <li>Total de unidades contratadas</li>
      </ul>

      <h4>Exportación:</h4>
      <p>Puede exportar el reporte a Excel o PDF para su distribución o análisis posterior.</p>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rpt_Contratos'"
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

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const showDocumentation = ref(false)
const reporteGenerado = ref(false)
const datos = ref([])
const empresas = ref([])

const filtros = ref({
  tipo_aseo: '',
  status_contrato: '',
  num_empresa: '',
  inicio_desde: '',
  inicio_hasta: '',
  orden: 'num_contrato'
})

const totales = computed(() => {
  const activos = datos.value.filter(c => c.status_contrato === 'N').length
  const inactivos = datos.value.filter(c => c.status_contrato === 'B').length
  const empresasUnicas = new Set(datos.value.map(c => c.num_empresa))
  const unidades = datos.value.reduce((sum, c) => sum + parseInt(c.cantidad_recoleccion || 0), 0)

  return {
    activos,
    inactivos,
    empresas: empresasUnicas.size,
    unidades
  }
})

const generarReporte = async () => {
  showLoading()
  try {
    // Obtener todos los contratos
    const parVigencia = filtros.value.status_contrato === 'N' ? 'V' :
                        filtros.value.status_contrato === 'B' ? 'B' : 'T'

    const response = await execute('sp16_contratos', 'aseo_contratado', {
      parTipo: filtros.value.tipo_aseo || 'T',
      parVigencia: parVigencia
    })

    let contratos = response || []

    // Aplicar filtros adicionales localmente
    if (filtros.value.num_empresa) {
      contratos = contratos.filter(c => c.num_empresa === filtros.value.num_empresa)
    }

    if (filtros.value.inicio_desde) {
      contratos = contratos.filter(c => c.inicio_oblig >= filtros.value.inicio_desde + '-01')
    }

    if (filtros.value.inicio_hasta) {
      const fechaHasta = new Date(filtros.value.inicio_hasta + '-01')
      fechaHasta.setMonth(fechaHasta.getMonth() + 1)
      fechaHasta.setDate(0) // Último día del mes
      contratos = contratos.filter(c => c.inicio_oblig <= fechaHasta.toISOString().split('T')[0])
    }

    // Ordenar
    contratos.sort((a, b) => {
      switch (filtros.value.orden) {
        case 'num_contrato':
          return parseInt(a.num_contrato) - parseInt(b.num_contrato)
        case 'empresa':
          return (a.empresa || '').localeCompare(b.empresa || '')
        case 'fecha_alta':
          return new Date(a.fecha_alta) - new Date(b.fecha_alta)
        case 'inicio_oblig':
          return (a.inicio_oblig || '').localeCompare(b.inicio_oblig || '')
        default:
          return 0
      }
    })

    datos.value = contratos
    reporteGenerado.value = true
    showToast(`Reporte generado: ${contratos.length} contratos encontrados`, 'success')
  } catch (error) {
    hideLoading()
    showToast('Error al generar reporte', 'error')
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    tipo_aseo: '',
    status_contrato: '',
    num_empresa: '',
    inicio_desde: '',
    inicio_hasta: '',
    orden: 'num_contrato'
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

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-')
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
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

const getTipoAseoClass = (tipo) => {
  const classes = {
    'C': 'badge-primary',
    'R': 'badge-success',
    'I': 'badge-warning',
    'M': 'badge-info'
  }
  return classes[tipo] || 'badge-secondary'
}

const formatDireccion = (contrato) => {
  if (!contrato) return 'N/A'
  const partes = [
    contrato.calle,
    contrato.numext,
    contrato.colonia
  ].filter(Boolean)
  return partes.join(' ') || 'N/A'
}

const openDocumentation = () => {
  showDocumentation.value = true
}

// Cargar empresas al montar
const cargarEmpresas = async () => {
  try {
    const response = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 1000,
      p_search: null
    })
    if (response) empresas.value = response
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

cargarEmpresas()
</script>

