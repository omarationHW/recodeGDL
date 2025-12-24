<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="bullhorn" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Anuncios para Excel</h1>
        <p>Padrón de Licencias - Exportación de Anuncios Publicitarios</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de reporte -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Configuración del Reporte
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Vigencia -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Vigencia: <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model="filters.vigencia"
              >
                <option value="1">Vigentes</option>
                <option value="2">Cancelados/Baja</option>
                <option value="3">Anulados</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Tipo de Reporte: <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoReporte"
              >
                <option value="0">Hasta una fecha</option>
                <option value="1">Rango de fechas</option>
              </select>
            </div>
          </div>

          <!-- Fechas según tipo de reporte -->
          <div class="form-row" v-if="filters.tipoReporte === '0'">
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Consulta: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaConsulta"
              >
            </div>
          </div>

          <div class="form-row" v-if="filters.tipoReporte === '1'">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Inicio: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaInicio"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaFin"
              >
            </div>
          </div>

          <!-- Filtros adicionales -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro de Adeudo:</label>
              <select
                class="municipal-form-control"
                v-model="filters.adeudo"
              >
                <option value="1">Sin adeudo</option>
                <option value="2">Con adeudo del año</option>
                <option value="3">Pagos realizados desde año</option>
                <option value="4">Adeudo hasta año</option>
                <option value="5">Adeudo del año específico</option>
                <option value="6">Pagos en rango de fechas</option>
              </select>
            </div>

            <div class="form-group" v-if="filters.adeudo !== '6'">
              <label class="municipal-form-label">Año de Referencia:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filters.yearInicio"
                :min="2000"
                :max="new Date().getFullYear()"
                placeholder="Ej: 2024"
              >
            </div>
          </div>

          <!-- Fechas de pago (solo para adeudo tipo 6) -->
          <div class="form-row" v-if="filters.adeudo === '6'">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Pago Inicio:</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaPagoInicio"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Pago Fin:</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaPagoFin"
              >
            </div>
          </div>

          <!-- Grupo de anuncios -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Grupo de Anuncios (Opcional):</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filters.grupoAnuncioId"
                placeholder="ID del grupo de anuncios"
              >
              <small class="form-text">Dejar vacío para consultar todos</small>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="!isFormValid"
            >
              <font-awesome-icon icon="chart-bar" />
              Generar Reporte
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="anuncios.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Anuncios Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="anuncios.length > 0">{{ anuncios.length }} anuncios</span>
            <button
              class="btn-municipal-primary"
              @click="exportarExcel"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 80px">Anuncio</th>
                  <th>Propietario</th>
                  <th style="width: 80px">Licencia</th>
                  <th>Tipo Anuncio</th>
                  <th>Medidas</th>
                  <th>Área m²</th>
                  <th style="width: 60px">Caras</th>
                  <th>Ubicación</th>
                  <th>Colonia</th>
                  <th style="width: 60px">Zona</th>
                  <th>Fecha Otorg.</th>
                  <th style="width: 80px">Estado</th>
                  <th style="width: 100px" v-if="showAdeudo">Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="anun in anuncios"
                  :key="anun.anuncio"
                  @click="selectedRow = anun"
                  :class="{ 'table-row-selected': selectedRow === anun }"
                  class="row-hover"
                >
                  <td>
                    <strong class="text-primary">{{ anun.anuncio }}</strong>
                  </td>
                  <td>{{ anun.propietario || 'N/A' }}</td>
                  <td class="text-center">
                    <span class="badge-secondary">{{ anun.licencia }}</span>
                  </td>
                  <td>{{ anun.tipo_anuncio || 'N/A' }}</td>
                  <td class="text-center">
                    <small>{{ anun.medidas1 }} x {{ anun.medidas2 }}</small>
                  </td>
                  <td class="text-right">{{ formatNumber(anun.area_anuncio) }}</td>
                  <td class="text-center">{{ anun.num_caras || 0 }}</td>
                  <td>
                    {{ anun.ubicacion }}
                    {{ anun.numext_ubic ? '#' + anun.numext_ubic : '' }}
                    {{ anun.letraext_ubic || '' }}
                  </td>
                  <td>{{ anun.colonia_ubic || 'N/A' }}</td>
                  <td class="text-center">
                    <span class="badge-purple">{{ anun.zona || 'N/A' }}</span>
                  </td>
                  <td>
                    <small class="text-muted">
                      {{ formatDate(anun.fecha_otorgamiento) }}
                    </small>
                  </td>
                  <td>
                    <span class="badge" :class="getVigenciaBadgeClass(anun.vigente)">
                      {{ getVigenciaText(anun.vigente) }}
                    </span>
                  </td>
                  <td class="text-right" v-if="showAdeudo">
                    <span v-if="anun.adeudo" :class="anun.adeudo > 0 ? 'text-danger' : 'text-success'">
                      {{ formatCurrency(anun.adeudo) }}
                    </span>
                    <span v-else class="text-muted">-</span>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="showAdeudo && totalAdeudo > 0">
                <tr class="table-total-row">
                  <td :colspan="showAdeudo ? 12 : 11" class="text-right">
                    <strong>Total Adeudo:</strong>
                  </td>
                  <td class="text-right">
                    <strong class="text-danger">{{ formatCurrency(totalAdeudo) }}</strong>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Resumen -->
          <div class="table-summary">
            <div class="summary-item">
              <strong>Total de anuncios:</strong>
              <span class="badge-primary">{{ anuncios.length }}</span>
            </div>
            <div class="summary-item">
              <strong>Área total:</strong>
              <span>{{ formatNumber(totalArea) }} m²</span>
            </div>
            <div class="summary-item" v-if="showAdeudo && totalAdeudo > 0">
              <strong>Adeudo total:</strong>
              <span class="text-danger">{{ formatCurrency(totalAdeudo) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="anuncios.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="bullhorn" size="3x" />
        </div>
        <h4>Reporte de Anuncios para Excel</h4>
        <p>Configure los filtros y genere el reporte de anuncios publicitarios</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="anuncios.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron anuncios con los criterios especificados</p>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ReporteAnunExcelfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Reporte de Anuncios para Excel'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useExcelExport } from '@/composables/useExcelExport'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { exportToExcel } = useExcelExport()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const anuncios = ref([])
const reporteGenerado = ref(false)
const selectedRow = ref(null)
const hasSearched = ref(false)

const filters = ref({
  vigencia: '1',
  tipoReporte: '0',
  fechaConsulta: '',
  fechaInicio: '',
  fechaFin: '',
  adeudo: '1',
  yearInicio: new Date().getFullYear(),
  fechaPagoInicio: '',
  fechaPagoFin: '',
  grupoAnuncioId: null
})

// Computed
const isFormValid = computed(() => {
  if (filters.value.tipoReporte === '0') {
    return filters.value.fechaConsulta !== ''
  } else if (filters.value.tipoReporte === '1') {
    return filters.value.fechaInicio !== '' && filters.value.fechaFin !== ''
  }
  return false
})

const showAdeudo = computed(() => {
  return ['2', '3', '4', '5', '6'].includes(filters.value.adeudo)
})

const totalArea = computed(() => {
  return anuncios.value.reduce((sum, anun) => sum + (parseFloat(anun.area_anuncio) || 0), 0)
})

const totalAdeudo = computed(() => {
  if (!showAdeudo.value) return 0
  return anuncios.value.reduce((sum, anun) => sum + (parseFloat(anun.adeudo) || 0), 0)
})

// Métodos
const generarReporte = async () => {
  if (!isFormValid.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Generando reporte...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const params = [
      { nombre: 'p_vigencia', valor: parseInt(filters.value.vigencia), tipo: 'integer' },
      { nombre: 'p_tiporep', valor: parseInt(filters.value.tipoReporte), tipo: 'integer' },
      {
        nombre: 'p_fechacons',
        valor: filters.value.tipoReporte === '0' ? filters.value.fechaConsulta : null,
        tipo: 'string'
      },
      {
        nombre: 'p_fechaini',
        valor: filters.value.tipoReporte === '1' ? filters.value.fechaInicio : null,
        tipo: 'string'
      },
      {
        nombre: 'p_fechafin',
        valor: filters.value.tipoReporte === '1' ? filters.value.fechaFin : null,
        tipo: 'string'
      },
      { nombre: 'p_adeudo', valor: parseInt(filters.value.adeudo), tipo: 'integer' },
      { nombre: 'p_axoini', valor: parseInt(filters.value.yearInicio), tipo: 'integer' },
      {
        nombre: 'p_fechapagoini',
        valor: filters.value.adeudo === '6' ? filters.value.fechaPagoInicio : null,
        tipo: 'string'
      },
      {
        nombre: 'p_fechapagofin',
        valor: filters.value.adeudo === '6' ? filters.value.fechaPagoFin : null,
        tipo: 'string'
      },
      {
        nombre: 'p_grupoanunid',
        valor: filters.value.grupoAnuncioId ? parseInt(filters.value.grupoAnuncioId) : null,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'sp_reporte_anuncios_excel',
      'padron_licencias',
      params,
      'guadalajara'
    )

    if (response && response.result) {
      anuncios.value = response.result

      if (anuncios.value.length > 0) {
        showToast('success', `Se encontraron ${anuncios.value.length} anuncios`)
      } else {
        showToast('info', 'No se encontraron anuncios con los criterios especificados')
      }
    } else {
      anuncios.value = []
      showToast('info', 'No se encontraron resultados')
    }
  } catch (error) {
    handleApiError(error)
    anuncios.value = []
  } finally {
    hideLoading()
  }
}

// Definición de columnas para exportación
const columnasExport = computed(() => {
  const cols = [
    { header: 'Anuncio', key: 'anuncio', width: 12 },
    { header: 'Propietario', key: 'propietario', width: 35 },
    { header: 'Licencia', key: 'licencia', width: 12 },
    { header: 'Tipo Anuncio', key: 'tipo_anuncio', width: 25 },
    { header: 'Medidas 1', key: 'medidas1', type: 'number', width: 12 },
    { header: 'Medidas 2', key: 'medidas2', type: 'number', width: 12 },
    { header: 'Área m²', key: 'area_anuncio', type: 'number', width: 12 },
    { header: 'Caras', key: 'num_caras', type: 'integer', width: 8 },
    { header: 'Ubicación', key: 'ubicacion', width: 35 },
    { header: 'No. Ext', key: 'numext_ubic', width: 10 },
    { header: 'Colonia', key: 'colonia_ubic', width: 25 },
    { header: 'Zona', key: 'zona', width: 10 },
    { header: 'Fecha Otorg.', key: 'fecha_otorgamiento', type: 'date', width: 15 },
    { header: 'Estado', key: 'vigente', width: 12 }
  ]

  // Agregar columna de adeudo si aplica
  if (showAdeudo.value) {
    cols.push({ header: 'Adeudo', key: 'adeudo', type: 'currency', width: 15 })
  }

  return cols
})

const exportarExcel = async () => {
  if (anuncios.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay anuncios para exportar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Generando Excel...', 'Por favor espere')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con texto de vigencia
    const datosExport = anuncios.value.map(anun => ({
      ...anun,
      vigente: getVigenciaText(anun.vigente)
    }))

    const success = exportToExcel(datosExport, columnasExport.value, 'Reporte_Anuncios')

    if (success) {
      showToast('success', `Excel generado con ${anuncios.value.length} anuncios`)
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
    vigencia: '1',
    tipoReporte: '0',
    fechaConsulta: '',
    fechaInicio: '',
    fechaFin: '',
    adeudo: '1',
    yearInicio: new Date().getFullYear(),
    fechaPagoInicio: '',
    fechaPagoFin: '',
    grupoAnuncioId: null
  }
  anuncios.value = []
  hasSearched.value = false
  selectedRow.value = null
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatNumber = (value) => {
  if (!value) return '0'
  return parseFloat(value).toFixed(2)
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  const num = parseFloat(value)
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(num)
}

const getVigenciaBadgeClass = (vigente) => {
  const classes = {
    'V': 'badge-success',
    'B': 'badge-danger',
    'C': 'badge-danger',
    'A': 'badge-warning'
  }
  return classes[vigente] || 'badge-secondary'
}

const getVigenciaText = (vigente) => {
  const texts = {
    'V': 'Vigente',
    'B': 'Baja',
    'C': 'Cancelado',
    'A': 'Anulado'
  }
  return texts[vigente] || 'Desconocido'
}

// Lifecycle
onMounted(() => {
  // Establecer fecha de consulta por defecto (hoy)
  const today = new Date()
  filters.value.fechaConsulta = today.toISOString().split('T')[0]
})
</script>

