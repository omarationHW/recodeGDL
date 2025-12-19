<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Locales</h1>
        <p>Inicio > Mercados > Emisión de Recibos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="previsualizar" :disabled="loading">
          <font-awesome-icon icon="search" /> Previsualizar
        </button>
        <button class="btn-municipal-primary" @click="emitirRecibos" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-invoice-dollar" /> Emitir Recibos
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select v-model="filters.oficina" class="municipal-form-control" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select v-model="filters.mercado" class="municipal-form-control" :disabled="loading || !mercados.length">
                <option value="">Seleccione...</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control"
                     min="1990" :max="new Date().getFullYear() + 1" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <select v-model.number="filters.periodo" class="municipal-form-control" :disabled="loading">
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Recibos a Emitir</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} locales</span>
            <span class="badge-success ms-2">Total Adeudo: {{ formatCurrency(totalAdeudo) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Datos del Local</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Adeudo</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Subtotal</th>
                  <th>Meses Adeudados</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedResults" :key="row.id_local" class="row-hover">
                  <td>{{ datosLocal(row) }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion_local }}</td>
                  <td class="text-end">{{ formatNumber(row.superficie) }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta) }}</td>
                  <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                  <td class="text-end">{{ formatCurrency(row.recargos) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.subtotal) }}</strong></td>
                  <td>{{ row.meses || 'N/A' }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="7" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalAdeudo) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="results.length > 0" class="pagination-controls">
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
                style="width: auto; display: inline-block;">
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button v-for="page in visiblePages" :key="page" class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)">
                {{ page }}
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="!results.length && !loading && busquedaRealizada" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron locales para emitir recibos con los filtros seleccionados.
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
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()

const filters = ref({
  oficina: '',
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1
})

const recaudadoras = ref([])
const mercados = ref([])
const results = ref([])
const loading = ref(false)
const busquedaRealizada = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
])

const totalRecords = computed(() => results.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return results.value.slice(start, end)
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

const totalAdeudo = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.subtotal) || 0), 0))

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

const fetchRecaudadoras = async () => {
  try {
    showLoading('Cargando recaudadoras...', 'Por favor espere')
    const response = await execute(
      'sp_get_recaudadoras',
      'mercados',
      [],
      'guadalajara',
      null,
      ''
    )
    if (response && response.result) {
      recaudadoras.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error)
    handleApiError(error, 'Error al cargar recaudadoras')
  } finally {
    hideLoading()
  }
}

const onOficinaChange = async () => {
  filters.value.mercado = ''
  mercados.value = []
  if (!filters.value.oficina) return

  try {
    showLoading('Cargando mercados...', 'Por favor espere')
    const response = await execute(
      'sp_get_mercados_by_recaudadora',
      'padron_licencias',
      [{ nombre: 'p_id_rec', valor: parseInt(filters.value.oficina), tipo: 'integer' }],
      'guadalajara',
      null,
      ''
    )
    if (response && response.result) {
      mercados.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error)
    handleApiError(error, 'Error al cargar mercados')
  } finally {
    hideLoading()
  }
}

const previsualizar = async () => {
  if (!filters.value.oficina || !filters.value.mercado) {
    showToast('Por favor complete todos los filtros requeridos', 'warning')
    return
  }

  showLoading('Consultando locales...', 'Por favor espere')
  loading.value = true
  busquedaRealizada.value = false

  try {
    const response = await execute(
      'sp_rpt_emision_locales_get',
      'mercados',
      [
        { nombre: 'p_oficina', valor: parseInt(filters.value.oficina), tipo: 'integer' },
        { nombre: 'p_axo', valor: parseInt(filters.value.axo), tipo: 'integer' },
        { nombre: 'p_periodo', valor: parseInt(filters.value.periodo), tipo: 'integer' },
        { nombre: 'p_mercado', valor: parseInt(filters.value.mercado), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      ''
    )

    if (response && response.result) {
      results.value = response.result
      busquedaRealizada.value = true
      currentPage.value = 1
      showToast(`Se encontraron ${results.value.length} locales`, 'success')
    } else {
      results.value = []
      busquedaRealizada.value = true
      showToast('No se encontraron locales para emitir', 'info')
    }
  } catch (error) {
    console.error('Error al consultar:', error)
    handleApiError(error, 'Error al consultar locales')
    results.value = []
    busquedaRealizada.value = true
  } finally {
    loading.value = false
    hideLoading()
  }
}

const emitirRecibos = async () => {
  if (!results.value.length) {
    showToast('No hay recibos para emitir', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar emisión de recibos?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se emitirán <strong>${results.value.length}</strong> recibos.</p>
        <p><strong>Total a facturar:</strong> ${formatCurrency(totalAdeudo.value)}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, emitir recibos',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Emitiendo recibos...', 'Por favor espere')
  loading.value = true

  try {
    const response = await execute(
      'sp_rpt_emision_locales_emit',
      'mercados',
      [
        { nombre: 'p_oficina', valor: parseInt(filters.value.oficina), tipo: 'integer' },
        { nombre: 'p_axo', valor: parseInt(filters.value.axo), tipo: 'integer' },
        { nombre: 'p_periodo', valor: parseInt(filters.value.periodo), tipo: 'integer' },
        { nombre: 'p_mercado', valor: parseInt(filters.value.mercado), tipo: 'integer' },
        { nombre: 'p_usuario_id', valor: 1, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      ''
    )

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: '¡Recibos emitidos!',
        text: 'Los recibos fueron emitidos correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('Recibos emitidos correctamente', 'success')
      await previsualizar()
    } else {
      throw new Error('Error en la emisión')
    }
  } catch (error) {
    console.error('Error al emitir recibos:', error)
    handleApiError(error, 'Error al emitir recibos')
    await Swal.fire({
      icon: 'error',
      title: 'Error al emitir',
      text: 'No se pudieron emitir los recibos',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
    hideLoading()
  }
}

const datosLocal = (row) => {
  return `${row.oficina}-${row.num_mercado}-${row.categoria}-${row.seccion}-${row.local}${row.letra_local || ''}${row.bloque ? '-' + row.bloque : ''}`
}

const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  if (value == null) return '0'
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value)
}

const mostrarAyuda = () => {
  Swal.fire({
    icon: 'info',
    title: 'Emisión de Recibos de Locales',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p>Seleccione la recaudadora, mercado, año y periodo para previsualizar los recibos a emitir.</p>
        <p>Luego haga clic en <strong>"Emitir Recibos"</strong> para generar los recibos.</p>
      </div>
    `,
    confirmButtonColor: '#ea8215'
  })
}

onMounted(() => {
  fetchRecaudadoras()
})
</script>
