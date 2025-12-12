<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="home" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Contratos Domésticos</h1>
        <p>Aseo Contratado - Vista especializada para contratos de servicio doméstico</p>
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
        <h5>Filtros de Búsqueda</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas las zonas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }} - {{ z.descripcion }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Búsqueda</label>
            <input type="text" class="municipal-form-control" v-model="filtros.busqueda"
              placeholder="Cuenta predial, contrato o contribuyente" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Status</label>
            <select class="municipal-form-control" v-model="filtros.status">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Cancelados</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="consultar" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-secondary w-100" @click="limpiar">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratos.length > 0">
      <div class="row mb-3">
        <div class="col-md-3">
          <div class="municipal-card bg-success text-white">
            <div class="municipal-card-body">
              <h6>Total Contratos Domésticos</h6>
              <h2>{{ contratos.length }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-primary text-white">
            <div class="municipal-card-body">
              <h6>Activos</h6>
              <h2>{{ contratosActivos }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body">
              <h6>Ingresos Mensuales</h6>
              <h2>${{ formatCurrency(ingresosMensuales) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-warning text-dark">
            <div class="municipal-card-body">
              <h6>Cuota Promedio</h6>
              <h2>${{ formatCurrency(cuotaPromedio) }}</h2>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Resultados ({{ contratos.length }} contratos domésticos)</h6>
          <div>
            <button class="btn btn-sm btn-success me-2" @click="exportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Cuenta Predial</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Zona</th>
                  <th class="text-end">Cuota Mensual</th>
                  <th>Fecha Alta</th>
                  <th>Status</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.cuenta_predial || 'N/A' }}</td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.domicilio }}</td>
                  <td>{{ contrato.zona }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                  <td>{{ formatFecha(contrato.fecha_alta) }}</td>
                  <td>
                    <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-danger'">
                      {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
                    </span>
                  </td>
                  <td>
                    <button class="btn btn-sm btn-info me-1" @click="verDetalle(contrato)" title="Ver detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button class="btn btn-sm btn-success" @click="verAdeudos(contrato)" title="Ver adeudos">
                      <font-awesome-icon icon="file-invoice-dollar" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="!cargando && consultaRealizada" class="municipal-alert municipal-alert-info">
      <font-awesome-icon icon="info-circle" class="me-2" />
      No se encontraron contratos domésticos con los criterios especificados.
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta de Contratos Domésticos">
      <h6>Descripción</h6>
      <p>Vista especializada para consultar únicamente contratos de servicio de aseo doméstico.</p>
      <h6>Características</h6>
      <ul>
        <li>Filtrado por zona geográfica</li>
        <li>Búsqueda por cuenta predial, contrato o contribuyente</li>
        <li>Estadísticas en tiempo real</li>
        <li>Visualización de cuota mensual y totales</li>
        <li>Exportación a Excel e impresión</li>
      </ul>
      <h6>Información Disponible</h6>
      <ul>
        <li>Total de contratos domésticos</li>
        <li>Contratos activos vs cancelados</li>
        <li>Ingresos mensuales proyectados</li>
        <li>Cuota promedio del sector doméstico</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Contratos_Cons_Dom'"
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
const consultaRealizada = ref(false)
const contratos = ref([])
const zonas = ref([])

const filtros = ref({
  zona: '',
  busqueda: '',
  status: ''
})

const contratosActivos = computed(() => contratos.value.filter(c => c.status === 'A').length)

const ingresosMensuales = computed(() => {
  return contratos.value
    .filter(c => c.status === 'A')
    .reduce((sum, c) => sum + parseFloat(c.cuota_mensual || 0), 0)
})

const cuotaPromedio = computed(() => {
  const activos = contratos.value.filter(c => c.status === 'A')
  return activos.length > 0 ? ingresosMensuales.value / activos.length : 0
})

const consultar = async () => {
  cargando.value = true
  consultaRealizada.value = false
  try {
    const params = {
      p_tipo_aseo: 'D', // Filtro fijo para doméstico
      p_zona: filtros.value.zona || null,
      p_busqueda: filtros.value.busqueda || null,
      p_status: filtros.value.status || null
    }
    const response = await execute('SP_ASEO_CONTRATOS_POR_TIPO', 'aseo_contratado', params)
    contratos.value = response || []
    consultaRealizada.value = true
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al consultar contratos')
  } finally {
    cargando.value = false
  }
}

const limpiar = () => {
  filtros.value = {
    zona: '',
    busqueda: '',
    status: ''
  }
  contratos.value = []
  consultaRealizada.value = false
}

const verDetalle = (contrato) => {
  showToast(`Ver detalle de contrato: ${contrato.num_contrato}`, 'info')
}

const verAdeudos = (contrato) => {
  showToast(`Ver adeudos de contrato: ${contrato.num_contrato}`, 'info')
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
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

