<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="bullhorn" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Anuncios para Excel</h1>
        <p>Padrón de Licencias - Exportación de Anuncios Publicitarios</p></div>
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
                :disabled="loading"
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
                :disabled="loading"
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
                :disabled="loading"
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
                :disabled="loading"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaFin"
                :disabled="loading"
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
                :disabled="loading"
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
                :disabled="loading"
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
                :disabled="loading"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Pago Fin:</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaPagoFin"
                :disabled="loading"
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
                :disabled="loading"
              >
              <small class="form-text">Dejar vacío para consultar todos</small>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="loading || !isFormValid"
            >
              <font-awesome-icon icon="chart-bar" />
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

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="anuncios.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Anuncios Encontrados
            <span class="badge-purple" v-if="anuncios.length > 0">{{ anuncios.length }} anuncios</span>
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
                <tr v-for="anun in anuncios" :key="anun.anuncio" class="clickable-row">
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

      <!-- Mensaje cuando no hay datos -->
      <div class="municipal-card" v-if="!loading && anuncios.length === 0 && reporteGenerado">
        <div class="municipal-card-body text-center text-muted">
          <font-awesome-icon icon="bullhorn" size="3x" class="empty-icon" />
          <p>No se encontraron anuncios con los criterios especificados</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Generando reporte de anuncios...</p>
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
      :componentName="'ReporteAnunExcelfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
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

// Estado
const anuncios = ref([])
const reporteGenerado = ref(false)

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

  setLoading(true, 'Generando reporte...')
  reporteGenerado.value = false

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
      reporteGenerado.value = true

      if (anuncios.value.length > 0) {
        showToast('success', `Se encontraron ${anuncios.value.length} anuncios`)
      } else {
        showToast('info', 'No se encontraron anuncios con los criterios especificados')
      }
    } else {
      anuncios.value = []
      reporteGenerado.value = true
      showToast('info', 'No se encontraron resultados')
    }
  } catch (error) {
    handleApiError(error)
    anuncios.value = []
    reporteGenerado.value = true
  } finally {
    setLoading(false)
  }
}

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

  showToast('info', 'Función de exportación a Excel en desarrollo')
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
  reporteGenerado.value = false
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

