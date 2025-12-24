<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="exchange-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Movimientos</h1>
        <p>Inicio > Mercados > Movimientos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-secondary" @click="$router.back()">
          <font-awesome-icon icon="arrow-left" />
          Regresar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Movimientos
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Local <span class="required">*</span></label>
              <input v-model.number="id_local" type="number" class="municipal-form-control"
                placeholder="Ingrese el ID del local" :disabled="loading" />
            </div>
            <div class="form-group align-self-end">
              <button class="btn-municipal-primary" @click="fetchMovimientos" :disabled="loading || !id_local">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Movimientos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Movimientos del Local
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="movimientos.length > 0">
              {{ movimientos.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando movimientos...</p>
          </div>

          <div v-else-if="movimientos.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Año</th>
                  <th>Número</th>
                  <th>Actualización</th>
                  <th>Nombre</th>
                  <th>Sector</th>
                  <th>Zona</th>
                  <th>Descripción</th>
                  <th>Superficie</th>
                  <th>Giro</th>
                  <th>Fec. Alta</th>
                  <th>Fec. Baja</th>
                  <th>Vigencia</th>
                  <th>Usuario</th>
                  <th>Clave Cuota</th>
                  <th class="text-end">Renta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="mov in paginatedMovimientos" :key="mov.id_local + '-' + mov.numero_memo" class="row-hover">
                  <td>{{ mov.id_local }}</td>
                  <td>{{ mov.axo_memo }}</td>
                  <td>{{ mov.numero_memo }}</td>
                  <td>{{ mov.fecha }}</td>
                  <td>{{ mov.nombre }}</td>
                  <td>{{ mov.sector }}</td>
                  <td>{{ mov.zona }}</td>
                  <td>{{ mov.drescripcion_local }}</td>
                  <td>{{ mov.superficie }}</td>
                  <td>{{ mov.giro }}</td>
                  <td>{{ mov.fecha_alta }}</td>
                  <td>{{ mov.fecha_baja }}</td>
                  <td>{{ mov.vigdescripcion }}</td>
                  <td>{{ mov.usuario }}</td>
                  <td>{{ mov.clave_cuota }}</td>
                  <td class="text-end">{{ formatCurrency(mov.renta) }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Paginación -->
            <div class="pagination-container">
              <div class="pagination-info">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </div>
              <div class="pagination-controls">
                <label class="me-2">Registros por página:</label>
                <select v-model.number="itemsPerPage" class="form-select form-select-sm">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                  <option :value="250">250</option>
                </select>
              </div>
              <div class="pagination-buttons">
                <button @click="goToPage(1)" :disabled="currentPage === 1" title="Primera página">
                  <font-awesome-icon icon="angle-double-left" />
                </button>
                <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" title="Página anterior">
                  <font-awesome-icon icon="angle-left" />
                </button>
                <button v-for="page in visiblePages" :key="page"
                  :class="page === currentPage ? 'active' : ''"
                  @click="goToPage(page)">
                  {{ page }}
                </button>
                <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" title="Página siguiente">
                  <font-awesome-icon icon="angle-right" />
                </button>
                <button @click="goToPage(totalPages)" :disabled="currentPage === totalPages" title="Última página">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>

          <div v-else-if="searched" class="text-center text-muted py-4">
            <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
            <p>No se encontraron movimientos para el local indicado</p>
          </div>

          <div v-else class="text-center text-muted py-4">
            <font-awesome-icon icon="search" size="2x" class="empty-icon" />
            <p>Ingrese un ID de local para buscar movimientos</p>
          </div>
        </div>
      </div>

      <!-- Catálogos en fila -->
      <div class="row">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="tags" />
                Claves de Movimiento
              </h5>
              <div class="header-right">
                <span class="badge-success" v-if="clavesMov.length > 0">
                  {{ clavesMov.length }}
                </span>
              </div>
            </div>
            <div class="municipal-card-body" style="max-height: 300px; overflow-y: auto;">
              <ul class="catalog-list" v-if="clavesMov.length > 0">
                <li v-for="c in clavesMov" :key="c.clave_movimiento">
                  <span class="catalog-key">{{ c.clave_movimiento }}</span>
                  <span class="catalog-desc">{{ c.descripcion }}</span>
                </li>
              </ul>
              <p v-else class="text-muted text-center">Sin datos</p>
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="receipt" />
                Claves de Cuota
              </h5>
              <div class="header-right">
                <span class="badge-success" v-if="cveCuotas.length > 0">
                  {{ cveCuotas.length }}
                </span>
              </div>
            </div>
            <div class="municipal-card-body" style="max-height: 300px; overflow-y: auto;">
              <ul class="catalog-list" v-if="cveCuotas.length > 0">
                <li v-for="c in cveCuotas" :key="c.clave_cuota">
                  <span class="catalog-key">{{ c.clave_cuota }}</span>
                  <span class="catalog-desc">{{ c.descripcion }}</span>
                </li>
              </ul>
              <p v-else class="text-muted text-center">Sin datos</p>
            </div>
          </div>
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
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'DatosMovimientos'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - DatosMovimientos'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'DatosMovimientos'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - DatosMovimientos'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const id_local = ref('')
const movimientos = ref([])
const clavesMov = ref([])
const cveCuotas = ref([])
const searched = ref(false)
const loading = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => movimientos.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedMovimientos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return movimientos.value.slice(start, end)
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

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

// Toast
const toast = ref({ show: false, type: 'info', message: '' })

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => { toast.value.show = false }

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const formatCurrency = (val) => {
  if (val == null) return '-'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(parseFloat(val))
}

const mostrarAyuda = () => {
  showToast('Consulta de movimientos históricos de un local de mercado', 'info')
}

// Función para calcular descripción de vigencia en frontend
const getVigenciaDesc = (vigencia) => {
  const vigencias = {
    'A': 'ALTA',
    'B': 'BAJA',
    'V': 'VIGENTE',
    'C': 'CANCELADO',
    '1': 'VIGENTE',
    '0': 'BAJA'
  }
  return vigencias[vigencia] || vigencia || '-'
}

// Función para calcular renta en frontend
const calcularRenta = (superficie, importeCuota, seccion) => {
  if (!importeCuota) return null
  // Para sección 'F' (fija), la renta es el importe de cuota
  // Para otras secciones, renta = superficie * importe_cuota
  if (seccion === 'F' || seccion === 'f') {
    return importeCuota
  }
  return (superficie || 1) * importeCuota
}

const fetchMovimientos = async () => {
  if (!id_local.value) {
    showToast('Ingrese un ID de local', 'warning')
    return
  }

  loading.value = true
  showLoading()
  searched.value = false

  try {
    // 1. Movimientos
    const movResp = await apiService.execute(
          'sp_get_movimientos_by_local',
          'mercados',
          [
          { nombre: 'p_id_local', valor: id_local.value }
        ],
          '',
          null,
          'publico'
        )
    let movs = movResp.data?.data.result || []

    // 2. Calcular vigdescripcion y renta para cada movimiento
    for (let mov of movs) {
      // Vigencia descripción (cálculo en frontend)
      mov.vigdescripcion = getVigenciaDesc(mov.vigencia)

      // Obtener cuota
      try {
        const cuotaResp = await apiService.execute(
          'sp_get_cuota_by_params',
          'mercados',
          [
              { nombre: 'p_vaxo', valor: mov.axo_memo },
              { nombre: 'p_vcat', valor: mov.categoria },
              { nombre: 'p_vsec', valor: mov.seccion },
              { nombre: 'p_vcuo', valor: mov.clave_cuota }
            ],
          '',
          null,
          'publico'
        )
        let cuota = cuotaResp.data?.data.result?.[0]

        // Calcular renta (cálculo en frontend)
        mov.renta = cuota ? calcularRenta(mov.superficie, cuota.importe_cuota, mov.seccion) : null
      } catch {
        mov.renta = null
      }
    }

    movimientos.value = movs
    searched.value = true
    currentPage.value = 1

    if (movs.length > 0) {
      showToast(`Se encontraron ${movs.length} movimientos`, 'success')
    } else {
      showToast('No se encontraron movimientos', 'info')
    }
  } catch (err) {
    showToast('Error al cargar movimientos', 'error')
    console.error(err)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const fetchCatalogs = async () => {
  showLoading('Cargando Movimientos', 'Preparando catálogos del sistema...')
  try {
    // Claves de movimiento
    const claveMovResp = await apiService.execute(
          'sp_get_clave_movimientos',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    clavesMov.value = claveMovResp.data?.data.result || []

    // Claves de cuota
    const cveCuotaResp = await apiService.execute(
          'sp_get_cve_cuotas',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    cveCuotas.value = cveCuotaResp.data?.data.result || []
  } catch (err) {
    console.error('Error al cargar catálogos:', err)
  } finally {
    hideLoading()
  }
}

onMounted(() => {
  fetchCatalogs()
})
</script>
