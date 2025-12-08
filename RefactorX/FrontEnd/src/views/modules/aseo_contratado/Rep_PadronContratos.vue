<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-lines" />
      </div>
      <div class="module-view-info">
        <h1>Padrón de Contratos</h1>
        <p>Aseo Contratado - Reporte completo del padrón de contratos registrados</p>
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
        <h5>Parámetros del Reporte</h5>
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
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="parametros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Status</label>
            <select class="municipal-form-control" v-model="parametros.status">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Cancelados</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Ordenar Por</label>
            <select class="municipal-form-control" v-model="parametros.ordenar">
              <option value="contrato">Contrato</option>
              <option value="contribuyente">Contribuyente</option>
              <option value="zona">Zona</option>
              <option value="fecha">Fecha Alta</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="generarReporte" :disabled="cargando">
              <font-awesome-icon icon="file-pdf" /> Generar Reporte
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="datosReporte.length > 0" class="municipal-card">
      <div class="municipal-card-header bg-light d-flex justify-content-between">
        <h6 class="mb-0">Vista Previa del Reporte</h6>
        <div>
          <button class="btn btn-sm btn-success me-2" @click="exportarExcel">
            <font-awesome-icon icon="file-excel" /> Excel
          </button>
          <button class="btn btn-sm btn-danger" @click="exportarPDF">
            <font-awesome-icon icon="file-pdf" /> PDF
          </button>
        </div>
      </div>
      <div class="municipal-card-body">
        <div class="mb-3">
          <h5 class="text-center">PADRÓN DE CONTRATOS DE ASEO CONTRATADO</h5>
          <p class="text-center text-muted">
            Fecha de emisión: {{ new Date().toLocaleDateString('es-MX') }}
          </p>
          <div class="row">
            <div class="col-md-12">
              <strong>Filtros aplicados:</strong>
              {{ obtenerFiltrosTexto() }}
            </div>
          </div>
        </div>

        <div class="table-responsive">
          <table class="municipal-table-sm table-bordered">
            <thead class="municipal-table-header">
              <tr>
                <th>#</th>
                <th>Contrato</th>
                <th>Contribuyente</th>
                <th>RFC</th>
                <th>Domicilio</th>
                <th>Tipo</th>
                <th>Zona</th>
                <th>Empresa</th>
                <th class="text-end">Cuota</th>
                <th>Fecha Alta</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in datosReporte" :key="item.control_contrato">
                <td>{{ index + 1 }}</td>
                <td>{{ item.num_contrato }}</td>
                <td>{{ item.contribuyente }}</td>
                <td>{{ item.rfc || 'N/A' }}</td>
                <td>{{ item.domicilio }}</td>
                <td>{{ formatTipoAseo(item.tipo_aseo) }}</td>
                <td>{{ item.zona }}</td>
                <td>{{ item.empresa }}</td>
                <td class="text-end">${{ formatCurrency(item.cuota_mensual) }}</td>
                <td>{{ formatFecha(item.fecha_alta) }}</td>
                <td>{{ item.status === 'A' ? 'Activo' : 'Cancelado' }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <th colspan="8" class="text-end">TOTAL:</th>
                <th class="text-end">${{ formatCurrency(totalCuotas) }}</th>
                <th colspan="2">{{ datosReporte.length }} contratos</th>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Padrón de Contratos">
      <h6>Descripción</h6>
      <p>Genera el reporte completo del padrón de contratos registrados en el sistema.</p>
      <h6>Opciones de Filtrado</h6>
      <ul>
        <li>Por empresa prestadora del servicio</li>
        <li>Por tipo de aseo</li>
        <li>Por status (activos/cancelados)</li>
        <li>Ordenamiento configurable</li>
      </ul>
      <h6>Formatos de Exportación</h6>
      <ul>
        <li>PDF para impresión oficial</li>
        <li>Excel para análisis de datos</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_PadronContratos'"
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
const empresas = ref([])

const parametros = ref({
  empresa: '',
  tipoAseo: '',
  status: '',
  ordenar: 'contrato'
})

const totalCuotas = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseFloat(item.cuota_mensual || 0), 0)
})

const generarReporte = async () => {
  cargando.value = true
  try {
    const params = {
      p_empresa: parametros.value.empresa || null,
      p_tipo_aseo: parametros.value.tipoAseo || null,
      p_status: parametros.value.status || null,
      p_ordenar: parametros.value.ordenar
    }
    const response = await execute('SP_ASEO_REPORTE_PADRON_CONTRATOS', 'aseo_contratado', params)
    datosReporte.value = response || []
    showToast(`Reporte generado: ${datosReporte.value.length} registros`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al generar reporte')
  } finally {
    cargando.value = false
  }
}

const obtenerFiltrosTexto = () => {
  const filtros = []
  if (parametros.value.empresa) {
    const emp = empresas.value.find(e => e.num_empresa === parametros.value.empresa)
    if (emp) filtros.push(`Empresa: ${emp.nombre_empresa}`)
  }
  if (parametros.value.tipoAseo) {
    filtros.push(`Tipo: ${formatTipoAseo(parametros.value.tipoAseo)}`)
  }
  if (parametros.value.status) {
    filtros.push(`Status: ${parametros.value.status === 'A' ? 'Activos' : 'Cancelados'}`)
  }
  return filtros.length > 0 ? filtros.join(' | ') : 'Sin filtros'
}

const exportarExcel = () => showToast('Exportando a Excel...', 'info')
const exportarPDF = () => showToast('Generando PDF...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
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

