<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Anuncios AS/400</h1>
        <p>Padrón de Licencias - Consulta de Datos Históricos de Anuncios del Sistema AS/400</p>
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

    <!-- Mensaje informativo -->
    <div class="alert-info">
      <font-awesome-icon icon="info-circle" />
      <strong>Sistema Legacy AS/400:</strong> Esta consulta muestra información histórica de anuncios del sistema anterior. Los datos son de solo lectura y se mantienen para referencia.
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Anuncio</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.numeroAnuncio"
              placeholder="Ingrese número de anuncio"
              @keyup.enter="searchAnuncio"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchAnuncio"
          >
            <font-awesome-icon icon="search" />
            Buscar
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

    <!-- Información del anuncio -->
    <div class="municipal-card" v-if="anuncioInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="bullhorn" />
          Información del Anuncio AS/400
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
                <td class="label">Número de Anuncio:</td>
                <td><code class="text-primary">{{ anuncioInfo.numero_anuncio?.trim() }}</code></td>
              </tr>
              <tr>
                <td class="label">Contribuyente:</td>
                <td><strong>{{ anuncioInfo.contribuyente?.trim() || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ anuncioInfo.rfc?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Tipo Anuncio:</td>
                <td>
                  <span class="badge-purple">
                    {{ anuncioInfo.tipo_anuncio?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Licencia Asociada:</td>
                <td><code>{{ anuncioInfo.numero_licencia?.trim() || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="ruler-combined" />
              Características
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ anuncioInfo.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Dimensiones:</td>
                <td>{{ anuncioInfo.dimensiones?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Área M²:</td>
                <td><strong>{{ anuncioInfo.area_m2 || '0' }} m²</strong></td>
              </tr>
              <tr>
                <td class="label">Material:</td>
                <td>{{ anuncioInfo.material?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Iluminación:</td>
                <td>
                  <span class="badge" :class="anuncioInfo.iluminado ? 'badge-success' : 'badge-secondary'">
                    <font-awesome-icon :icon="anuncioInfo.iluminado ? 'lightbulb' : 'times'" />
                    {{ anuncioInfo.iluminado ? 'Iluminado' : 'No Iluminado' }}
                  </span>
                </td>
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
                <td>{{ anuncioInfo.domicilio?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ anuncioInfo.colonia?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td><code>{{ anuncioInfo.cp?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>
                  <span class="badge-secondary">
                    Zona {{ anuncioInfo.zona || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Ubicación Específica:</td>
                <td>{{ anuncioInfo.ubicacion_especifica?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Fechas y Estado
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Autorización:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(anuncioInfo.fecha_autorizacion) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Vigencia:</td>
                <td>
                  <font-awesome-icon icon="calendar-check" class="text-info" />
                  {{ formatDate(anuncioInfo.fecha_vigencia) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Baja:</td>
                <td>
                  <font-awesome-icon icon="calendar-minus" class="text-danger" />
                  {{ formatDate(anuncioInfo.fecha_baja) }}
                </td>
              </tr>
              <tr>
                <td class="label">Estatus:</td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(anuncioInfo.estatus)">
                    <font-awesome-icon :icon="getStatusIcon(anuncioInfo.estatus)" />
                    {{ anuncioInfo.estatus?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Observaciones:</td>
                <td>{{ anuncioInfo.observaciones?.trim() || 'Sin observaciones' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de pagos -->
    <div class="municipal-card" v-if="anuncioInfo">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="money-bill-wave" />
          Historial de Pagos AS/400
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="pagos.length > 0">{{ pagos.length }} pagos</span>
          <button
            class="btn-municipal-secondary btn-sm"
            @click="loadPagos"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>

      <div class="municipal-card-body table-container">
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
              <tr
                v-for="pago in pagos"
                :key="pago.folio"
                @click="selectedRow = pago"
                :class="{ 'table-row-selected': selectedRow === pago }"
                class="row-hover"
              >
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
                  <p>No hay historial de pagos para este anuncio</p>
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
      :componentName="'consAnun400frm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Consulta de Anuncios AS/400'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
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

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const anuncioInfo = ref(null)
const pagos = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros
const filters = ref({
  numeroAnuncio: ''
})

// Computed
const totalPagos = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (parseFloat(pago.importe) || 0), 0)
})

// Métodos
const searchAnuncio = async () => {
  if (!filters.value.numeroAnuncio) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese un número de anuncio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Consultando anuncio en AS/400...', 'Recuperando información histórica')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const response = await execute(
      'sp_cons_anun_400_frm_get_anuncio_400',
      'padron_licencias',
      [
        { nombre: 'p_numero_anuncio', valor: filters.value.numeroAnuncio, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      anuncioInfo.value = response.result[0]
      await loadPagos()
      showToast('success', 'Anuncio encontrado en AS/400')
    } else {
      anuncioInfo.value = null
      pagos.value = []
      await Swal.fire({
        icon: 'error',
        title: 'Anuncio no encontrado',
        text: 'No se encontró el anuncio especificado en el sistema AS/400',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    anuncioInfo.value = null
    pagos.value = []
  } finally {
    hideLoading()
  }
}

const loadPagos = async () => {
  if (!filters.value.numeroAnuncio) return

  showLoading('Cargando historial de pagos...', 'Recuperando información de pagos')

  try {
    const response = await execute(
      'sp_cons_anun_400_frm_get_pagos_anun_400',
      'padron_licencias',
      [
        { nombre: 'p_numero_anuncio', valor: filters.value.numeroAnuncio, tipo: 'string' }
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
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    numeroAnuncio: ''
  }
  anuncioInfo.value = null
  pagos.value = []
  hasSearched.value = false
  selectedRow.value = null
}

// Utilidades
const getStatusBadgeClass = (estatus) => {
  const classes = {
    'Vigente': 'badge-success',
    'Vencida': 'badge-danger',
    'Suspendida': 'badge-warning',
    'Cancelada': 'badge-secondary',
    'Baja': 'badge-danger',
    'Autorizado': 'badge-success',
    'Rechazado': 'badge-danger'
  }
  return classes[estatus] || 'badge-secondary'
}

const getStatusIcon = (estatus) => {
  const icons = {
    'Vigente': 'check-circle',
    'Vencida': 'times-circle',
    'Suspendida': 'pause-circle',
    'Cancelada': 'ban',
    'Baja': 'times-circle',
    'Autorizado': 'check-circle',
    'Rechazado': 'times-circle'
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
