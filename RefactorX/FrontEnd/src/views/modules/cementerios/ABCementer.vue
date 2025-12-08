<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cross" />
      </div>
      <div class="module-view-info">
        <h1>Cat\u00e1logo de Cementerios</h1>
        <p>Cementerios - Alta, Baja y Cambio de Cementerios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Cementerio
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchText"
                @keyup.enter="buscar"
                placeholder="Cementerio, nombre o domicilio..."
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscar"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarBusqueda"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="cargarCementerios"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Cementerios Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cementerio</th>
                  <th>Nombre</th>
                  <th>Domicilio</th>
                  <th>Fecha Modificaci\u00f3n</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cem in cementerios" :key="cem.cementerio" class="row-hover">
                  <td><strong class="text-primary">{{ cem.cementerio }}</strong></td>
                  <td>{{ cem.nombre }}</td>
                  <td>{{ cem.domicilio }}</td>
                  <td>
                    <small class="text-muted">
                      {{ formatDate(cem.fecha_mov) }}
                    </small>
                  </td>
                  <td>
                    <div class="action-buttons">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editarCementerio(cem)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-secondary btn-sm"
                        @click="eliminarCementerio(cem)"
                        title="Eliminar"
                      >
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="cementerios.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    No se encontraron cementerios
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <button
              class="pagination-button"
              @click="cambiarPagina(currentPage - 1)"
              :disabled="currentPage === 1"
            >
              <font-awesome-icon icon="chevron-left" />
              Anterior
            </button>
            <span class="pagination-info">
              P\u00e1gina {{ currentPage }} de {{ totalPages }}
            </span>
            <button
              class="pagination-button"
              @click="cambiarPagina(currentPage + 1)"
              :disabled="currentPage === totalPages"
            >
              Siguiente
              <font-awesome-icon icon="chevron-right" />
            </button>
          </div>
        </div>

        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-3">Cargando cementerios...</p>
        </div>
      </div>
    </div>

    <!-- Modal para Crear/Editar -->
    <div class="modal" :class="{ show: showModal }" @click.self="cerrarModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon :icon="modalMode === 'create' ? 'plus' : 'edit'" />
              {{ modalMode === 'create' ? 'Nuevo Cementerio' : 'Editar Cementerio' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarCementerio">
              <div class="form-group">
                <label class="municipal-form-label required">Cementerio</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.cementerio"
                  :disabled="modalMode === 'edit'"
                  maxlength="10"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Nombre</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.nombre"
                  maxlength="100"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Domicilio</label>
                <textarea
                  class="municipal-form-control"
                  v-model="formData.domicilio"
                  rows="3"
                  maxlength="200"
                  required
                ></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="cerrarModal"
            >
              Cancelar
            </button>
            <button
              type="button"
              class="btn-municipal-primary"
              @click="guardarCementerio"
              :disabled="guardando"
            >
              <span v-if="guardando" class="spinner-border spinner-border-sm me-2"></span>
              {{ guardando ? 'Guardando...' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Cat\u00e1logo de Cementerios"
    >
      <h6>Descripci\u00f3n</h6>
      <p>M\u00f3dulo para la gesti\u00f3n de cementerios municipales.</p>

      <h6>Funcionalidades</h6>
      <ul>
        <li>Alta de nuevos cementerios</li>
        <li>Modificaci\u00f3n de datos de cementerios existentes</li>
        <li>Baja de cementerios (s\u00f3lo si no tienen fosas asociadas)</li>
        <li>B\u00fasqueda por cementerio, nombre o domicilio</li>
      </ul>

      <h6>Instrucciones</h6>
      <ol>
        <li>Use el bot\u00f3n "Nuevo Cementerio" para registrar uno nuevo</li>
        <li>Haga clic en el icono de editar para modificar un cementerio</li>
        <li>Use el icono de eliminar para dar de baja (validar\u00e1 que no tenga fosas)</li>
        <li>Utilice el buscador para filtrar por cualquier campo</li>
      </ol>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ABCementer'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, onMounted, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const guardando = ref(false)
const cementerios = ref([])
const mostrarAyuda = ref(false)
const showModal = ref(false)
const modalMode = ref('create') // 'create' o 'edit'

// Paginaci\u00f3n
const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)

// B\u00fasqueda
const searchText = ref('')

// Formulario
const formData = ref({
  cementerio: '',
  nombre: '',
  domicilio: ''
})

// Computed
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))

// M\u00e9todos
const cargarCementerios = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_cem_listar_cementerios',
      'cementerios',
      {},
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      let data = response.result

      // Filtrar por búsqueda si hay texto de búsqueda
      if (searchText.value && searchText.value.trim()) {
        const search = searchText.value.toLowerCase()
        data = data.filter(c =>
          (c.cementerio && c.cementerio.toLowerCase().includes(search)) ||
          (c.nombre && c.nombre.toLowerCase().includes(search)) ||
          (c.direccion && c.direccion.toLowerCase().includes(search))
        )
      }

      totalRecords.value = data.length

      // Paginación manual del lado del cliente
      const start = (currentPage.value - 1) * pageSize.value
      const end = start + pageSize.value
      cementerios.value = data.slice(start, end)
    } else {
      cementerios.value = []
      totalRecords.value = 0
    }
  } catch (error) {
    showToast('Error al cargar cementerios: ' + error.message, 'error')
    cementerios.value = []
  } finally {
    loading.value = false
  }
}

