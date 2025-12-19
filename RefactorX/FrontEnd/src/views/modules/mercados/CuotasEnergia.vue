<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Cuotas de Energía Eléctrica</h1>
        <p>Inicio > Mercados > Cuotas de Energía</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Cuotas de Energía Eléctrica</h5>
      </div>
      <div class="municipal-card-body">
        <div class="mb-3">
          <button class="btn-municipal-primary" @click="openCreateForm" :disabled="loading">Agregar Cuota</button>
        </div>

        <div v-if="showCreate || editRow" class="municipal-card mb-4">
          <div class="municipal-card-header">
            <h6>{{ editRow ? 'Modificar Cuota' : 'Agregar Nueva Cuota' }}</h6>
          </div>
          <div class="municipal-card-body">
            <form @submit.prevent="editRow ? updateCuota() : createCuota()">
              <div class="row">
                <div class="col-md-3 mb-3">
                  <label class="municipal-form-label">Año *</label>
                  <input type="number" v-model.number="form.axo" class="municipal-form-control" required min="2000" max="2100" :disabled="loading">
                </div>
                <div class="col-md-3 mb-3">
                  <label class="municipal-form-label">Periodo *</label>
                  <input type="number" v-model.number="form.periodo" class="municipal-form-control" required min="1" max="12" :disabled="loading">
                </div>
                <div class="col-md-3 mb-3">
                  <label class="municipal-form-label">Importe *</label>
                  <input type="number" v-model.number="form.importe" class="municipal-form-control" step="0.000001" min="0.000001" required :disabled="loading">
                </div>
              </div>
              <div class="d-flex gap-2">
                <button type="submit" class="btn-municipal-primary" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                  {{ editRow ? 'Guardar Cambios' : 'Agregar' }}
                </button>
                <button type="button" class="btn-municipal-secondary" @click="cancelForm" :disabled="loading">Cancelar</button>
              </div>
            </form>
          </div>
        </div>

        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div v-else class="table-responsive">
          <table class="municipal-table table-hover">
            <thead>
              <tr>
                <th>Control</th>
                <th>Año</th>
                <th>Periodo</th>
                <th>Importe</th>
                <th>Fecha de Alta</th>
                <th>Usuario</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in paginatedData" :key="row.id_kilowhatts">
                <td>{{ row.id_kilowhatts }}</td>
                <td>{{ row.axo }}</td>
                <td>{{ row.periodo }}</td>
                <td>{{ formatCurrency(row.importe) }}</td>
                <td>{{ formatDateTime(row.fecha_alta) }}</td>
                <td>{{ row.usuario }}</td>
                <td>
                  <button class="btn btn-sm btn-info me-1" @click="editCuota(row)" :disabled="loading">Editar</button>
                  <button class="btn btn-sm btn-danger" @click="deleteCuota(row)" :disabled="loading">Eliminar</button>
                </td>
              </tr>
              <tr v-if="cuotas.length === 0">
                <td colspan="7" class="text-center">No hay cuotas registradas.</td>
              </tr>
            </tbody>
          </table>

          <!-- Controles de paginación -->
          <div v-if="cuotas.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, cuotas.length) }}
                de {{ cuotas.length }} registros
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from '@/composables/useToast'

const { showToast } = useToast()
const loading = ref(false)
const cuotas = ref([])
const showCreate = ref(false)
const editRow = ref(null)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const form = ref({
  axo: new Date().getFullYear(),
  periodo: 1,
  importe: null
})

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(cuotas.value.length / itemsPerPage.value)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return cuotas.value.slice(start, end)
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

const fetchCuotas = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotas_energia_list',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      cuotas.value = response.data.eResponse.data.result
      currentPage.value = 1
    } else {
      cuotas.value = []
    }
  } catch (error) {
    showToast('Error al cargar cuotas', 'error')
    console.error('Error:', error)
    cuotas.value = []
  } finally {
    loading.value = false
  }
}

const openCreateForm = () => {
  showCreate.value = true
  editRow.value = null
  resetForm()
}

const createCuota = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotas_energia_create',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) },
          { Nombre: 'p_importe', Valor: parseFloat(form.value.importe) },
          { Nombre: 'p_id_usuario', Valor: 1 } // TODO: Obtener de sesión
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      showToast('Cuota agregada correctamente', 'success')
      showCreate.value = false
      resetForm()
      await fetchCuotas()
    } else {
      showToast(response.data?.eResponse?.message || 'Error al agregar cuota', 'error')
    }
  } catch (error) {
    showToast('Error al agregar cuota', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const editCuota = (row) => {
  editRow.value = row
  form.value = {
    id_kilowhatts: row.id_kilowhatts,
    axo: row.axo,
    periodo: row.periodo,
    importe: row.importe
  }
  showCreate.value = false
}

const updateCuota = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotas_energia_update',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_kilowhatts', Valor: parseInt(form.value.id_kilowhatts) },
          { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) },
          { Nombre: 'p_importe', Valor: parseFloat(form.value.importe) },
          { Nombre: 'p_id_usuario', Valor: 1 } // TODO: Obtener de sesión
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      showToast('Cuota modificada correctamente', 'success')
      editRow.value = null
      resetForm()
      await fetchCuotas()
    } else {
      showToast(response.data?.eResponse?.message || 'Error al modificar cuota', 'error')
    }
  } catch (error) {
    showToast('Error al modificar cuota', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const deleteCuota = async (row) => {
  const confirmDelete = confirm('¿Está seguro de eliminar la cuota seleccionada?')
  if (!confirmDelete) return

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotas_energia_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_kilowhatts', Valor: parseInt(row.id_kilowhatts) }
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      showToast('Cuota eliminada correctamente', 'success')
      await fetchCuotas()
    } else {
      showToast(response.data?.eResponse?.message || 'Error al eliminar cuota', 'error')
    }
  } catch (error) {
    showToast('Error al eliminar cuota', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const cancelForm = () => {
  showCreate.value = false
  editRow.value = null
  resetForm()
}

const resetForm = () => {
  form.value = {
    axo: new Date().getFullYear(),
    periodo: 1,
    importe: null
  }
}

const formatCurrency = (val) => {
  if (val == null) return ''
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(parseFloat(val))
}

const formatDateTime = (val) => {
  if (!val) return ''
  return new Date(val).toLocaleString('es-MX')
}

onMounted(() => {
  fetchCuotas()
})
</script>

<style scoped>
.gap-2 {
  gap: 0.5rem;
}
</style>
