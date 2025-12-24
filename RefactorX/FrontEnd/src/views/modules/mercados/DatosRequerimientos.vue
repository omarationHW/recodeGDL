<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Requerimientos</h1>
        <p>Inicio > Mercados > Requerimientos</p>
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
        
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda por Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarRequerimiento">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">ID Local <span class="required">*</span></label>
                <input v-model.number="form.id_local" type="number" class="municipal-form-control" required :disabled="loading" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Módulo <span class="required">*</span></label>
                <input v-model.number="form.modulo" type="number" class="municipal-form-control" required :disabled="loading" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Folio <span class="required">*</span></label>
                <input v-model.number="form.folio" type="number" class="municipal-form-control" required :disabled="loading" />
              </div>
              <div class="form-group align-self-end">
                <button type="submit" class="btn-municipal-primary" :disabled="loading">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                  Buscar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Resultados -->
      <template v-if="local && mercado">
        <div class="row">
          <!-- Datos del Local -->
          <div class="col-md-6">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5>
                  <font-awesome-icon icon="store" />
                  Datos del Local
                </h5>
              </div>
              <div class="municipal-card-body">
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">ID</span>
                    <span class="info-value">{{ local.id_local }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Oficina</span>
                    <span class="info-value">{{ local.oficina }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Num. Mercado</span>
                    <span class="info-value">{{ local.num_mercado }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Categoría</span>
                    <span class="info-value">{{ local.categoria }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Sección</span>
                    <span class="info-value">{{ local.seccion }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Letra Local</span>
                    <span class="info-value">{{ local.letra_local || '-' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Bloque</span>
                    <span class="info-value">{{ local.bloque || '-' }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Nombre</span>
                    <span class="info-value">{{ local.nombre }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Descripción</span>
                    <span class="info-value">{{ local.descripcion_local || '-' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Datos del Mercado -->
          <div class="col-md-6">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5>
                  <font-awesome-icon icon="building" />
                  Datos del Mercado
                </h5>
              </div>
              <div class="municipal-card-body">
                <div class="info-grid">
                  <div class="info-item full-width">
                    <span class="info-label">Descripción</span>
                    <span class="info-value">{{ mercado.descripcion }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Cuenta Ingreso</span>
                    <span class="info-value">{{ mercado.cuenta_ingreso }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Cuenta Energía</span>
                    <span class="info-value">{{ mercado.cuenta_energia }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      
  <DocumentationModal :show="showAyuda" :component-name="'DatosRequerimientos'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - DatosRequerimientos'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'DatosRequerimientos'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - DatosRequerimientos'" @close="showDocumentacion = false" />
</template>

      <!-- Datos del Requerimiento -->
      <div v-if="requerimiento" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="clipboard-list" />
            Datos del Requerimiento
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-4">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Folio</span>
                  <span class="info-value highlight">{{ requerimiento.folio }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Diligencia</span>
                  <span class="info-value">{{ requerimiento.diligencia }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Estado</span>
                  <span class="info-value">{{ requerimiento.estado }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Vigencia</span>
                  <span class="info-value">{{ requerimiento.vigencia }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Clave Practicado</span>
                  <span class="info-value">{{ requerimiento.clave_practicado }}</span>
                </div>
              </div>
            </div>
            <div class="col-md-4">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Importe Global</span>
                  <span class="info-value currency">{{ formatCurrency(requerimiento.importe_global) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Importe Multa</span>
                  <span class="info-value currency">{{ formatCurrency(requerimiento.importe_multa) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Importe Recargo</span>
                  <span class="info-value currency">{{ formatCurrency(requerimiento.importe_recargo) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Importe Gastos</span>
                  <span class="info-value currency">{{ formatCurrency(requerimiento.importe_gastos) }}</span>
                </div>
              </div>
            </div>
            <div class="col-md-4">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Fecha Emisión</span>
                  <span class="info-value">{{ requerimiento.fecha_emision }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Fecha Practicado</span>
                  <span class="info-value">{{ requerimiento.fecha_practicado }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Zona</span>
                  <span class="info-value">{{ requerimiento.zona }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Zona Apremio</span>
                  <span class="info-value">{{ requerimiento.zona_apremio }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Usuario</span>
                  <span class="info-value">{{ requerimiento.usuario_1 }} ({{ requerimiento.nombre }})</span>
                </div>
              </div>
            </div>
          </div>
          <div class="mt-3" v-if="requerimiento.observaciones">
            <strong>Observaciones:</strong>
            <p class="text-muted mb-0">{{ requerimiento.observaciones }}</p>
          </div>
        </div>
      </div>

      <!-- Periodos Requeridos -->
      <div v-if="periodos && periodos.length" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Periodos Requeridos
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ periodos.length }} periodos
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Recargos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="p in paginatedPeriodos" :key="p.id_control" class="row-hover">
                  <td>{{ p.ayo }}</td>
                  <td>{{ p.periodo }}</td>
                  <td class="text-end">{{ formatCurrency(p.importe) }}</td>
                  <td class="text-end">{{ formatCurrency(p.recargos) }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Paginación -->
            <div v-if="periodos.length > 0" class="pagination-container">
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
        </div>
      </div>

      <!-- Estado vacío -->
      <div v-if="!local && !loading && searched" class="municipal-card">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="exclamation-circle" size="3x" class="text-warning mb-3" />
          <p class="text-muted">{{ error || 'No se encontraron datos' }}</p>
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
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const form = ref({
  id_local: '',
  modulo: '',
  folio: ''
})
const loading = ref(false)
const searched = ref(false)
const error = ref('')
const local = ref(null)
const mercado = ref(null)
const requerimiento = ref(null)
const periodos = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => periodos.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedPeriodos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return periodos.value.slice(start, end)
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
  if (val == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(parseFloat(val))
}

const mostrarAyuda = () => {
  showToast('Consulta de requerimientos de pago por folio', 'info')
}

const buscarRequerimiento = async () => {
  loading.value = true
  showLoading()
  searched.value = false
  error.value = ''
  local.value = null
  mercado.value = null
  requerimiento.value = null
  periodos.value = []

  try {
    // 1. Obtener local
    let res = await apiService.execute(
          'sp_get_locales',
          'mercados',
          [
          { nombre: 'p_id_local', valor: form.value.id_local }
        ],
          '',
          null,
          'publico'
        )

    if (!res.success || !res.data?.result?.length) {
      throw new Error('Local no encontrado')
    }
    local.value = res.data.result[0]

    // 2. Obtener mercado
    res = await apiService.execute(
          'sp_get_mercado',
          'mercados',
          [
          { nombre: 'p_oficina', valor: local.value.oficina },
          { nombre: 'p_num_mercado', valor: local.value.num_mercado }
        ],
          '',
          null,
          'publico'
        )

    if (!res.success || !res.data?.result?.length) {
      throw new Error('Mercado no encontrado')
    }
    mercado.value = res.data.result[0]

    // 3. Obtener requerimiento
    res = await apiService.execute(
          'sp_get_requerimientos',
          'mercados',
          [
          { nombre: 'p_modulo', valor: form.value.modulo },
          { nombre: 'p_folio', valor: form.value.folio },
          { nombre: 'p_control_otr', valor: form.value.id_local }
        ],
          '',
          null,
          'publico'
        )

    if (!res.success || !res.data?.result?.length) {
      throw new Error('Requerimiento no encontrado')
    }
    requerimiento.value = res.data.result[0]

    // 4. Obtener periodos
    res = await apiService.execute(
          'sp_get_periodos',
          'mercados',
          [
          { nombre: 'p_control_otr', valor: form.value.id_local }
        ],
          '',
          null,
          'publico'
        )
    periodos.value = res.success ? res.data?.result || [] : []
    currentPage.value = 1

    searched.value = true
    showToast('Requerimiento encontrado', 'success')

  } catch (e) {
    error.value = e.message || 'Error al consultar datos'
    searched.value = true
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}
</script>
