<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Padrón Global de Locales</h1>
        <p>Inicio > Mercados > Padrón Global</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Filtros de Consulta</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3 mb-3">
            <label class="municipal-form-label">Año</label>
            <input type="number" v-model.number="filters.axo" class="municipal-form-control" min="1995" max="3000" :disabled="loading" />
          </div>
          <div class="col-md-3 mb-3">
            <label class="municipal-form-label">Mes</label>
            <input type="number" v-model.number="filters.mes" class="municipal-form-control" min="1" max="12" :disabled="loading" />
          </div>
          <div class="col-md-4 mb-3">
            <label class="municipal-form-label">Estado del local</label>
            <select v-model="filters.vig" class="municipal-form-control" :disabled="loading">
              <option value="A">VIGENTES</option>
              <option value="B">CON BAJA TOTAL</option>
              <option value="C">CON BAJA POR ACUERDO</option>
              <option value="D">CON BAJA ADMINISTRATIVA</option>
            </select>
          </div>
          <div class="col-md-2 mb-3 d-flex align-items-end">
            <button class="btn-municipal-primary w-100" @click="fetchPadron" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              Consultar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="municipal-card mb-3">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5>Padrón Global de Locales</h5>
        <div>
          <button class="btn-municipal-primary me-2" @click="exportExcel" :disabled="loading">Exportar Excel</button>
          <button class="btn-municipal-secondary" @click="$router.push('/')">Salir</button>
        </div>
      </div>
      <div class="municipal-card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div v-else class="table-responsive">
          <table class="municipal-table table-sm table-hover mb-0">
            <thead>
              <tr>
                <th>Rec.</th>
                <th>Merc.</th>
                <th>Nombre Mercado</th>
                <th>Cat.</th>
                <th>Secc.</th>
                <th>Local</th>
                <th>Let</th>
                <th>Blq</th>
                <th>Nombre</th>
                <th>Adicionales</th>
                <th>Superficie</th>
                <th>Renta</th>
                <th>Estado</th>
                <th>Leyenda</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in paginatedPadron" :key="row.id_local">
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local }}</td>
                <td>{{ row.bloque }}</td>
                <td>{{ row.nombre }}</td>
                <td>{{ row.descripcion_local }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ formatCurrency(row.renta) }}</td>
                <td>{{ estadoLabel(row.vigencia) }}</td>
                <td>{{ row.leyenda }}</td>
              </tr>
              <tr v-if="padron.length === 0">
                <td colspan="14" class="text-center">No hay datos para los filtros seleccionados.</td>
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
              @change="changeItemsPerPage($event.target.value)"
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
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const router = useRouter()
const toast = useToast()

const loading = ref(false)
const padron = ref([])

const now = new Date()
const filters = ref({
  axo: now.getFullYear(),
  mes: now.getMonth() + 1,
  vig: 'A'
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(padron.value.length / itemsPerPage.value)
})

const paginatedPadron = computed(() => {
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

const changeItemsPerPage = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1 // Reset a la primera página
}

const resetPagination = () => {
  currentPage.value = 1
  itemsPerPage.value = 10
}

const fetchPadron = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_padron_global',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_mes', Valor: parseInt(filters.value.mes) },
          { Nombre: 'p_vigencia', Valor: filters.value.vig }
        ]
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      padron.value = response.data.eResponse.data.result
      resetPagination()
      toast.success(`Se encontraron ${padron.value.length} registros`)
    } else {
      padron.value = []
      toast.info('No se encontraron datos para los filtros seleccionados')
    }
  } catch (error) {
    toast.error('Error al consultar el padrón global')
    console.error('Error:', error)
    padron.value = []
  } finally {
    loading.value = false
  }
}

const exportExcel = async () => {
  if (padron.value.length === 0) {
    toast.warning('No hay datos para exportar')
    return
  }

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_vencimiento_rec',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_mes', Valor: parseInt(filters.value.mes) },
          { Nombre: 'p_vigencia', Valor: filters.value.vig }
        ]
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.url) {
      window.open(response.data.eResponse.data.url, '_blank')
      toast.success('Archivo Excel generado correctamente')
    } else {
      toast.error('No se pudo generar el archivo Excel')
    }
  } catch (error) {
    toast.error('Error al exportar a Excel')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const estadoLabel = (vig) => {
  const estados = {
    'A': 'VIGENTE',
    'B': 'BAJA TOTAL',
    'C': 'BAJA POR ACUERDO',
    'D': 'BAJA ADMINISTRATIVA'
  }
  return estados[vig] || vig
}

const formatCurrency = (val) => {
  if (typeof val === 'number') {
    return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
  }
  return val || ''
}

onMounted(() => {
  fetchPadron()
})
</script>

<style scoped>
/* Estilos adicionales si son necesarios */
</style>
