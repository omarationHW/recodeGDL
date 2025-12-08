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
                <button type="submit" class="btn-municipal-success" :disabled="loading">
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
              <tr v-for="row in cuotas" :key="row.id_kilowhatts">
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
const cuotas = ref([])
const showCreate = ref(false)
const editRow = ref(null)

const form = ref({
  axo: new Date().getFullYear(),
  periodo: 1,
  importe: null
})

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
    } else {
      cuotas.value = []
    }
  } catch (error) {
    toast.error('Error al cargar cuotas')
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
      toast.success('Cuota agregada correctamente')
      showCreate.value = false
      resetForm()
      await fetchCuotas()
    } else {
      toast.error(response.data?.eResponse?.message || 'Error al agregar cuota')
    }
  } catch (error) {
    toast.error('Error al agregar cuota')
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
      toast.success('Cuota modificada correctamente')
      editRow.value = null
      resetForm()
      await fetchCuotas()
    } else {
      toast.error(response.data?.eResponse?.message || 'Error al modificar cuota')
    }
  } catch (error) {
    toast.error('Error al modificar cuota')
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
      toast.success('Cuota eliminada correctamente')
      await fetchCuotas()
    } else {
      toast.error(response.data?.eResponse?.message || 'Error al eliminar cuota')
    }
  } catch (error) {
    toast.error('Error al eliminar cuota')
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
