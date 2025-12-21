<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Padrón de Energía Eléctrica</h1>
        <p>Mercados - Consulta de locales con registro de consumo eléctrico</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
        <form @submit.prevent="buscarPadron">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina Recaudadora</label>
              <select
                v-model="form.recaudadora_id"
                class="municipal-form-control"
                @change="onRecaudadoraChange"
                required
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="rec in recaudadoras"
                  :key="rec.id_rec"
                  :value="rec.id_rec"
                >
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado</label>
              <select
                v-model="form.mercado_id"
                class="municipal-form-control"
                :disabled="!form.recaudadora_id"
                required
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="merc in mercados"
                  :key="merc.num_mercado_nvo"
                  :value="merc.num_mercado_nvo"
                >
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button
                  type="submit"
                  class="btn-municipal-primary me-2"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="search" />
                  <span v-if="loading">Buscando...</span>
                  <span v-else>Buscar Padrón</span>
                </button>
                <button
                  type="button"
                  class="btn-municipal-purple"
                  @click="exportarExcel"
                  :disabled="padron.length === 0 || loading"
                >
                  <font-awesome-icon icon="file-excel" />
                  Exportar Excel
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Padrón de Energía - {{ mercadoSeleccionadoNombre }}
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="padron.length > 0">
            {{ padron.length }} locales
          </span>
        </div>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Rec.</th>
                <th>Merc.</th>
                <th>Cat.</th>
                <th>Sec.</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Bloque</th>
                <th>Descripción</th>
                <th>Adicionales</th>
                <th>Nombre</th>
                <th>Consumo</th>
                <th>Kilowhatts/Cuota</th>
                <th>Vigencia</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="padron.length === 0 && !searchExecuted">
                <td colspan="13" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>Selecciona una recaudadora y mercado para consultar el padrón de energía</p>
                </td>
              </tr>
              <tr v-else-if="padron.length === 0">
                <td colspan="13" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No se encontraron registros de energía para el mercado seleccionado</p>
                </td>
              </tr>
              <tr v-else v-for="(row, idx) in paginatedData" :key="`padron-${idx}`" class="row-hover">
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td><strong class="text-primary">{{ row.local }}</strong></td>
                <td>{{ row.letra_local || '-' }}</td>
                <td>{{ row.bloque || '-' }}</td>
                <td>{{ row.descripcion_local || '-' }}</td>
                <td>{{ row.local_adicional || '-' }}</td>
                <td>{{ row.nombre }}</td>
                <td><span class="badge badge-secondary">{{ row.cve_consumo }}</span></td>
                <td class="text-end">{{ row.cantidad }}</td>
                <td>
                  <span class="badge" :class="row.vigencia === 'A' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="row.vigencia === 'A' ? 'check-circle' : 'times-circle'" />
                    {{ row.vigencia === 'A' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Controles de paginación -->
        <div v-if="padron.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, padron.length) }}
              de {{ padron.length }} registros
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
      </div>
    </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import axios from 'axios'
import { useToast } from '@/composables/useToast'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showToast } = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado reactivo
const recaudadoras = ref([])
const mercados = ref([])
const padron = ref([])
const loading = ref(false)
const searchExecuted = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const form = ref({
  recaudadora_id: '',
  mercado_id: ''
})

// Computed para mostrar nombre del mercado en header
const mercadoSeleccionadoNombre = computed(() => {
  if (!form.value.mercado_id || mercados.value.length === 0) return ''
  const mercado = mercados.value.find(m => m.num_mercado_nvo == form.value.mercado_id)
  return mercado ? `${mercado.num_mercado_nvo} - ${mercado.descripcion}` : ''
})

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(padron.value.length / itemsPerPage.value)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return padron.value.slice(start, end)
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

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
}

// Inicializar
onMounted(async () => {
  showLoading('Cargando Padrón de Energía', 'Preparando oficinas recaudadoras...')
  try {
    await fetchRecaudadoras()
  } finally {
    hideLoading()
  }
})

// Cargar catálogo de recaudadoras
const fetchRecaudadoras = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      recaudadoras.value = data
    } else if (apiResponse.success === false) {
      showToast(apiResponse.message || 'Error al cargar recaudadoras', 'error')
      recaudadoras.value = []
    } else {
      recaudadoras.value = []
      showToast('No se encontraron recaudadoras', 'warning')
    }
  } catch (error) {
    console.error('Error fetchRecaudadoras:', error)
    showToast('Error al cargar recaudadoras: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

// Evento cuando cambia la recaudadora
const onRecaudadoraChange = async () => {
  console.log('Recaudadora changed to:', form.value)
  form.value.mercado_id = ''
  mercados.value = []
  searchExecuted.value = false
  padron.value = []

  if (!form.value.recaudadora_id) return

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_recaudadora_id', Valor: parseInt(form.value.recaudadora_id) }
        ]
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      mercados.value = data
    } else if (apiResponse.success === false) {
      showToast(apiResponse.message || 'Error al cargar mercados', 'error')
      mercados.value = []
    } else {
      mercados.value = []
      showToast('No hay mercados para esta recaudadora', 'warning')
    }
  } catch (error) {
    console.error('Error onRecaudadoraChange:', error)
    showToast('Error al cargar mercados: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

// Buscar padrón de energía
const buscarPadron = async () => {
  if (!form.value.recaudadora_id || !form.value.mercado_id) {
    showToast('Debe seleccionar recaudadora y mercado', 'warning')
    return
  }

  loading.value = true
  padron.value = []
  searchExecuted.value = true

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'rpt_padron_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.recaudadora_id) },
          { Nombre: 'p_mercado', Valor: parseInt(form.value.mercado_id) }
        ]
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      padron.value = data
      currentPage.value = 1 // Resetear a la primera página
      showToast(`Se encontraron ${padron.value.length} locales con energía`, 'success')
    } else if (apiResponse.success === false) {
      showToast(apiResponse.message || 'Error al buscar padrón de energía', 'error')
      padron.value = []
    } else {
      padron.value = []
      showToast('No se encontraron registros de energía para este mercado', 'info')
    }
  } catch (error) {
    console.error('Error buscarPadron:', error)
    showToast('Error al buscar padrón: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

// Exportar a Excel
const exportarExcel = () => {
  if (padron.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    // Crear CSV manualmente
    const headers = [
      'Rec.', 'Merc.', 'Cat.', 'Sec.', 'Local', 'Letra', 'Bloque',
      'Descripción', 'Adicionales', 'Nombre', 'Consumo', 'Kilowhatts/Cuota', 'Vigencia'
    ]

    const rows = padron.value.map(row => [
      row.oficina,
      row.num_mercado,
      row.categoria,
      row.seccion,
      row.local,
      row.letra_local || '',
      row.bloque || '',
      row.descripcion_local || '',
      row.local_adicional || '',
      row.nombre,
      row.cve_consumo,
      row.cantidad,
      row.vigencia
    ])

    const csv = [
      headers.join(','),
      ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
    ].join('\n')

    // Crear blob y descargar
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    const url = URL.createObjectURL(blob)

    link.setAttribute('href', url)
    link.setAttribute('download', `padron_energia_mercado_${form.value.mercado_id}_${Date.now()}.csv`)
    link.style.visibility = 'hidden'

    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    showToast('Archivo exportado correctamente', 'success')
  } catch (error) {
    console.error('Error exportarExcel:', error)
    showToast('Error al exportar: ' + error.message, 'error')
  }
}
</script>

<style src="@/styles/municipal-theme.css"></style>
