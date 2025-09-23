<template>
  <div class="generic-module-crud">
    <!-- Header -->
    <div class="module-header mb-4">
      <div class="row align-items-center">
        <div class="col">
          <h2 class="h4 mb-0">{{ moduleTitle }}</h2>
          <p class="text-muted small mb-0">{{ moduleDescription }}</p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-primary"
            @click="showCreateModal = true"
            :disabled="state.loading"
          >
            <i class="fas fa-plus me-2"></i>
            Crear Nuevo
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros y búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-6">
            <div class="input-group">
              <span class="input-group-text">
                <i class="fas fa-search"></i>
              </span>
              <input
                v-model="searchTerm"
                type="text"
                class="form-control"
                placeholder="Buscar..."
                @input="debouncedSearch"
              />
            </div>
          </div>
          <div class="col-md-3">
            <select
              v-model="statusFilter"
              class="form-select"
              @change="applyFilters"
            >
              <option value="">Todos los estados</option>
              <option value="active">Activo</option>
              <option value="inactive">Inactivo</option>
            </select>
          </div>
          <div class="col-md-3">
            <button
              class="btn btn-outline-secondary"
              @click="clearAllFilters"
              :disabled="state.loading"
            >
              <i class="fas fa-times me-2"></i>
              Limpiar Filtros
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Acciones masivas -->
    <div v-if="hasSelection" class="card mb-4">
      <div class="card-body">
        <div class="row align-items-center">
          <div class="col">
            <span class="text-muted">
              {{ totalSelected }} elemento(s) seleccionado(s)
            </span>
          </div>
          <div class="col-auto">
            <div class="btn-group">
              <button
                class="btn btn-sm btn-success"
                @click="bulkActivate"
                :disabled="state.loading"
              >
                <i class="fas fa-check me-1"></i>
                Activar
              </button>
              <button
                class="btn btn-sm btn-warning"
                @click="bulkDeactivate"
                :disabled="state.loading"
              >
                <i class="fas fa-pause me-1"></i>
                Desactivar
              </button>
              <button
                class="btn btn-sm btn-danger"
                @click="confirmBulkDelete"
                :disabled="state.loading"
              >
                <i class="fas fa-trash me-1"></i>
                Eliminar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de datos -->
    <div class="card">
      <div class="card-header">
        <div class="row align-items-center">
          <div class="col">
            <h6 class="mb-0">Registros</h6>
          </div>
          <div class="col-auto">
            <button
              class="btn btn-sm btn-outline-primary"
              @click="refresh"
              :disabled="state.loading"
            >
              <i class="fas fa-sync-alt me-1"></i>
              Actualizar
            </button>
          </div>
        </div>
      </div>
      
      <div class="card-body p-0">
        <!-- Loading -->
        <div v-if="state.loading && state.items.length === 0" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando datos...</p>
        </div>

        <!-- Error -->
        <div v-else-if="state.error" class="alert alert-danger m-3">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ state.error }}</p>
          <hr>
          <button class="btn btn-sm btn-outline-danger" @click="refresh">
            Reintentar
          </button>
        </div>

        <!-- Sin datos -->
        <div v-else-if="state.items.length === 0" class="text-center py-4">
          <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
          <h6 class="text-muted">No hay registros</h6>
          <p class="text-muted">
            No se encontraron registros con los filtros actuales.
          </p>
        </div>

        <!-- Tabla de datos -->
        <div v-else class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th style="width: 50px">
                  <input
                    type="checkbox"
                    class="form-check-input"
                    @change="toggleSelectAll"
                    :checked="state.items.length > 0 && totalSelected === state.items.length"
                    :indeterminate="totalSelected > 0 && totalSelected < state.items.length"
                  />
                </th>
                <th>ID</th>
                <th v-for="field in displayFields" :key="field.key">
                  {{ field.label }}
                </th>
                <th>Estado</th>
                <th>Fecha Creación</th>
                <th style="width: 120px">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in state.items" :key="item.id">
                <td>
                  <input
                    type="checkbox"
                    class="form-check-input"
                    :checked="state.selectedIds.has(item.id)"
                    @change="toggleSelection(item.id)"
                  />
                </td>
                <td>{{ item.id }}</td>
                <td v-for="field in displayFields" :key="field.key">
                  {{ getFieldValue(item, field.key) }}
                </td>
                <td>
                  <span
                    class="badge"
                    :class="{
                      'bg-success': item.status === 'active',
                      'bg-secondary': item.status === 'inactive'
                    }"
                  >
                    {{ item.status === 'active' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>{{ formatDate(item.created_at) }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn btn-outline-primary"
                      @click="viewItem(item)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-outline-secondary"
                      @click="editItem(item)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-outline-danger"
                      @click="confirmDelete(item)"
                      title="Eliminar"
                    >
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div v-if="state.pagination && state.pagination.last_page > 1" class="card-footer">
        <nav>
          <ul class="pagination pagination-sm mb-0 justify-content-center">
            <li class="page-item" :class="{ disabled: state.pagination.current_page <= 1 }">
              <button class="page-link" @click="prevPage" :disabled="state.pagination.current_page <= 1">
                Anterior
              </button>
            </li>
            
            <li
              v-for="page in visiblePages"
              :key="page"
              class="page-item"
              :class="{ active: page === state.pagination.current_page }"
            >
              <button class="page-link" @click="goToPage(page)">
                {{ page }}
              </button>
            </li>
            
            <li class="page-item" :class="{ disabled: state.pagination.current_page >= state.pagination.last_page }">
              <button class="page-link" @click="nextPage" :disabled="state.pagination.current_page >= state.pagination.last_page">
                Siguiente
              </button>
            </li>
          </ul>
        </nav>
        
        <div class="text-center text-muted small mt-2">
          Mostrando {{ state.items.length }} de {{ state.pagination.total }} registros
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div
      class="modal fade"
      :class="{ show: showCreateModal || showEditModal }"
      :style="{ display: showCreateModal || showEditModal ? 'block' : 'none' }"
      tabindex="-1"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ editingItem ? 'Editar Registro' : 'Crear Nuevo Registro' }}
            </h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          
          <div class="modal-body">
            <form @submit.prevent="saveItem">
              <div class="row g-3">
                <div v-for="field in formFields" :key="field.key" :class="field.colClass || 'col-md-6'">
                  <label :for="field.key" class="form-label">
                    {{ field.label }}
                    <span v-if="field.required" class="text-danger">*</span>
                  </label>
                  
                  <input
                    v-if="field.type === 'text' || field.type === 'email' || field.type === 'number'"
                    :id="field.key"
                    v-model="formData[field.key]"
                    :type="field.type"
                    class="form-control"
                    :placeholder="field.placeholder"
                    :required="field.required"
                  />
                  
                  <textarea
                    v-else-if="field.type === 'textarea'"
                    :id="field.key"
                    v-model="formData[field.key]"
                    class="form-control"
                    :placeholder="field.placeholder"
                    :required="field.required"
                    rows="3"
                  ></textarea>
                  
                  <select
                    v-else-if="field.type === 'select'"
                    :id="field.key"
                    v-model="formData[field.key]"
                    class="form-select"
                    :required="field.required"
                  >
                    <option value="">Seleccionar...</option>
                    <option
                      v-for="option in field.options"
                      :key="option.value"
                      :value="option.value"
                    >
                      {{ option.label }}
                    </option>
                  </select>
                </div>
              </div>
            </form>
          </div>
          
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="saveItem"
              :disabled="state.loading"
            >
              <i class="fas fa-save me-2"></i>
              {{ editingItem ? 'Actualizar' : 'Crear' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ver detalles -->
    <div
      class="modal fade"
      :class="{ show: showViewModal }"
      :style="{ display: showViewModal ? 'block' : 'none' }"
      tabindex="-1"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalles del Registro</h5>
            <button type="button" class="btn-close" @click="showViewModal = false"></button>
          </div>
          
          <div class="modal-body" v-if="viewingItem">
            <div class="row g-3">
              <div class="col-12">
                <h6>Información General</h6>
                <table class="table table-sm">
                  <tbody>
                    <tr>
                      <td><strong>ID:</strong></td>
                      <td>{{ viewingItem.id }}</td>
                    </tr>
                    <tr>
                      <td><strong>Estado:</strong></td>
                      <td>
                        <span
                          class="badge"
                          :class="{
                            'bg-success': viewingItem.status === 'active',
                            'bg-secondary': viewingItem.status === 'inactive'
                          }"
                        >
                          {{ viewingItem.status === 'active' ? 'Activo' : 'Inactivo' }}
                        </span>
                      </td>
                    </tr>
                    <tr>
                      <td><strong>Fecha Creación:</strong></td>
                      <td>{{ formatDate(viewingItem.created_at) }}</td>
                    </tr>
                    <tr>
                      <td><strong>Fecha Actualización:</strong></td>
                      <td>{{ formatDate(viewingItem.updated_at) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              
              <div class="col-12" v-if="viewingItem.data">
                <h6>Datos del Registro</h6>
                <pre class="bg-light p-3 rounded">{{ JSON.stringify(viewingItem.data, null, 2) }}</pre>
              </div>
            </div>
          </div>
          
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showViewModal = false">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Backdrop para modales -->
    <div
      v-if="showCreateModal || showEditModal || showViewModal"
      class="modal-backdrop fade show"
      @click="closeModal"
    ></div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, watch, nextTick } from 'vue'
import { useModuleCrud } from '@/composables/useModuleCrud'

export default {
  name: 'GenericModuleCrud',
  
  props: {
    moduleName: {
      type: String,
      required: true
    },
    moduleTitle: {
      type: String,
      default: 'Módulo'
    },
    moduleDescription: {
      type: String,
      default: 'Gestión de registros del módulo'
    },
    displayFields: {
      type: Array,
      default: () => [
        { key: 'name', label: 'Nombre' },
        { key: 'description', label: 'Descripción' }
      ]
    },
    formFields: {
      type: Array,
      default: () => [
        { key: 'name', label: 'Nombre', type: 'text', required: true, colClass: 'col-md-6' },
        { key: 'description', label: 'Descripción', type: 'textarea', colClass: 'col-md-6' }
      ]
    }
  },
  
  setup(props) {
    // CRUD composable
    const crud = useModuleCrud(props.moduleName)
    const { state, loadItems, createItem, updateItem, deleteItem, bulkDelete, bulkStatusChange } = crud
    
    // Reactive data
    const searchTerm = ref('')
    const statusFilter = ref('')
    
    // Modales
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const showViewModal = ref(false)
    
    const editingItem = ref(null)
    const viewingItem = ref(null)
    const formData = reactive({})
    
    // Búsqueda con debounce
    let searchTimeout = null
    const debouncedSearch = () => {
      clearTimeout(searchTimeout)
      searchTimeout = setTimeout(() => {
        crud.search(searchTerm.value)
      }, 500)
    }
    
    // Filtros
    const applyFilters = () => {
      const filters = {}
      if (statusFilter.value) {
        filters.status = statusFilter.value
      }
      crud.setFilters(filters)
    }
    
    const clearAllFilters = () => {
      searchTerm.value = ''
      statusFilter.value = ''
      crud.clearFilters()
    }
    
    // Computed
    const { hasSelection, totalSelected, selectedItems } = crud
    
    const visiblePages = computed(() => {
      if (!state.pagination) return []
      
      const current = state.pagination.current_page
      const total = state.pagination.last_page
      const pages = []
      
      for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages.push(i)
      }
      
      return pages
    })
    
    // Métodos
    const refresh = () => {
      crud.refresh()
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      return new Date(dateString).toLocaleDateString('es-ES', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    const getFieldValue = (item, key) => {
      if (key.includes('.')) {
        return key.split('.').reduce((obj, prop) => obj?.[prop], item.data) || 'N/A'
      }
      return item.data?.[key] || 'N/A'
    }
    
    // Operaciones CRUD
    const resetFormData = () => {
      props.formFields.forEach(field => {
        formData[field.key] = field.default || ''
      })
    }
    
    const viewItem = (item) => {
      viewingItem.value = item
      showViewModal.value = true
    }
    
    const editItem = (item) => {
      editingItem.value = item
      
      // Llenar el formulario con los datos del item
      props.formFields.forEach(field => {
        formData[field.key] = getFieldValue(item, field.key)
      })
      
      showEditModal.value = true
    }
    
    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      showViewModal.value = false
      editingItem.value = null
      resetFormData()
    }
    
    const saveItem = async () => {
      try {
        let result
        
        if (editingItem.value) {
          result = await updateItem(editingItem.value.id, formData)
        } else {
          result = await createItem(formData)
        }
        
        if (result.success) {
          closeModal()
          // Mostrar mensaje de éxito (puedes usar toast o alert)
          alert(result.message)
        } else {
          alert(result.error)
        }
      } catch (error) {
        alert('Error inesperado al guardar el registro')
      }
    }
    
    const confirmDelete = (item) => {
      if (confirm(`¿Estás seguro de eliminar el registro ${item.id}?`)) {
        deleteItem(item.id)
      }
    }
    
    const confirmBulkDelete = () => {
      if (confirm(`¿Estás seguro de eliminar ${totalSelected.value} registros?`)) {
        bulkDelete()
      }
    }
    
    const bulkActivate = () => {
      bulkStatusChange('active')
    }
    
    const bulkDeactivate = () => {
      bulkStatusChange('inactive')
    }
    
    // Inicializar form data
    onMounted(() => {
      resetFormData()
    })
    
    // Watch para crear modal
    watch(showCreateModal, (newVal) => {
      if (newVal) {
        resetFormData()
      }
    })
    
    return {
      // Estado
      state,
      searchTerm,
      statusFilter,
      
      // Modales
      showCreateModal,
      showEditModal,
      showViewModal,
      editingItem,
      viewingItem,
      formData,
      
      // Computed
      hasSelection,
      totalSelected,
      selectedItems,
      visiblePages,
      
      // Métodos
      debouncedSearch,
      applyFilters,
      clearAllFilters,
      refresh,
      formatDate,
      getFieldValue,
      
      // CRUD
      viewItem,
      editItem,
      closeModal,
      saveItem,
      confirmDelete,
      confirmBulkDelete,
      bulkActivate,
      bulkDeactivate,
      
      // Del composable
      ...crud
    }
  }
}
</script>

<style scoped>
.generic-module-crud {
  padding: 1rem;
}

.modal.show {
  display: block !important;
}

.table th {
  border-top: none;
  background-color: #f8f9fa;
  font-weight: 600;
  font-size: 0.875rem;
}

.btn-group-sm .btn {
  padding: 0.25rem 0.5rem;
}

.badge {
  font-size: 0.75rem;
}

.pagination-sm .page-link {
  padding: 0.25rem 0.5rem;
}

pre {
  font-size: 0.875rem;
  max-height: 300px;
  overflow-y: auto;
}

.form-check-input:indeterminate {
  background-color: #0d6efd;
  border-color: #0d6efd;
}
</style>