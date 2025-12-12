<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte por Zonas</h1>
        <p>Aseo Contratado - Análisis estadístico de contratos por zona de recolección</p>
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
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="parametros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Status</label>
            <select class="municipal-form-control" v-model="parametros.status">
              <option value="">Todos</option>
              <option value="A">Solo Activos</option>
              <option value="I">Solo Cancelados</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="parametros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
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
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="map-marker-alt" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosReporte.length }}</div>
            <div class="stat-label-mini">Zonas Activas</div>
          </div>
        </div>
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ totalContratos }}</div>
            <div class="stat-label-mini">Total Contratos</div>
          </div>
        </div>
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(ingresosTotales) }}</div>
            <div class="stat-label-mini">Ingresos Mensuales</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="calculator" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ Math.round(totalContratos / datosReporte.length) }}</div>
            <div class="stat-label-mini">Promedio por Zona - contratos</div>
          </div>
        </div>
      </div>

      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Distribución por Zona</h6>
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
                  <th>Zona</th>
                  <th class="text-end">Contratos Activos</th>
                  <th class="text-end">Contratos Cancelados</th>
                  <th class="text-end">Total Contratos</th>
                  <th class="text-end">% del Total</th>
                  <th class="text-end">Ingreso Mensual</th>
                  <th class="text-end">Cuota Promedio</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="zona in datosReporte" :key="zona.zona">
                  <td class="text-center">
                    <strong class="badge badge-primary" style="font-size: 1rem;">{{ zona.zona }}</strong>
                  </td>
                  <td class="text-end">{{ zona.activos }}</td>
                  <td class="text-end">{{ zona.cancelados }}</td>
                  <td class="text-end"><strong>{{ zona.total }}</strong></td>
                  <td class="text-end">
                    <span class="badge badge-info">{{ calcularPorcentaje(zona.total) }}%</span>
                  </td>
                  <td class="text-end">${{ formatCurrency(zona.ingresos) }}</td>
                  <td class="text-end">${{ formatCurrency(zona.cuota_promedio) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <th>TOTALES</th>
                  <th class="text-end">{{ sumaActivos }}</th>
                  <th class="text-end">{{ sumaCancelados }}</th>
                  <th class="text-end">{{ totalContratos }}</th>
                  <th class="text-end">100%</th>
                  <th class="text-end">${{ formatCurrency(ingresosTotales) }}</th>
                  <th class="text-end">${{ formatCurrency(cuotaPromedioGeneral) }}</th>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Gráfica: Contratos por Zona</h5>
            </div>
            <div class="municipal-card-body">
              <div v-for="zona in datosReporte.slice(0, 10)" :key="'graf-' + zona.zona" class="mb-3">
                <div class="d-flex justify-content-between mb-1">
                  <strong>Zona {{ zona.zona }}</strong>
                  <span>{{ zona.total }} contratos ({{ calcularPorcentaje(zona.total) }}%)</span>
                </div>
                <div class="progress" style="height: 25px;">
                  <div class="progress-bar bg-primary"
                    :style="{ width: calcularPorcentaje(zona.total) + '%' }">
                    {{ zona.total }}
                  </div>
                </div>
              </div>
              <p v-if="datosReporte.length > 10" class="text-muted text-center mt-3">
                Mostrando top 10 zonas. Total: {{ datosReporte.length }} zonas
              </p>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Gráfica: Ingresos por Zona</h5>
            </div>
            <div class="municipal-card-body">
              <div v-for="zona in topZonasPorIngresos" :key="'ing-' + zona.zona" class="mb-3">
                <div class="d-flex justify-content-between mb-1">
                  <strong>Zona {{ zona.zona }}</strong>
                  <span>${{ formatCurrency(zona.ingresos) }} ({{ calcularPorcentajeIngresos(zona.ingresos) }}%)</span>
                </div>
                <div class="progress" style="height: 25px;">
                  <div class="progress-bar bg-success"
                    :style="{ width: calcularPorcentajeIngresos(zona.ingresos) + '%' }">
                    ${{ formatCurrency(zona.ingresos) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mt-4">
        <div class="col-md-12">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Análisis Comparativo</h5>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-4">
                  <h6 class="text-center text-success">Top 3 Zonas con Más Contratos</h6>
                  <ol class="list-group list-group-numbered">
                    <li v-for="zona in topZonasContratos" :key="'top-c-' + zona.zona"
                        class="list-group-item d-flex justify-content-between align-items-start">
                      <div class="ms-2 me-auto">
                        <div class="fw-bold">Zona {{ zona.zona }}</div>
                        {{ zona.total }} contratos
                      </div>
                      <span class="badge bg-success rounded-pill">{{ calcularPorcentaje(zona.total) }}%</span>
                    </li>
                  </ol>
                </div>
                <div class="col-md-4">
                  <h6 class="text-center text-primary">Top 3 Zonas con Mayores Ingresos</h6>
                  <ol class="list-group list-group-numbered">
                    <li v-for="zona in topZonasPorIngresos.slice(0, 3)" :key="'top-i-' + zona.zona"
                        class="list-group-item d-flex justify-content-between align-items-start">
                      <div class="ms-2 me-auto">
                        <div class="fw-bold">Zona {{ zona.zona }}</div>
                        ${{ formatCurrency(zona.ingresos) }}
                      </div>
                      <span class="badge bg-primary rounded-pill">{{ calcularPorcentajeIngresos(zona.ingresos) }}%</span>
                    </li>
                  </ol>
                </div>
                <div class="col-md-4">
                  <h6 class="text-center text-info">Zonas con Mayor Cuota Promedio</h6>
                  <ol class="list-group list-group-numbered">
                    <li v-for="zona in topZonasCuotaPromedio" :key="'top-p-' + zona.zona"
                        class="list-group-item d-flex justify-content-between align-items-start">
                      <div class="ms-2 me-auto">
                        <div class="fw-bold">Zona {{ zona.zona }}</div>
                        ${{ formatCurrency(zona.cuota_promedio) }} promedio
                      </div>
                      <span class="badge bg-info rounded-pill">{{ zona.total }} contratos</span>
                    </li>
                  </ol>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Reporte por Zonas">
      <h6>Descripción</h6>
      <p>Genera análisis estadístico completo de contratos agrupados por zona de recolección.</p>
      <h6>Información Incluida</h6>
      <ul>
        <li>Cantidad de contratos activos y cancelados por zona</li>
        <li>Ingresos mensuales generados por zona</li>
        <li>Cuota promedio por zona</li>
        <li>Porcentaje de participación de cada zona</li>
        <li>Gráficas comparativas</li>
      </ul>
      <h6>Análisis Top</h6>
      <p>El reporte incluye análisis de las principales zonas en tres categorías:</p>
      <ul>
        <li>Zonas con más contratos</li>
        <li>Zonas con mayores ingresos</li>
        <li>Zonas con mayor cuota promedio</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_Zonas'"
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

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const datosReporte = ref([])
const empresas = ref([])

const parametros = ref({
  empresa: '',
  status: 'A',
  tipoAseo: ''
})

const totalContratos = computed(() => {
  return datosReporte.value.reduce((sum, zona) => sum + parseInt(zona.total || 0), 0)
})

const sumaActivos = computed(() => {
  return datosReporte.value.reduce((sum, zona) => sum + parseInt(zona.activos || 0), 0)
})

const sumaCancelados = computed(() => {
  return datosReporte.value.reduce((sum, zona) => sum + parseInt(zona.cancelados || 0), 0)
})

const ingresosTotales = computed(() => {
  return datosReporte.value.reduce((sum, zona) => sum + parseFloat(zona.ingresos || 0), 0)
})

const cuotaPromedioGeneral = computed(() => {
  return totalContratos.value > 0 ? ingresosTotales.value / sumaActivos.value : 0
})

const topZonasContratos = computed(() => {
  return [...datosReporte.value].sort((a, b) => b.total - a.total).slice(0, 3)
})

const topZonasPorIngresos = computed(() => {
  return [...datosReporte.value].sort((a, b) => b.ingresos - a.ingresos).slice(0, 10)
})

const topZonasCuotaPromedio = computed(() => {
  return [...datosReporte.value].sort((a, b) => b.cuota_promedio - a.cuota_promedio).slice(0, 3)
})

const calcularPorcentaje = (cantidad) => {
  return totalContratos.value > 0 ? ((cantidad / totalContratos.value) * 100).toFixed(2) : 0
}

const calcularPorcentajeIngresos = (ingreso) => {
  return ingresosTotales.value > 0 ? ((ingreso / ingresosTotales.value) * 100).toFixed(2) : 0
}

const generarReporte = async () => {
  cargando.value = true
  try {
    const params = {
      p_empresa: parametros.value.empresa || null,
      p_status: parametros.value.status || null,
      p_tipo_aseo: parametros.value.tipoAseo || null
    }
    const response = await execute('SP_ASEO_REPORTE_POR_ZONAS', 'aseo_contratado', params)
    datosReporte.value = response || []
    showToast(`Reporte generado: ${datosReporte.value.length} zonas`, 'success')
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

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {})
    empresas.value = response || []
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

