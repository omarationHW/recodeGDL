<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Clave de Diferencias</h1>
        <p>Inicio > Mercados > Clave de Diferencias</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Clave de Diferencias</h5>
      </div>
      <div class="municipal-card-body">
        <div class="mb-3 d-flex gap-2">
          <button class="btn-municipal-primary" @click="openAddModal" :disabled="loading">
            <font-awesome-icon icon="plus-circle" class="me-1" /> Agregar
          </button>
          <button class="btn-municipal-info" @click="fetchData" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
            <font-awesome-icon icon="sync" v-if="!loading" />
            Refrescar
          </button>
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
                <th>Clave</th>
                <th>Descripción</th>
                <th>Cuenta Ingreso</th>
                <th>Usuario</th>
                <th>Fecha Actual</th>
                <th width="120">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in paginatedRows" :key="row.clave_diferencia">
                <td>{{ row.clave_diferencia }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.cuenta_ingreso }}</td>
                <td>{{ row.usuario }}</td>
                <td>{{ formatDate(row.fecha_actual) }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button class="btn-municipal-primary btn-sm" @click.stop="openEditModal(row)" title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="rows.length === 0">
                <td colspan="6" class="text-center">No hay datos disponibles</td>
              </tr>
            </tbody>
          </table>

          <!-- Controles de Paginación -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, rows.length) }}
                de {{ rows.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="form-label me-2 mb-0">Registros por página:</label>
              <select
                class="form-select form-select-sm"
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

    <!-- Add Modal -->
    <div v-if="showAddModal" class="modal-backdrop show"></div>
    <div v-if="showAddModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Agregar Clave de Diferencia</h5>
            <button type="button" class="btn-close" @click="closeAddModal"></button>
          </div>
          <form @submit.prevent="addCveDiferencia">
            <div class="modal-body">
              <div class="mb-3">
                <label class="municipal-form-label">Descripción *</label>
                <input v-model="form.descripcion" type="text" class="municipal-form-control" maxlength="60" required />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Cuenta Ingreso *</label>
                <select v-model="form.cuenta_ingreso" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cuenta in cuentasIngreso" :key="cuenta.cta_aplicacion" :value="cuenta.cta_aplicacion">
                    {{ cuenta.cta_aplicacion }} - {{ cuenta.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn-municipal-secondary" @click="closeAddModal">Cancelar</button>
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                Guardar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Edit Modal -->
    <div v-if="showEditModal" class="modal-backdrop show"></div>
    <div v-if="showEditModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Modificar Clave de Diferencia</h5>
            <button type="button" class="btn-close" @click="closeEditModal"></button>
          </div>
          <form @submit.prevent="updateCveDiferencia">
            <div class="modal-body">
              <div class="mb-3">
                <label class="municipal-form-label">Descripción *</label>
                <input v-model="form.descripcion" type="text" class="municipal-form-control" maxlength="60" required />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Cuenta Ingreso *</label>
                <select v-model="form.cuenta_ingreso" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cuenta in cuentasIngreso" :key="cuenta.cta_aplicacion" :value="cuenta.cta_aplicacion">
                    {{ cuenta.cta_aplicacion }} - {{ cuenta.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn-municipal-secondary" @click="closeEditModal">Cancelar</button>
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                Actualizar
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const toast = useToast()
const loading = ref(false)
const rows = ref([])
const cuentasIngreso = ref([])
const selectedRow = ref(null)
const showAddModal = ref(false)
const showEditModal = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const form = ref({
  descripcion: '',
  cuenta_ingreso: ''
})

// Computed de paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage.value))

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rows.value.slice(start, end)
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
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

const fetchData = async () => {
  showLoading('Cargando Clave de Diferencias', 'Preparando catálogo...')
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_cve_diferencias',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      rows.value = response.data.eResponse.data.result
    } else {
      rows.value = []
    }
  } catch (error) {
    toast.error('Error al cargar claves de diferencias')
    console.error('Error:', error)
    rows.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const fetchCuentasIngreso = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_cuentas_ingreso',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      cuentasIngreso.value = response.data.eResponse.data.result
    }
  } catch (error) {
    toast.error('Error al cargar cuentas de ingreso')
    console.error('Error:', error)
  }
}

const openAddModal = () => {
  selectedRow.value = null
  form.value = {
    descripcion: '',
    cuenta_ingreso: ''
  }
  showAddModal.value = true
}

const closeAddModal = () => {
  showAddModal.value = false
  selectedRow.value = null
  form.value = {
    descripcion: '',
    cuenta_ingreso: ''
  }
}

const openEditModal = (row) => {
  if (!row) return
  selectedRow.value = row
  form.value.descripcion = row.descripcion
  form.value.cuenta_ingreso = row.cuenta_ingreso
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
}

const addCveDiferencia = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_add_cve_diferencia',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_descripcion', Valor: form.value.descripcion },
          { Nombre: 'p_cuenta_ingreso', Valor: form.value.cuenta_ingreso },
          { Nombre: 'p_id_usuario', Valor: 1 } // TODO: Obtener de sesión
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      toast.success('Clave de diferencia agregada correctamente')
      closeAddModal()
      await fetchData()
    } else {
      toast.error(response.data?.eResponse?.message || 'Error al agregar')
    }
  } catch (error) {
    toast.error('Error al agregar clave de diferencia')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const updateCveDiferencia = async () => {
  if (!selectedRow.value) return

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_update_cve_diferencia',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_clave_diferencia', Valor: parseInt(selectedRow.value.clave_diferencia) },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion },
          { Nombre: 'p_cuenta_ingreso', Valor: form.value.cuenta_ingreso },
          { Nombre: 'p_id_usuario', Valor: 1 } // TODO: Obtener de sesión
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      toast.success('Clave de diferencia actualizada correctamente')
      closeEditModal()
      await fetchData()
      selectedRow.value = null
    } else {
      toast.error(response.data?.eResponse?.message || 'Error al actualizar')
    }
  } catch (error) {
    toast.error('Error al actualizar clave de diferencia')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const formatDate = (dt) => {
  if (!dt) return ''
  return new Date(dt).toLocaleString('es-MX')
}

onMounted(() => {
  fetchData()
  fetchCuentasIngreso()
})
</script>

<style scoped>
.gap-2 {
  gap: 0.5rem;
}

.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1040;
  width: 100vw;
  height: 100vh;
  background-color: #000;
  opacity: 0.5;
}

.modal.show {
  display: block;
}

.pagination-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding: 1rem 0;
  gap: 1rem;
  flex-wrap: wrap;
}

.pagination-info {
  display: flex;
  align-items: center;
}

.pagination-size {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-buttons {
  display: flex;
  gap: 0.25rem;
}

.pagination-buttons .btn {
  min-width: 2rem;
}
</style>
