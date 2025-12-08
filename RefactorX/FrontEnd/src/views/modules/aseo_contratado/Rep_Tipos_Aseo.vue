<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-pie" />
      </div>
      <div class="module-view-info">
        <h1>Reporte por Tipos de Aseo</h1>
        <p>Aseo Contratado - Análisis estadístico por clasificación de servicio</p>
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
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Configuración del Reporte</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Status de Contratos</label>
            <select class="municipal-form-control" v-model="parametros.status">
              <option value="">Todos</option>
              <option value="A">Solo Activos</option>
              <option value="I">Solo Cancelados</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="parametros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="generarReporte" :disabled="cargando">
              <font-awesome-icon icon="chart-bar" /> Generar Reporte
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="datosReporte.length > 0">
      <div class="row mb-3">
        <div class="col-md-3">
          <div class="municipal-card bg-success text-white">
            <div class="municipal-card-body">
              <h6>Total Contratos</h6>
              <h2>{{ totalContratos }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-primary text-white">
            <div class="municipal-card-body">
              <h6>Ingresos Totales</h6>
              <h2>${{ formatCurrency(ingresosTotales) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body">
              <h6>Cuota Promedio</h6>
              <h2>${{ formatCurrency(cuotaPromedio) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-warning text-dark">
            <div class="municipal-card-body">
              <h6>Tipos Activos</h6>
              <h2>{{ datosReporte.length }}</h2>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Resumen por Tipo de Aseo</h6>
          <div>
            <button class="btn btn-sm btn-success me-2" @click="exportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="imprimir">
              <font-awesome-icon icon="file-pdf" /> PDF
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table-sm table-bordered">
              <thead class="municipal-table-header">
                <tr>
                  <th>Tipo de Aseo</th>
                  <th class="text-end">Cantidad Contratos</th>
                  <th class="text-end">% del Total</th>
                  <th class="text-end">Ingreso Total Mensual</th>
                  <th class="text-end">Cuota Promedio</th>
                  <th class="text-end">Cuota Mínima</th>
                  <th class="text-end">Cuota Máxima</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in datosReporte" :key="item.tipo_aseo">
                  <td>
                    <strong>{{ formatTipoAseo(item.tipo_aseo) }}</strong>
                  </td>
                  <td class="text-end">{{ item.cantidad }}</td>
                  <td class="text-end">
                    <span class="badge badge-primary">{{ calcularPorcentaje(item.cantidad) }}%</span>
                  </td>
                  <td class="text-end">${{ formatCurrency(item.ingreso_total) }}</td>
                  <td class="text-end">${{ formatCurrency(item.cuota_promedio) }}</td>
                  <td class="text-end">${{ formatCurrency(item.cuota_minima) }}</td>
                  <td class="text-end">${{ formatCurrency(item.cuota_maxima) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <th>TOTALES</th>
                  <th class="text-end">{{ totalContratos }}</th>
                  <th class="text-end">100%</th>
                  <th class="text-end">${{ formatCurrency(ingresosTotales) }}</th>
                  <th class="text-end">${{ formatCurrency(cuotaPromedio) }}</th>
                  <th colspan="2"></th>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Gráfica de Distribución</h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6">
              <h6 class="text-center">Por Cantidad de Contratos</h6>
              <div v-for="item in datosReporte" :key="'cant-' + item.tipo_aseo" class="mb-2">
                <div class="d-flex justify-content-between">
                  <span>{{ formatTipoAseo(item.tipo_aseo) }}</span>
                  <span>{{ item.cantidad }} ({{ calcularPorcentaje(item.cantidad) }}%)</span>
                </div>
                <div class="progress">
                  <div class="progress-bar" :class="getColorClass(item.tipo_aseo)"
                    :style="{ width: calcularPorcentaje(item.cantidad) + '%' }">
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <h6 class="text-center">Por Ingresos Mensuales</h6>
              <div v-for="item in datosReporte" :key="'ing-' + item.tipo_aseo" class="mb-2">
                <div class="d-flex justify-content-between">
                  <span>{{ formatTipoAseo(item.tipo_aseo) }}</span>
                  <span>${{ formatCurrency(item.ingreso_total) }} ({{ calcularPorcentajeIngreso(item.ingreso_total) }}%)</span>
                </div>
                <div class="progress">
                  <div class="progress-bar" :class="getColorClass(item.tipo_aseo)"
                    :style="{ width: calcularPorcentajeIngreso(item.ingreso_total) + '%' }">
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Reporte por Tipos de Aseo">
      <h6>Descripción</h6>
      <p>Genera análisis estadístico completo agrupado por tipo de servicio de aseo.</p>
      <h6>Tipos de Aseo</h6>
      <ul>
        <li><strong>Doméstico:</strong> Servicio residencial</li>
        <li><strong>Comercial:</strong> Establecimientos comerciales</li>
        <li><strong>Industrial:</strong> Plantas industriales</li>
        <li><strong>Servicios:</strong> Instituciones y servicios</li>
      </ul>
      <h6>Información Incluida</h6>
      <ul>
        <li>Cantidad y porcentaje de contratos</li>
        <li>Ingresos totales y promedios</li>
        <li>Rangos de cuotas (mínima/máxima)</li>
        <li>Gráficas de distribución</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_Tipos_Aseo'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const datosReporte = ref([])
const zonas = ref([])

const parametros = ref({
  status: 'A',
  zona: ''
})

const totalContratos = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseInt(item.cantidad || 0), 0)
})

const ingresosTotales = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseFloat(item.ingreso_total || 0), 0)
})

const cuotaPromedio = computed(() => {
  return totalContratos.value > 0 ? ingresosTotales.value / totalContratos.value : 0
})

const calcularPorcentaje = (cantidad) => {
  return totalContratos.value > 0 ? ((cantidad / totalContratos.value) * 100).toFixed(2) : 0
}

const calcularPorcentajeIngreso = (ingreso) => {
  return ingresosTotales.value > 0 ? ((ingreso / ingresosTotales.value) * 100).toFixed(2) : 0
}

const getColorClass = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
}

const generarReporte = async () => {
  cargando.value = true
  try {
    const params = {
      p_status: parametros.value.status || null,
      p_zona: parametros.value.zona || null
    }
    const response = await execute('SP_ASEO_REPORTE_TIPOS_ASEO', 'aseo_contratado', params)
    datosReporte.value = response || []
    showToast(`Reporte generado: ${datosReporte.value.length} tipos`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al generar reporte')
  } finally {
    cargando.value = false
  }
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    zonas.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

