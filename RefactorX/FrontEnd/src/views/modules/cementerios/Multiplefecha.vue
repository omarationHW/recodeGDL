<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos por Fecha</h1>
        <p>Cementerios - Búsqueda de pagos por fecha, recibo y caja</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Criterios de Búsqueda
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha de Ingreso</label>
            <input
              v-model="filtros.fecha"
              type="date"
              class="municipal-form-control"
              @keyup.enter="buscarPagos"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Recibo</label>
            <input
              v-model.number="filtros.recibo"
              type="number"
              class="municipal-form-control"
              min="1"
              @keyup.enter="buscarPagos"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Caja</label>
            <input
              v-model="filtros.caja"
              type="text"
              class="municipal-form-control"
              maxlength="1"
              @keyup.enter="buscarPagos"
            />
          </div>
        </div>
        <div class="form-actions">
          <button @click="buscarPagos" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar Pagos
          </button>
          <button @click="limpiarFiltros" class="btn-municipal-secondary">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="pagos.length > 0" class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Pagos Encontrados
        </h5>
        <div class="header-right">
          <span class="badge-purple">
            {{ formatNumber(totalRecords) }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Folio</th>
                <th>Ubicación</th>
                <th>Fecha Ingreso</th>
                <th>Recibo</th>
                <th>Caja</th>
                <th>Años Pago</th>
                <th>Importe Anual</th>
                <th>Recargos</th>
                <th>Vigencia</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in paginatedPagos" :key="`${pago.control_id}-${pago.control_rcm}`" class="row-hover">
                <td><strong class="text-primary">{{ pago.control_rcm }}</strong></td>
                <td><small>{{ formatearUbicacion(pago) }}</small></td>
                <td><small>{{ formatearFecha(pago.fecing) }}</small></td>
                <td>{{ pago.recing }}</td>
                <td>{{ pago.cajing }}</td>
                <td><small>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</small></td>
                <td><strong>{{ formatearMoneda(pago.importe_anual) }}</strong></td>
                <td><strong>{{ formatearMoneda(pago.importe_recargos) }}</strong></td>
                <td>
                  <span class="badge" :class="getBadgeVigencia(pago.vigencia)">
                    {{ getTextoVigencia(pago.vigencia) }}
                  </span>
                </td>
                <td>
                  <button
                    @click="verDetalleFolio(pago.control_rcm)"
                    class="btn-municipal-secondary btn-sm"
                    title="Ver detalle del folio"
                  >
                    <font-awesome-icon icon="eye" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Controles de Paginación -->
        <div v-if="pagos.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ totalRecords }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="itemsPerPage"
              @change="changePageSize($event.target.value)"
              style="width: auto; display: inline-block;"
            >
              <option value="5">5</option>
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(1)"
              :disabled="currentPage === 1"
              title="Primera página"
            >
              <font-awesome-icon icon="angle-double-left" />
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(currentPage - 1)"
              :disabled="currentPage === 1"
              title="Página anterior"
            >
              <font-awesome-icon icon="angle-left" />
            </button>

            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(currentPage + 1)"
              :disabled="currentPage === totalPages"
              title="Página siguiente"
            >
              <font-awesome-icon icon="angle-right" />
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(totalPages)"
              :disabled="currentPage === totalPages"
              title="Última página"
            >
              <font-awesome-icon icon="angle-double-right" />
            </button>
          </div>
        </div>

        <!-- Resumen -->
        <div class="summary-grid mt-3">
          <div class="summary-card">
            <div class="summary-info">
              <div class="summary-label">Total de Pagos</div>
              <div class="summary-value">{{ pagos.length }}</div>
            </div>
          </div>
          <div class="summary-card">
            <div class="summary-info">
              <div class="summary-label">Total Anual</div>
              <div class="summary-value">{{ formatearMoneda(totalAnual) }}</div>
            </div>
          </div>
          <div class="summary-card">
            <div class="summary-info">
              <div class="summary-label">Total Recargos</div>
              <div class="summary-value">{{ formatearMoneda(totalRecargos) }}</div>
            </div>
          </div>
          <div class="summary-card">
            <div class="summary-info">
              <div class="summary-label">Total General</div>
              <div class="summary-value" style="color: var(--municipal-primary);">{{ formatearMoneda(totalGeneral) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron pagos con los criterios especificados
    </div>

    <!-- Modal de detalle (placeholder) -->
    <div v-if="folioSeleccionado" class="modal-backdrop show" @click="cerrarDetalle">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>
            <font-awesome-icon icon="file-alt" />
            Detalle del Folio {{ folioSeleccionado }}
          </h3>
          <button @click="cerrarDetalle" class="btn-close">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="alert-info">
            <font-awesome-icon icon="info-circle" />
            El detalle completo del folio se implementará en el componente ConIndividual
          </div>
          <p><strong>Folio:</strong> {{ folioSeleccionado }}</p>
          <p>Aquí se mostrará la información detallada del folio, incluyendo datos del titular, ubicación completa y todos los pagos asociados.</p>
        </div>
        <div class="modal-footer">
          <button @click="cerrarDetalle" class="btn-municipal-secondary">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Multiplefecha'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Modal de documentación
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => pagos.value.length)

const filtros = reactive({
  fecha: '',
  recibo: 1,
  caja: 'A'
})

const pagos = ref([])
const busquedaRealizada = ref(false)
const folioSeleccionado = ref(null)

const totalAnual = computed(() => {
  return pagos.value.reduce((sum, pago) => {
    const importe = parseFloat(pago.importe_anual)
    return sum + (isNaN(importe) ? 0 : importe)
  }, 0)
})

const totalRecargos = computed(() => {
  return pagos.value.reduce((sum, pago) => {
    const recargos = parseFloat(pago.importe_recargos)
    return sum + (isNaN(recargos) ? 0 : recargos)
  }, 0)
})

const totalGeneral = computed(() => {
  return totalAnual.value + totalRecargos.value
})

const buscarPagos = async () => {
  if (!filtros.fecha) {
    showToast('warning', 'Seleccione una fecha')
    return
  }
  if (!filtros.recibo || filtros.recibo < 1) {
    showToast('warning', 'Ingrese un número de recibo válido')
    return
  }
  if (!filtros.caja || filtros.caja.trim() === '') {
    showToast('warning', 'Ingrese una caja')
    return
  }

  showLoading('Buscando pagos...', 'Por favor espere')
  currentPage.value = 1

  try {
    /* TODO FUTURO: Query SQL original (Multiplefecha.dfm líneas 738-749):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select 'Manten' tipopag,*,' ' obser
    --       from ta_13_pagosrcm where fecing=:fecha and
    --       recing>=:rec and cajing>=:caja
    --       union
    --       SELECT 'Titulo',fecha, id_rec, caja, operacion, 0,control_rcm,
    --              '',0,'',0,'',0,'',0,'', tipo, titulo,   importe, 0,'',0,today,'observaciones
    --           FROM ta_13_titulos  where fecha=:fecha and
    --        id_rec>=:rec and caja>=:caja
    --       order by 2,3,4,5'
    -- Parámetros Pascal (líneas 78-81):
    --   :fecha = ExDateTPFecha.Date (fecha seleccionada)
    --   :rec = FlatSpinEIRec.Value (default: 1)
    --   :caja = FlatECaja.Text (default: 'A')
    -- FormShow (líneas 101-105): Carga inicial con fecha actual, rec=1, caja='A'
    */

    const response = await execute(
      'sp_multiplefecha_buscar_por_fecha',
      'cementerio',
      [
        { nombre: 'p_fecha', valor: filtros.fecha, tipo: 'date' },
        { nombre: 'p_recibo', valor: filtros.recibo, tipo: 'smallint' },
        { nombre: 'p_caja', valor: filtros.caja.toUpperCase(), tipo: 'varchar' }
      ],
      'function',
      null,
      'public'
    )

    if(response?.result?.length > 0) {
      pagos.value = response.result
    } else {
      pagos.value = []
    }
    busquedaRealizada.value = true

    if (pagos.value.length === 0) {
      showToast('info', 'No existe Registro con esos Datos')
    } else {
      showToast('success', `Se encontraron ${pagos.value.length} pago(s)`)
    }
  } catch (error) {
    console.error('Error al buscar pagos:', error)
    showToast('error', 'Error al buscar pagos: ' + error.message)
    pagos.value = []
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.fecha = new Date().toISOString().split('T')[0]
  filtros.recibo = 1
  filtros.caja = 'A'
  pagos.value = []
  busquedaRealizada.value = false
  folioSeleccionado.value = null
}

const verDetalleFolio = (controlRcm) => {
  folioSeleccionado.value = controlRcm
  // TODO: Integrar con componente ConIndividual cuando esté disponible
}

const cerrarDetalle = () => {
  folioSeleccionado.value = null
}

const formatearUbicacion = (pago) => {
  const partes = []
  partes.push(`Cl:${pago.clase}${pago.clase_alfa || ''}`)
  partes.push(`Sec:${pago.seccion}${pago.seccion_alfa || ''}`)
  partes.push(`Lin:${pago.linea}${pago.linea_alfa || ''}`)
  partes.push(`Fosa:${pago.fosa}${pago.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (valor == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(valor)
}

const getBadgeVigencia = (vigencia) => {
  switch (vigencia) {
    case 'V':
    case 'A':
      return 'badge-success'
    case 'C':
      return 'badge-danger'
    default:
      return 'badge-secondary'
  }
}

const getTextoVigencia = (vigencia) => {
  switch (vigencia) {
    case 'V':
      return 'Vigente'
    case 'A':
      return 'Activo'
    case 'C':
      return 'Cancelado'
    default:
      return vigencia || 'N/A'
  }
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedPagos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return pagos.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

onMounted(() => {
  // Inicializar con fecha actual
  filtros.fecha = new Date().toISOString().split('T')[0]
})
</script>
