<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-tie" /></div>
      <div class="module-view-info">
        <h1>Diferencias por Cobrar por Perito</h1>
        <p>Multas y Reglamentos - Reporte de Diferencias Agrupadas por Perito Valuador</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-success" @click="generarReporte" :disabled="loading || peritos.length === 0">
          <font-awesome-icon icon="file-pdf" /> Generar Reporte
        </button>
        <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" /> Filtros de Busqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Inicial</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaInicio" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Final</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaFin" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Estado</label>
              <select class="municipal-form-control" v-model="filters.vigencia">
                <option value="V">Vigente</option>
                <option value="P">Pagado</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="users" /> Peritos con Diferencias</h5>
          <span v-if="peritos.length > 0" class="badge badge-primary">{{ peritos.length }} peritos</span>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione el rango de fechas y estado</p>
            </div>
          </div>

          <div v-else-if="peritos.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron diferencias en el periodo</p>
            </div>
          </div>

          <div v-else>
            <div class="table-responsive mb-4">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>
                      <input type="checkbox" @change="toggleSelectAll" :checked="allSelected" />
                    </th>
                    <th>No. Perito</th>
                    <th>Nombre del Perito</th>
                    <th class="text-end">Total Diferencias</th>
                    <th class="text-center">Casos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="perito in peritos" :key="perito.noperito"
                      @click="toggleSelect(perito)"
                      :class="{ 'table-active': perito.selected }"
                      style="cursor: pointer;">
                    <td @click.stop>
                      <input type="checkbox" v-model="perito.selected" />
                    </td>
                    <td><strong class="text-primary">{{ perito.noperito }}</strong></td>
                    <td>{{ perito.nom }}</td>
                    <td class="text-end">{{ formatCurrency(perito.difer) }}</td>
                    <td class="text-center">{{ perito.casos || '-' }}</td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="3" class="text-end"><strong>Total:</strong></td>
                    <td class="text-end"><strong>{{ formatCurrency(totalDiferencias) }}</strong></td>
                    <td></td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <div v-if="selectedPerito" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="list" /> Detalle - {{ selectedPerito.nom }}</h5>
              </div>
              <div class="municipal-card-body">
                <div v-if="loadingDetalle" class="text-center py-4">
                  <font-awesome-icon icon="spinner" spin size="2x" />
                  <p class="mt-2">Cargando detalle...</p>
                </div>
                <div v-else-if="detallePerito.length === 0" class="alert alert-info">
                  No hay detalle disponible
                </div>
                <div v-else class="table-responsive">
                  <table class="municipal-table table-sm">
                    <thead>
                      <tr>
                        <th>Folio</th>
                        <th>Cuenta</th>
                        <th>Fecha Alta</th>
                        <th class="text-end">Base</th>
                        <th class="text-end">Recargos</th>
                        <th class="text-end">Multas</th>
                        <th class="text-end">Total</th>
                        <th>Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="det in detallePerito" :key="det.id">
                        <td>{{ det.foliot }}</td>
                        <td>{{ det.cvecuenta }}</td>
                        <td>{{ formatDate(det.fecha_alta) }}</td>
                        <td class="text-end">{{ formatCurrency(det.importe_base) }}</td>
                        <td class="text-end">{{ formatCurrency(det.recargos) }}</td>
                        <td class="text-end">{{ formatCurrency(det.multas) }}</td>
                        <td class="text-end"><strong>{{ formatCurrency(det.total) }}</strong></td>
                        <td>
                          <span class="badge" :class="getBadgeClass(det.vigencia)">
                            {{ getEstadoText(det.vigencia) }}
                          </span>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <DocumentationModal :show="showDocModal" :componentName="'DifxCobPerito'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Diferencias por Cobrar por Perito'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const peritos = ref([])
const selectedPerito = ref(null)
const detallePerito = ref([])
const loadingDetalle = ref(false)
const showDocModal = ref(false)
const docType = ref('ayuda')

