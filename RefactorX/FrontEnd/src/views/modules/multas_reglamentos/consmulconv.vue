<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="handshake" /></div>
      <div class="module-view-info">
        <h1>Consulta Multas con Convenio</h1>
        <p>Multas y Reglamentos - Consulta de Multas que tienen Convenio de Pago</p>
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
              <label class="municipal-form-label">Folio Multa</label>
              <input type="number" class="municipal-form-control" v-model="filters.folio" placeholder="Numero de folio" @keyup.enter="buscar" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Inicio Convenio</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaInicio" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin Convenio</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaFin" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Estado del Convenio</label>
              <select class="municipal-form-control" v-model="filters.estado">
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
          <h5><font-awesome-icon icon="table" /> Multas con Convenio</h5>
          <span v-if="convenios.length > 0" class="badge badge-primary">{{ convenios.length }} registros</span>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione criterios de busqueda</p>
            </div>
          </div>

          <div v-else-if="convenios.length === 0" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontraron multas con convenio</p>
            </div>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Folio Multa</th>
                  <th>Folio Convenio</th>
                  <th>Fecha Alta</th>
                  <th>Contribuyente</th>
                  <th class="text-end">Monto Total</th>
                  <th>Parcialidades</th>
                  <th class="text-end">Pagado</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="conv in convenios" :key="conv.id_convenio">
                  <td><strong class="text-primary">{{ conv.folio_multa }}</strong></td>
                  <td>{{ conv.folio_convenio }}</td>
                  <td>{{ formatDate(conv.fecha_alta) }}</td>
                  <td>{{ conv.contribuyente || 'N/A' }}</td>
                  <td class="text-end">{{ formatCurrency(conv.monto_total) }}</td>
                  <td class="text-center">{{ conv.parcialidades_pagadas }}/{{ conv.total_parcialidades }}</td>
                  <td class="text-end">{{ formatCurrency(conv.monto_pagado) }}</td>
                  <td>
                    <span class="badge" :class="getBadgeClass(conv.vigencia)">
                      {{ getEstadoText(conv.vigencia) }}
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="convenios.length > 0">
                <tr>
                  <td colspan="4" class="text-end"><strong>Totales:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalMonto) }}</strong></td>
                  <td></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalPagado) }}</strong></td>
                  <td></td>
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

    <DocumentationModal :show="showDocModal" :componentName="'consmulconv'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Consulta Multas con Convenio'" @close="showDocModal = false" />
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
const convenios = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ folio: '', fechaInicio: '', fechaFin: '', estado: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const totalMonto = computed(() => {
  return convenios.value.reduce((sum, c) => sum + (parseFloat(c.monto_total) || 0), 0)
})

const totalPagado = computed(() => {
  return convenios.value.reduce((sum, c) => sum + (parseFloat(c.monto_pagado) || 0), 0)
})

const buscar = async () => {
  showLoading('Buscando convenios...', 'Consultando base de datos')
  searchPerformed.value = true

  try {
    const response = await execute('sp_consmulconv_lista', 'multas_reglamentos',
      [
        { nombre: 'p_folio', valor: filters.value.folio ? parseInt(filters.value.folio) : null, tipo: 'integer' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' },
        { nombre: 'p_estado', valor: filters.value.estado || null, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    convenios.value = response?.result || []
    showToast(convenios.value.length > 0 ? 'success' : 'info',
      convenios.value.length > 0 ? `${convenios.value.length} convenios encontrados` : 'No se encontraron convenios')
  } catch (error) {
    handleApiError(error, 'Error al buscar convenios')
    convenios.value = []
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { folio: '', fechaInicio: '', fechaFin: '', estado: '' }
  convenios.value = []
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
