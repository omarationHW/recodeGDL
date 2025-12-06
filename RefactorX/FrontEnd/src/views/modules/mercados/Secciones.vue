<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="layer-group" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Secciones</h1>
        <p>Inicio > Mercados > Secciones</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalCrear" :disabled="loading">
          <font-awesome-icon icon="plus-circle" />
          Nueva Sección
        </button>
        <button class="btn-municipal-primary" @click="cargarSecciones" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
          Recargar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas -->
      <div class="stats-grid mb-4">
        <div class="stat-card stat-card-primary">
          <div class="stat-icon">
            <font-awesome-icon icon="layer-group" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.totalSecciones }}</div>
            <div class="stat-label">Secciones Registradas</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <font-awesome-icon icon="store" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalLocales) }}</div>
            <div class="stat-label">Locales Clasificados</div>
          </div>
        </div>
        <div class="stat-card stat-card-info">
          <div class="stat-icon">
            <font-awesome-icon icon="chart-bar" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.promedio }}</div>
            <div class="stat-label">Promedio Locales/Sección</div>
          </div>
        </div>
      </div>

      <!-- Tabla de secciones -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Secciones
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="secciones.length > 0">
              {{ secciones.length }} secciones
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando secciones...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Sección</th>
                  <th>Descripción</th>
                  <th class="text-end">Locales</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="secciones.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron secciones registradas</p>
                  </td>
                </tr>
                <tr v-else v-for="seccion in secciones" :key="seccion.seccion" class="row-hover">
                  <td>
                    <span class="badge-seccion">{{ seccion.seccion }}</span>
                  </td>
                  <td>
                    <font-awesome-icon icon="layer-group" class="icon-small text-primary" />
                    <strong>{{ seccion.descripcion }}</strong>
                  </td>
                  <td class="text-end">
                    <span class="badge-count">{{ formatNumber(seccion.cantidad_locales) }}</span>
                  </td>
                  <td class="text-center">
                    <button
                      class="btn-icon btn-warning me-2"
                      @click="abrirModalEditar(seccion)"
                      title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-icon btn-danger"
                      @click="eliminarSeccion(seccion)"
                      title="Eliminar"
                      :disabled="seccion.cantidad_locales > 0">
                      <font-awesome-icon icon="trash" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Crear/Editar Sección -->
    <Modal
      v-if="showModal"
      :show="showModal"
      :title="modoEdicion ? 'Editar Sección' : 'Nueva Sección'"
      :icon="modoEdicion ? 'edit' : 'plus-circle'"
      size="md"
      @close="cerrarModal">
      <template #body>
        <form @submit.prevent="guardarSeccion">
          <div class="mb-3">
            <label class="form-label">
              <font-awesome-icon icon="code" class="me-2" />
              Código de Sección <span class="text-danger">*</span>
            </label>
            <input
              type="text"
              v-model="form.seccion"
              class="form-control"
              :readonly="modoEdicion"
              maxlength="2"
              placeholder="Ej: SS, EA, PS"
              required
              @input="form.seccion = form.seccion.toUpperCase()"
            />
            <small class="text-muted">Máximo 2 caracteres</small>
          </div>

          <div class="mb-3">
            <label class="form-label">
              <font-awesome-icon icon="align-left" class="me-2" />
              Descripción <span class="text-danger">*</span>
            </label>
            <input
              type="text"
              v-model="form.descripcion"
              class="form-control"
              maxlength="50"
              placeholder="Descripción de la sección"
              required
            />
            <small class="text-muted">Máximo 50 caracteres</small>
          </div>

          <div class="alert alert-info d-flex align-items-center" v-if="modoEdicion">
            <font-awesome-icon icon="info-circle" class="me-2" />
            <small>El código de sección no puede modificarse</small>
          </div>
        </form>
      </template>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          type="button"
          class="btn-municipal-success"
          @click="guardarSeccion"
          :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar' }}
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/Modal.vue'

// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const guardando = ref(false)
const error = ref('')
const secciones = ref([])
const showModal = ref(false)
const modoEdicion = ref(false)
const form = ref({
  seccion: '',
  descripcion: ''
})

// Computed
const estadisticas = computed(() => {
  const totalSecciones = secciones.value.length
  const totalLocales = secciones.value.reduce((sum, s) => sum + parseInt(s.cantidad_locales || 0), 0)
  const promedio = totalSecciones > 0 ? Math.round(totalLocales / totalSecciones) : 0

  return {
    totalSecciones,
    totalLocales,
    promedio
  }
})

// Métodos de UI
const mostrarAyuda = () => {
  showToast('info', 'Las secciones permiten clasificar los locales dentro de los mercados (Ej: Tianguis, Edificio Administrativo, etc.)')
}

// Utilidades
const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Modal
const abrirModalCrear = () => {
  modoEdicion.value = false
  form.value = {
    seccion: '',
    descripcion: ''
  }
  showModal.value = true
}

const abrirModalEditar = (seccion) => {
  modoEdicion.value = true
  form.value = {
    seccion: seccion.seccion.trim(),
    descripcion: seccion.descripcion
  }
  showModal.value = true
}

const cerrarModal = () => {
  showModal.value = false
  form.value = {
    seccion: '',
    descripcion: ''
  }
}

// API
const cargarSecciones = async () => {
  loading.value = true
  error.value = ''
  showLoading('Cargando secciones...')

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_secciones_list',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      secciones.value = response.data.eResponse.data.result || []
      if (secciones.value.length > 0) {
        showToast('success', `Se cargaron ${secciones.value.length} secciones`)
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar secciones'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al cargar secciones'
    console.error('Error al cargar secciones:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const guardarSeccion = async () => {
  if (!form.value.seccion.trim() || !form.value.descripcion.trim()) {
    showToast('warning', 'Todos los campos son requeridos')
    return
  }

  guardando.value = true
  showLoading(modoEdicion.value ? 'Actualizando sección...' : 'Guardando sección...')

  try {
    const operacion = modoEdicion.value ? 'sp_secciones_update' : 'sp_secciones_create'

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_seccion', Valor: form.value.seccion.trim().toUpperCase() },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion.trim() }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      const result = response.data.eResponse.data.result[0]

      if (result.success) {
        showToast('success', result.message)
        cerrarModal()
        await cargarSecciones()
      } else {
        showToast('error', result.message)
      }
    } else {
      showToast('error', 'Error al guardar la sección')
    }
  } catch (err) {
    console.error('Error al guardar sección:', err)
    showToast('error', err.response?.data?.eResponse?.message || 'Error al guardar la sección')
  } finally {
    guardando.value = false
    hideLoading()
  }
}

const eliminarSeccion = async (seccion) => {
  if (seccion.cantidad_locales > 0) {
    showToast('warning', `No se puede eliminar. Hay ${seccion.cantidad_locales} locales asociados`)
    return
  }

  if (!confirm(`¿Está seguro de eliminar la sección "${seccion.seccion} - ${seccion.descripcion}"?`)) {
    return
  }

  showLoading('Eliminando sección...')

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_secciones_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_seccion', Valor: seccion.seccion.trim() }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      const result = response.data.eResponse.data.result[0]

      if (result.success) {
        showToast('success', result.message)
        await cargarSecciones()
      } else {
        showToast('error', result.message)
      }
    } else {
      showToast('error', 'Error al eliminar la sección')
    }
  } catch (err) {
    console.error('Error al eliminar sección:', err)
    showToast('error', err.response?.data?.eResponse?.message || 'Error al eliminar la sección')
  } finally {
    hideLoading()
  }
}

// Lifecycle
onMounted(() => {
  cargarSecciones()
})
</script>