const today = new Date()
const thirtyDaysAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000)
const filters = ref({
  fechaInicio: thirtyDaysAgo.toISOString().split('T')[0],
  fechaFin: today.toISOString().split('T')[0],
  vigencia: 'V'
})

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const totalDiferencias = computed(() => {
  return peritos.value.reduce((sum, p) => sum + (parseFloat(p.difer) || 0), 0)
})

const allSelected = computed(() => {
  return peritos.value.length > 0 && peritos.value.every(p => p.selected)
})

const toggleSelectAll = (event) => {
  const checked = event.target.checked
  peritos.value.forEach(p => p.selected = checked)
}

const toggleSelect = (perito) => {
  perito.selected = !perito.selected
  if (perito.selected) {
    selectedPerito.value = perito
    cargarDetalle(perito.noperito)
  } else if (selectedPerito.value?.noperito === perito.noperito) {
    selectedPerito.value = null
    detallePerito.value = []
  }
}

const cargarDetalle = async (noperito) => {
  loadingDetalle.value = true
  try {
    const response = await execute('sp_difxcobperito_detalle', 'multas_reglamentos',
      [
        { nombre: 'p_noperito', valor: noperito, tipo: 'integer' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin, tipo: 'date' },
        { nombre: 'p_vigencia', valor: filters.value.vigencia, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    detallePerito.value = response?.result || []
  } catch (error) {
    console.error('Error cargando detalle:', error)
    detallePerito.value = []
  } finally {
    loadingDetalle.value = false
  }
}

const buscar = async () => {
  if (filters.value.fechaFin < filters.value.fechaInicio) {
    showToast('warning', 'La fecha final debe ser mayor o igual a la inicial')
    return
  }

  showLoading('Buscando diferencias...', 'Consultando base de datos')
  searchPerformed.value = true
  selectedPerito.value = null
  detallePerito.value = []

  try {
    const response = await execute('sp_difxcobperito_lista', 'multas_reglamentos',
      [
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin, tipo: 'date' },
        { nombre: 'p_vigencia', valor: filters.value.vigencia, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    peritos.value = (response?.result || []).map(p => ({ ...p, selected: false }))
    showToast(peritos.value.length > 0 ? 'success' : 'info',
      peritos.value.length > 0 ? `${peritos.value.length} peritos encontrados` : 'No se encontraron diferencias')
  } catch (error) {
    handleApiError(error, 'Error al buscar diferencias')
    peritos.value = []
  } finally {
    hideLoading()
  }
}

const generarReporte = async () => {
  const selected = peritos.value.filter(p => p.selected)
  if (selected.length === 0) {
    showToast('warning', 'Seleccione al menos un perito')
    return
  }

  await Swal.fire({
    icon: 'info',
    title: 'Generar Reporte',
    text: `Se generara reporte para ${selected.length} perito(s) seleccionado(s)`,
    confirmButtonColor: '#ea8215'
  })

  // Aqui iria la logica de generacion del reporte PDF
  showToast('success', 'Reporte generado correctamente')
}

const limpiar = () => {
  filters.value = {
    fechaInicio: thirtyDaysAgo.toISOString().split('T')[0],
    fechaFin: today.toISOString().split('T')[0],
    vigencia: 'V'
  }
  peritos.value = []
  selectedPerito.value = null
  detallePerito.value = []
  searchPerformed.value = false
}

const getBadgeClass = (vigencia) => {
  const classes = { V: 'badge-success', P: 'badge-info', C: 'badge-danger' }
  return classes[vigencia] || 'badge-secondary'
}

const getEstadoText = (vigencia) => {
  const estados = { V: 'Vigente', P: 'Pagado', C: 'Cancelado' }
  return estados[vigencia] || vigencia
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try { return new Date(dateString).toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' }) }
  catch { return 'N/A' }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}
</script>
