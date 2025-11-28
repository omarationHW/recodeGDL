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
          <button class="btn-municipal-primary" @click="openAddModal" :disabled="loading">Agregar</button>
          <button class="btn-municipal-secondary" :disabled="!selectedRow || loading" @click="openEditModal">Modificar</button>
          <button class="btn-municipal-info" @click="fetchData" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
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
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in rows" :key="row.clave_diferencia"
                  :class="{ 'table-active': selectedRow && selectedRow.clave_diferencia === row.clave_diferencia }"
                  @click="selectRow(row)"
                  style="cursor: pointer;">
                <td>{{ row.clave_diferencia }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.cuenta_ingreso }}</td>
                <td>{{ row.usuario }}</td>
                <td>{{ formatDate(row.fecha_actual) }}</td>
              </tr>
              <tr v-if="rows.length === 0">
                <td colspan="5" class="text-center">No hay datos disponibles</td>
              </tr>
            </tbody>
          </table>
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
              <button type="submit" class="btn-municipal-success" :disabled="loading">
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
              <button type="submit" class="btn-municipal-success" :disabled="loading">
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
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const toast = useToast()
const loading = ref(false)
const rows = ref([])
const cuentasIngreso = ref([])
const selectedRow = ref(null)
const showAddModal = ref(false)
const showEditModal = ref(false)

const form = ref({
  descripcion: '',
  cuenta_ingreso: ''
})

const fetchData = async () => {
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

const selectRow = (row) => {
  selectedRow.value = row
  form.value.descripcion = row.descripcion
  form.value.cuenta_ingreso = row.cuenta_ingreso
}

const openAddModal = () => {
  form.value = {
    descripcion: '',
    cuenta_ingreso: ''
  }
  showAddModal.value = true
}

const closeAddModal = () => {
  showAddModal.value = false
  form.value = {
    descripcion: '',
    cuenta_ingreso: ''
  }
}

const openEditModal = () => {
  if (!selectedRow.value) return
  form.value.descripcion = selectedRow.value.descripcion
  form.value.cuenta_ingreso = selectedRow.value.cuenta_ingreso
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
</style>