const buscar = () => {
  currentPage.value = 1
  cargarCementerios()
}

const limpiarBusqueda = () => {
  searchText.value = ''
  currentPage.value = 1
  cargarCementerios()
}

const cambiarPagina = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    cargarCementerios()
  }
}

const openCreateModal = () => {
  modalMode.value = 'create'
  formData.value = {
    cementerio: '',
    nombre: '',
    domicilio: ''
  }
  showModal.value = true
}

const editarCementerio = async (cem) => {
  modalMode.value = 'edit'
  formData.value = {
    cementerio: cem.cementerio,
    nombre: cem.nombre,
    domicilio: cem.domicilio
  }
  showModal.value = true
}

const guardarCementerio = async () => {
  if (!formData.value.cementerio || !formData.value.nombre || !formData.value.domicilio) {
    showToast('Por favor complete todos los campos requeridos', 'warning')
    return
  }

  guardando.value = true
  try {
    const operacion = modalMode.value === 'create' ? 'A' : 'C'
    const response = await execute(
      'sp_cem_abc_cementerios',
      'cementerios',
      {
        p_operacion: operacion,
        p_cementerio: formData.value.cementerio,
        p_nombre: formData.value.nombre,
        p_domicilio: formData.value.domicilio,
        p_usuario: 1 // TODO: Obtener usuario actual del sistema
      },
      '',
      null,
      'comun'
    )

    if (response && response[0]) {
      const result = response.result[0]
      if (result.resultado === 'S') {
        showToast(result.mensaje, 'success')
        cerrarModal()
        cargarCementerios()
      } else {
        showToast(result.mensaje, 'error')
      }
    }
  } catch (error) {
    showToast('Error al guardar: ' + error.message, 'error')
  } finally {
    guardando.value = false
  }
}

const eliminarCementerio = async (cem) => {
  const result = await Swal.fire({
    title: '\u00bfEliminar Cementerio?',
    html: `\u00bfEst\u00e1 seguro que desea eliminar el cementerio <strong>${cem.nombre}</strong>?<br><small>Esta acci\u00f3n no se puede deshacer.</small>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'S\u00ed, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545'
  })

  if (result.isConfirmed) {
    try {
      const response = await execute(
      'sp_cem_abc_cementerios',
      'cementerios',
      {
          p_operacion: 'B',
          p_cementerio: cem.cementerio,
          p_nombre: '',
          p_domicilio: '',
          p_usuario: 1
        },
      '',
      null,
      'comun'
    )

      if (response && response[0]) {
        const result = response.result[0]
        if (result.resultado === 'S') {
          showToast(result.mensaje, 'success')
          cargarCementerios()
        } else {
          showToast(result.mensaje, 'error')
        }
      }
    } catch (error) {
      showToast('Error al eliminar: ' + error.message, 'error')
    }
  }
}

const cerrarModal = () => {
  showModal.value = false
  formData.value = {
    cementerio: '',
    nombre: '',
    domicilio: ''
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

// Inicializar
onMounted(() => {
  cargarCementerios()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
