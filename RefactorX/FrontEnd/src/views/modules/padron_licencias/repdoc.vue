<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Documentos y Requisitos</h1>
        <p>Padrón de Licencias - Requisitos por Giro</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de reporte -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Giro: <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoGiro"
                @change="loadGiros"
                :disabled="loading"
              >
                <option value="">Seleccionar tipo...</option>
                <option value="L">Licencias</option>
                <option value="A">Anuncios</option>
                <option value="E">Eventuales</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Giro: <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model="filters.idGiro"
                :disabled="loading || !filters.tipoGiro || giros.length === 0"
              >
                <option value="">Seleccionar giro...</option>
                <option
                  v-for="giro in giros"
                  :key="giro.id_giro"
                  :value="giro.id_giro"
                >
                  {{ giro.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Reporte:</label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoReporte"
                :disabled="loading"
              >
                <option value="requisitos">Requisitos por Giro</option>
                <option value="permisos">Permisos Eventuales</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="loading || !filters.tipoGiro || !filters.idGiro"
            >
              <font-awesome-icon icon="file-pdf" />
              Generar Reporte
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de requisitos -->
      <div class="municipal-card" v-if="requisitos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-check" />
            Requisitos del Giro
            <span class="badge-purple" v-if="requisitos.length > 0">{{ requisitos.length }} requisitos</span>
          </h5>
          <button
            class="btn-municipal-primary"
            @click="exportarExcel"
            :disabled="loading"
          >
            <font-awesome-icon icon="file-excel" />
            Exportar a Excel
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="col-narrow">No.</th>
                  <th>Requisito</th>
                  <th class="col-medium">Obligatorio</th>
                  <th class="col-medium">Tipo Doc.</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(req, index) in requisitos" :key="req.id_requisito" class="clickable-row">
                  <td class="text-center">
                    <span class="badge-secondary">{{ index + 1 }}</span>
                  </td>
                  <td>{{ req.descripcion }}</td>
                  <td class="text-center">
                    <span class="badge" :class="req.obligatorio === 'S' ? 'badge-danger' : 'badge-secondary'">
                      <font-awesome-icon :icon="req.obligatorio === 'S' ? 'exclamation-circle' : 'info-circle'" />
                      {{ req.obligatorio === 'S' ? 'Obligatorio' : 'Opcional' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <code>{{ req.tipo_documento || 'General' }}</code>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay datos -->
      <div class="municipal-card" v-if="!loading && requisitos.length === 0 && filters.idGiro">
        <div class="municipal-card-body text-center text-muted">
          <font-awesome-icon icon="inbox" size="3x" class="empty-icon" />
          <p>No hay requisitos registrados para este giro</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando información...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'repdoc'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useExcelExport } from '@/composables/useExcelExport'
import { usePdfExport } from '@/composables/usePdfExport'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { exportToExcel } = useExcelExport()
const { exportToPdf } = usePdfExport()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const giros = ref([])
const requisitos = ref([])
const filters = ref({
  tipoGiro: '',
  idGiro: '',
  tipoReporte: 'requisitos'
})

// Métodos
const loadGiros = async () => {
  if (!filters.value.tipoGiro) {
    giros.value = []
    return
  }

  setLoading(true, 'Cargando giros...')

  try {
    const response = await execute(
      'sp_repdoc_get_giros',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: filters.value.tipoGiro, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      giros.value = response.result
      showToast('success', `${giros.value.length} giros cargados`)
    } else {
      giros.value = []
      showToast('warning', 'No se encontraron giros')
    }
  } catch (error) {
    handleApiError(error)
    giros.value = []
  } finally {
    setLoading(false)
  }
}

const loadRequisitos = async () => {
  if (!filters.value.idGiro) {
    requisitos.value = []
    return
  }

  setLoading(true, 'Cargando requisitos...')

  try {
    const response = await execute(
      'sp_repdoc_get_requisitos_by_giro',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: filters.value.idGiro, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      requisitos.value = response.result
      showToast('success', `${requisitos.value.length} requisitos encontrados`)
    } else {
      requisitos.value = []
      showToast('info', 'No hay requisitos para este giro')
    }
  } catch (error) {
    handleApiError(error)
    requisitos.value = []
  } finally {
    setLoading(false)
  }
}

const generarReporte = async () => {
  if (!filters.value.tipoGiro || !filters.value.idGiro) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor seleccione el tipo de giro y el giro',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Cargar requisitos
  await loadRequisitos()

  // Mensaje de éxito con opción de generar PDF
  const result = await Swal.fire({
    icon: 'success',
    title: 'Reporte generado',
    text: 'Los requisitos se han cargado correctamente. ¿Desea generar el PDF?',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Generar PDF',
    cancelButtonText: 'Solo ver en pantalla'
  })

  if (result.isConfirmed) {
    await imprimirReporte()
  }
}

// Definición de columnas para exportación
const columnasExport = [
  { header: 'No.', key: 'numero', type: 'integer', width: 8 },
  { header: 'Requisito', key: 'descripcion', width: 60 },
  { header: 'Obligatorio', key: 'obligatorio_texto', width: 15 },
  { header: 'Tipo Documento', key: 'tipo_documento', width: 20 }
]

// Nombre del giro seleccionado
const giroSeleccionado = computed(() => {
  const giro = giros.value.find(g => g.id_giro === filters.value.idGiro)
  return giro?.descripcion || 'Sin seleccionar'
})

const imprimirReporte = async () => {
  if (requisitos.value.length === 0) {
    showToast('warning', 'No hay requisitos para generar PDF')
    return
  }

  showLoading('Generando PDF...', 'Por favor espere')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con número y texto de obligatorio
    const datosExport = requisitos.value.map((req, index) => ({
      numero: index + 1,
      descripcion: req.descripcion,
      obligatorio_texto: req.obligatorio === 'S' ? 'Obligatorio' : 'Opcional',
      tipo_documento: req.tipo_documento || 'General'
    }))

    const success = exportToPdf(datosExport, columnasExport, {
      title: 'Requisitos por Giro',
      subtitle: `Giro: ${giroSeleccionado.value}`,
      orientation: 'portrait'
    })

    if (success) {
      showToast('success', 'PDF generado correctamente')
    } else {
      showToast('error', 'Error al generar PDF')
    }
  } catch (error) {
    showToast('error', 'Error al generar PDF')
  } finally {
    hideLoading()
  }
}

const exportarExcel = async () => {
  if (requisitos.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay requisitos para exportar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Generando Excel...', 'Por favor espere')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con número y texto de obligatorio
    const datosExport = requisitos.value.map((req, index) => ({
      numero: index + 1,
      descripcion: req.descripcion,
      obligatorio_texto: req.obligatorio === 'S' ? 'Obligatorio' : 'Opcional',
      tipo_documento: req.tipo_documento || 'General'
    }))

    const success = exportToExcel(datosExport, columnasExport, `Requisitos_${giroSeleccionado.value.replace(/\s+/g, '_')}`)

    if (success) {
      showToast('success', `Excel generado con ${requisitos.value.length} requisitos`)
    } else {
      showToast('error', 'Error al generar Excel')
    }
  } catch (error) {
    showToast('error', 'Error al generar Excel')
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    tipoGiro: '',
    idGiro: '',
    tipoReporte: 'requisitos'
  }
  giros.value = []
  requisitos.value = []
}

// Lifecycle
onMounted(() => {
  // Inicialización si es necesario
})
</script>
