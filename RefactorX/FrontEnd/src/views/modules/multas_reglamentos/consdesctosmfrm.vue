<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list-alt" /></div>
      <div class="module-view-info">
        <h1>Consulta Descuentos Multas</h1>
        <p>Multas y Reglamentos - Consulta de Descuentos Aplicados a Multas</p>
      </div>
      <div class="button-group ms-auto">
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
                <option value="">Todos</option>
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
          <h5><font-awesome-icon icon="table" /> Descuentos Registrados</h5>
          <span v-if="descuentos.length > 0" class="badge badge-primary">{{ descuentos.length }} registros</span>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione criterios de busqueda</p>
            </div>
          </div>

          <div v-else-if="descuentos.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron descuentos</p>
            </div>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Folio</th>
                  <th>Fecha Alta</th>
                  <th>Multa</th>
                  <th>Porcentaje</th>
                  <th class="text-end">Importe</th>
                  <th>Funcionario</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="desc in descuentos" :key="desc.id_descto">
                  <td><strong class="text-primary">{{ desc.folio }}</strong></td>
                  <td>{{ formatDate(desc.fecha_alta) }}</td>
                  <td>{{ desc.folio_multa }}</td>
                  <td>{{ desc.porcentaje }}%</td>
                  <td class="text-end">{{ formatCurrency(desc.importe) }}</td>
                  <td>{{ desc.funcionario || 'N/A' }}</td>
                  <td>
                    <span class="badge" :class="getBadgeClass(desc.vigencia)">
                      {{ getEstadoText(desc.vigencia) }}
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="descuentos.length > 0">
                <tr>
                  <td colspan="4" class="text-end"><strong>Total:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                  <td colspan="2"></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <DocumentationModal :show="showDocModal" :componentName="'consdesctosmfrm'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Consulta Descuentos Multas'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const descuentos = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const today = new Date().toISOString().split('T')[0]
const firstDayOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]
const filters = ref({ fechaInicio: firstDayOfMonth, fechaFin: today, vigencia: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const totalImporte = computed(() => {
  return descuentos.value.reduce((sum, d) => sum + (parseFloat(d.importe) || 0), 0)
})

const buscar = async () => {
  showLoading('Buscando descuentos...', 'Consultando base de datos')
  searchPerformed.value = true

  try {
    const response = await execute('sp_consdesctosmultas_lista', 'multas_reglamentos',
      [
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin, tipo: 'date' },
        { nombre: 'p_vigencia', valor: filters.value.vigencia || null, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    descuentos.value = response?.result || []
    showToast(descuentos.value.length > 0 ? 'success' : 'info',
      descuentos.value.length > 0 ? `${descuentos.value.length} descuentos encontrados` : 'No se encontraron descuentos')
  } catch (error) {
    handleApiError(error, 'Error al buscar descuentos')
    descuentos.value = []
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { fechaInicio: firstDayOfMonth, fechaFin: today, vigencia: '' }
  descuentos.value = []
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
