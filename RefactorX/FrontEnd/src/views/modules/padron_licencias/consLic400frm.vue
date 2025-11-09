<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Licencias AS/400</h1>
        <p>Padrón de Licencias - Consulta de Datos Históricos del Sistema AS/400</p></div>
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

    <!-- Mensaje informativo -->
    <div class="alert-info">
      <font-awesome-icon icon="info-circle" />
      <strong>Sistema Legacy AS/400:</strong> Esta consulta muestra información histórica del sistema anterior. Los datos son de solo lectura y se mantienen para referencia.
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.numeroLicencia"
              placeholder="Ingrese número de licencia"
              @keyup.enter="searchLicencia"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencia"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
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

    <!-- Información de la licencia -->
    <div class="municipal-card" v-if="licenciaInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Información de la Licencia AS/400
          <span class="badge-warning">Legacy</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Datos Generales
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Número de Licencia:</td>
                <td><code class="text-primary">{{ licenciaInfo.numero_licencia?.trim() }}</code></td>
              </tr>
              <tr>
                <td class="label">Contribuyente:</td>
                <td><strong>{{ licenciaInfo.contribuyente?.trim() || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ licenciaInfo.rfc?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>
                  <span class="badge-purple">
                    {{ licenciaInfo.giro?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Categoría:</td>
                <td>{{ licenciaInfo.categoria?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ licenciaInfo.domicilio?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ licenciaInfo.colonia?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td><code>{{ licenciaInfo.cp?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>
                  <span class="badge-secondary">
                    Zona {{ licenciaInfo.zona || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Fechas
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Expedición:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(licenciaInfo.fecha_expedicion) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Vigencia:</td>
                <td>
                  <font-awesome-icon icon="calendar-check" class="text-info" />
                  {{ formatDate(licenciaInfo.fecha_vigencia) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Baja:</td>
                <td>
                  <font-awesome-icon icon="calendar-minus" class="text-danger" />
                  {{ formatDate(licenciaInfo.fecha_baja) }}
                </td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Estado
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Estatus:</td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(licenciaInfo.estatus)">
                    <font-awesome-icon :icon="getStatusIcon(licenciaInfo.estatus)" />
                    {{ licenciaInfo.estatus?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Superficie M²:</td>
                <td>{{ licenciaInfo.superficie || '0' }} m²</td>
              </tr>
              <tr>
                <td class="label">Empleados:</td>
                <td>{{ licenciaInfo.empleados || '0' }}</td>
              </tr>
              <tr>
                <td class="label">Observaciones:</td>
                <td>{{ licenciaInfo.observaciones?.trim() || 'Sin observaciones' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de pagos -->
    <div class="municipal-card" v-if="licenciaInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="money-bill-wave" />
          Historial de Pagos AS/400
          <span class="badge-purple" v-if="pagos.length > 0">{{ pagos.length }} pagos</span>
        </h5>
        <button
          class="btn-municipal-secondary btn-sm"
          @click="loadPagos"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Folio</th>
                <th>Concepto</th>
                <th>Fecha Pago</th>
                <th>Periodo</th>
                <th>Importe</th>
                <th>Forma Pago</th>
                <th>Referencia</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagos" :key="pago.folio" class="clickable-row">
                <td><code class="text-primary">{{ pago.folio?.trim() }}</code></td>
                <td>{{ pago.concepto?.trim() || 'N/A' }}</td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(pago.fecha_pago) }}
                  </small>
                </td>
                <td>{{ pago.periodo?.trim() || 'N/A' }}</td>
                <td>
                  <strong class="text-success">
                    <font-awesome-icon icon="dollar-sign" />
                    {{ formatCurrency(pago.importe) }}
                  </strong>
                </td>
                <td>
                  <span class="badge-secondary">
                    {{ pago.forma_pago?.trim() || 'N/A' }}
                  </span>
                </td>
                <td><code class="text-muted">{{ pago.referencia?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr v-if="pagos.length === 0">
                <td colspan="7" class="text-center text-muted">
                  <font-awesome-icon icon="folder-open" size="2x" class="empty-icon" />
                  <p>No hay historial de pagos para esta licencia</p>
                </td>
              </tr>
            </tbody>
            <tfoot v-if="pagos.length > 0" class="municipal-table-footer">
              <tr>
                <td colspan="4" class="text-right"><strong>Total Pagado:</strong></td>
                <td colspan="3">
                  <strong class="text-success">
                    <font-awesome-icon icon="dollar-sign" />
                    {{ formatCurrency(totalPagos) }}
                  </strong>
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && !licenciaInfo" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Consultando sistema AS/400...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'consLic400frm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
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
const licenciaInfo = ref(null)
const pagos = ref([])

// Filtros
const filters = ref({
  numeroLicencia: ''
})

// Computed
const totalPagos = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (parseFloat(pago.importe) || 0), 0)
})

// Métodos
const searchLicencia = async () => {
  if (!filters.value.numeroLicencia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese un número de licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Consultando licencia en AS/400...')

  try {
    const response = await execute(
      'sp_cons_lic_400_frm_get_lic_400',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaInfo.value = response.result[0]
      await loadPagos()
      showToast('success', 'Licencia encontrada en AS/400')
    } else {
      licenciaInfo.value = null
      pagos.value = []
      await Swal.fire({
        icon: 'error',
        title: 'Licencia no encontrada',
        text: 'No se encontró la licencia especificada en el sistema AS/400',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    licenciaInfo.value = null
    pagos.value = []
  } finally {
    setLoading(false)
  }
}

const loadPagos = async () => {
  if (!filters.value.numeroLicencia) return

  setLoading(true, 'Cargando historial de pagos...')

  try {
    const response = await execute(
      'sp_cons_lic_400_frm_get_pago_lic_400',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: filters.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      pagos.value = response.result
      showToast('success', 'Historial de pagos cargado correctamente')
    } else {
      pagos.value = []
    }
  } catch (error) {
    handleApiError(error)
    pagos.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    numeroLicencia: ''
  }
  licenciaInfo.value = null
  pagos.value = []
}

// Utilidades
const getStatusBadgeClass = (estatus) => {
  const classes = {
    'Vigente': 'badge-success',
    'Vencida': 'badge-danger',
    'Suspendida': 'badge-warning',
    'Cancelada': 'badge-secondary',
    'Baja': 'badge-danger'
  }
  return classes[estatus] || 'badge-secondary'
}

const getStatusIcon = (estatus) => {
  const icons = {
    'Vigente': 'check-circle',
    'Vencida': 'times-circle',
    'Suspendida': 'pause-circle',
    'Cancelada': 'ban',
    'Baja': 'times-circle'
  }
  return icons[estatus] || 'info-circle'
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
  } catch {
    return 'Fecha inválida'
  }
}

const formatCurrency = (amount) => {
  if (amount === null || amount === undefined) return '$0.00'
  const numAmount = parseFloat(amount)
  if (isNaN(numAmount)) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(numAmount)
}

// Lifecycle
onMounted(() => {
  // Componente listo
})

onBeforeUnmount(() => {
  // Limpieza si es necesario
})
</script>
