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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="abrirModalCrear" :disabled="loading">
          <font-awesome-icon icon="plus-circle" />
          Nueva Sección
        </button>
        <button class="btn-municipal-primary" @click="cargarSecciones" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
          Recargar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas -->
      <div class="stats-grid mb-4">
        <div class="stat-card stat-card-primary">
          <div class="stat-icon-wrapper">
            <font-awesome-icon icon="layer-group" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.totalSecciones }}</div>
            <div class="stat-label">Secciones Registradas</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon-wrapper">
            <font-awesome-icon icon="store" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalLocales) }}</div>
            <div class="stat-label">Locales Clasificados</div>
          </div>
        </div>
        <div class="stat-card stat-card-info">
          <div class="stat-icon-wrapper">
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
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="abrirModalEditar(seccion)"
                        title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click.stop="eliminarSeccion(seccion)"
                        title="Eliminar"
                        :disabled="seccion.cantidad_locales > 0">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
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
        <form @submit.prevent="guardarSeccion">
          <div class="mb-3">
            <label class="municipal-form-label">
              <font-awesome-icon icon="code" class="me-2" />
              Código de Sección <span class="text-danger">*</span>
            </label>
            <input
              type="text"
              v-model="form.seccion"
              class="municipal-form-control"
              :readonly="modoEdicion"
              maxlength="2"
              placeholder="Ej: SS, EA, PS"
              required
              @input="form.seccion = form.seccion.toUpperCase()"
            />
            <small class="text-muted">Máximo 2 caracteres</small>
          </div>

          <div class="mb-3">
            <label class="municipal-form-label">
              <font-awesome-icon icon="align-left" class="me-2" />
              Descripción <span class="text-danger">*</span>
            </label>
            <input
              type="text"
              v-model="form.descripcion"
              class="municipal-form-control"
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

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          type="button"
          class="btn-municipal-primary"
          @click="guardarSeccion"
          :disabled="guardando">
          <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
          {{ guardando ? 'Guardando...' : 'Guardar' }}
        </button>
      
  <DocumentationModal :show="showAyuda" :component-name="'Secciones'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Secciones'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Secciones'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Secciones'" @close="showDocumentacion = false" />
</template>
    </Modal>

    <!-- Modal de Confirmación de Eliminación -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="cancelarEliminacion">
      <div class="modal-dialog-confirm" @click.stop>
        <div class="modal-header-confirm">
          <font-awesome-icon icon="exclamation-triangle" class="modal-icon-warning" />
          <h5 class="modal-title-confirm">Confirmar Eliminación</h5>
        </div>
        <div class="modal-body-confirm">
          <p>¿Está seguro de eliminar la sección?</p>
          <div class="section-info" v-if="seccionAEliminar">
            <strong>{{ seccionAEliminar.seccion }}</strong> - {{ seccionAEliminar.descripcion }}
          </div>
          <p class="text-muted mt-3">Esta acción no se puede deshacer.</p>
        </div>
        <div class="modal-footer-confirm">
          <button type="button" class="btn-cancel" @click="cancelarEliminacion">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="button" class="btn-delete" @click="confirmarEliminacion">
            <font-awesome-icon icon="trash" />
            Eliminar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import Swal from 'sweetalert2'

const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#6c757d',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


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
const showDeleteModal = ref(false)
const seccionAEliminar = ref(null)
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
  showToast('Las secciones permiten clasificar los locales dentro de los mercados (Ej: Tianguis, Edificio Administrativo, etc.)', 'info')
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
    const response = await apiService.execute(
          'sp_secciones_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )

    if (response && response.success === true) {
      secciones.value = response.data.result || []
      if (secciones.value.length > 0) {
        showToast(`Se cargaron ${secciones.value.length} secciones`, 'success')
      }
    } else {
      error.value = response?.message || 'Error al cargar secciones'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = err.response?.message || 'Error al cargar secciones'
    console.error('Error al cargar secciones:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const guardarSeccion = async () => {
  if (!form.value.seccion.trim() || !form.value.descripcion.trim()) {
    showToast('Todos los campos son requeridos', 'warning')
    return
  }

  const confirmado = await confirmarAccion(
    modoEdicion.value ? '¿Actualizar sección?' : '¿Guardar sección?',
    modoEdicion.value ? 'Se actualizarán los datos' : 'Se creará una nueva sección',
    modoEdicion.value ? 'Sí, actualizar' : 'Sí, guardar'
  )
  if (!confirmado) return

  guardando.value = true
  showLoading(modoEdicion.value ? 'Actualizando sección...' : 'Guardando sección...')

  try {
    const operacion = modoEdicion.value ? 'sp_secciones_update' : 'sp_secciones_create'

    const response = await apiService.execute(
      operacion,
      'mercados',
      [
        { nombre: 'p_seccion', valor: form.value.seccion.trim().toUpperCase(), tipo: 'string' },
        { nombre: 'p_descripcion', valor: form.value.descripcion.trim(), tipo: 'string' }
      ],
      '',
      null,
      'publico'
    )

    if (response && response.success === true) {
      const result = response.data.result[0]

      if (result.success) {
        showToast(result.message, 'success')
        cerrarModal()
        await cargarSecciones()
      } else {
        showToast(result.message, 'error')
      }
    } else {
      showToast('Error al guardar la sección', 'error')
    }
  } catch (err) {
    console.error('Error al guardar sección:', err)
    showToast(err.response?.message || 'Error al guardar la sección', 'error')
  } finally {
    guardando.value = false
    hideLoading()
  }
}

const eliminarSeccion = (seccion) => {
  if (seccion.cantidad_locales > 0) {
    showToast(`No se puede eliminar. Hay ${seccion.cantidad_locales} locales asociados`, 'warning')
    return
  }

  seccionAEliminar.value = seccion
  showDeleteModal.value = true
}

const cancelarEliminacion = () => {
  showDeleteModal.value = false
  seccionAEliminar.value = null
}

const confirmarEliminacion = async () => {
  if (!seccionAEliminar.value) return

  const confirmado = await confirmarEliminar('Se eliminará la sección ' + seccionAEliminar.value.descripcion)
  if (!confirmado) {
    showDeleteModal.value = false
    return
  }

  showDeleteModal.value = false
  showLoading('Eliminando sección...')

  try {
    const response = await apiService.execute(
          'sp_secciones_delete',
          'mercados',
          [
          { nombre: 'p_seccion', valor: seccionAEliminar.value.seccion.trim() }
        ],
          '',
          null,
          'publico'
        )

    if (response && response.success === true) {
      const result = response.data.result[0]

      if (result.success) {
        showToast(result.message, 'success')
        await cargarSecciones()
      } else {
        showToast(result.message, 'error')
      }
    } else {
      showToast('Error al eliminar la sección', 'error')
    }
  } catch (err) {
    console.error('Error al eliminar sección:', err)
    showToast(err.response?.message || 'Error al eliminar la sección', 'error')
  } finally {
    hideLoading()
    seccionAEliminar.value = null
  }
}

// Lifecycle
onMounted(() => {
  cargarSecciones()
})
</script>
