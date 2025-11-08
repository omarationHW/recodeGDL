<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-ul" />
      </div>
      <div class="module-view-info">
        <h1>Selección de Giros</h1>
        <p>Padrón de Licencias - Diálogo de Selección de Giros</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openSelectionDialog"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Abrir Selector
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Giros seleccionados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-square" />
          Giros Seleccionados
          <span class="badge-info" v-if="selectedGiros.length > 0">{{ selectedGiros.length }} giros</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div v-if="selectedGiros.length === 0" class="empty-state">
          <font-awesome-icon icon="list-ul" size="2x" class="empty-icon" />
          <p>No hay giros seleccionados. Haga clic en "Abrir Selector" para agregar giros.</p>
        </div>

        <div v-else class="selected-giros-list">
          <div
            v-for="giro in selectedGiros"
            :key="giro.id"
            class="selected-giro-item"
          >
            <div class="giro-info">
              <span class="giro-code">{{ giro.codigo }}</span>
              <span class="giro-name">{{ giro.nombre }}</span>
              <span v-if="giro.categoria" class="badge-secondary">{{ giro.categoria }}</span>
            </div>
            <button
              class="btn-municipal-danger btn-sm"
              @click="removeGiro(giro)"
              title="Eliminar"
            >
              <font-awesome-icon icon="times" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Búsqueda rápida -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Búsqueda Rápida de Giros
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Buscar por código o nombre</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="searchQuery"
              @input="searchGiros"
              placeholder="Ingrese código o nombre del giro..."
            >
          </div>
        </div>

        <div v-if="searchResults.length > 0" class="search-results">
          <h6>Resultados de búsqueda:</h6>
          <div class="results-list">
            <div
              v-for="giro in searchResults"
              :key="giro.id"
              class="result-item"
              :class="{ 'selected': isGiroSelected(giro.id) }"
            >
              <div class="result-info">
                <span class="giro-code">{{ giro.codigo }}</span>
                <span class="giro-name">{{ giro.nombre }}</span>
                <span v-if="giro.categoria" class="badge-secondary">{{ giro.categoria }}</span>
              </div>
              <button
                v-if="!isGiroSelected(giro.id)"
                class="btn-municipal-primary btn-sm"
                @click="addGiroFromSearch(giro)"
              >
                <font-awesome-icon icon="plus" />
                Agregar
              </button>
              <button
                v-else
                class="btn-municipal-secondary btn-sm"
                disabled
              >
                <font-awesome-icon icon="check" />
                Seleccionado
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando giros...</p>
      </div>
    </div>

    <!-- Modal de selección de giros -->
    <Modal
      :show="showSelectionDialog"
      title="Seleccionar Giros"
      size="xl"
      @close="showSelectionDialog = false"
      @confirm="confirmSelection"
      confirmText="Confirmar Selección"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <div class="giro-selector">
        <!-- Búsqueda dentro del modal -->
        <div class="modal-search">
          <div class="form-group">
            <label class="municipal-form-label">Buscar Giro:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="modalSearchQuery"
              @input="searchGirosInModal"
              placeholder="Buscar por código o nombre..."
            >
          </div>
        </div>

        <!-- Árbol de categorías -->
        <div class="categories-tree">
          <div v-if="!modalSearchQuery" class="tree-view">
            <div
              v-for="categoria in categorias"
              :key="categoria.id"
              class="category-node"
            >
              <div
                class="category-header"
                @click="toggleCategory(categoria.id)"
              >
                <font-awesome-icon
                  :icon="categoria.expanded ? 'chevron-down' : 'chevron-right'"
                  class="expand-icon"
                />
                <font-awesome-icon icon="folder" class="category-icon" />
                <span class="category-name">{{ categoria.nombre }}</span>
                <span class="badge-info">{{ categoria.giros?.length || 0 }} giros</span>
              </div>

              <div v-if="categoria.expanded" class="category-giros">
                <div
                  v-for="giro in categoria.giros"
                  :key="giro.id"
                  class="giro-item"
                >
                  <label class="giro-checkbox">
                    <input
                      type="checkbox"
                      :value="giro.id"
                      :checked="isGiroSelected(giro.id)"
                      @change="toggleGiroSelection(giro)"
                    >
                    <span class="giro-code">{{ giro.codigo }}</span>
                    <span class="giro-name">{{ giro.nombre }}</span>
                  </label>
                </div>
              </div>
            </div>
          </div>

          <!-- Resultados de búsqueda en modal -->
          <div v-else class="modal-search-results">
            <p class="results-count">
              {{ modalSearchResults.length }} resultados encontrados
            </p>
            <div class="results-list">
              <div
                v-for="giro in modalSearchResults"
                :key="giro.id"
                class="giro-item"
              >
                <label class="giro-checkbox">
                  <input
                    type="checkbox"
                    :value="giro.id"
                    :checked="isGiroSelected(giro.id)"
                    @change="toggleGiroSelection(giro)"
                  >
                  <span class="giro-code">{{ giro.codigo }}</span>
                  <span class="giro-name">{{ giro.nombre }}</span>
                  <span v-if="giro.categoria" class="badge-secondary">{{ giro.categoria }}</span>
                </label>
              </div>
            </div>
          </div>
        </div>

        <!-- Resumen de selección -->
        <div class="selection-summary">
          <strong>Giros seleccionados en este diálogo:</strong>
          <span class="badge-primary">{{ tempSelectedGiros.length }}</span>
        </div>
      </div>
    </Modal>

    <!-- Toast Notification -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'grs_dlg'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const selectedGiros = ref([])
const tempSelectedGiros = ref([])
const categorias = ref([])
const searchQuery = ref('')
const searchResults = ref([])
const modalSearchQuery = ref('')
const modalSearchResults = ref([])
const showSelectionDialog = ref(false)
let searchTimeout = null

// Métodos
const loadGiros = async () => {
  setLoading(true, 'Cargando catálogo de giros...')

  try {
    const response = await execute(
      'grs_dlg_sp_get_giros',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      // Agrupar giros por categoría
      const girosData = response.result
      const categoriasMap = new Map()

      girosData.forEach(giro => {
        const catNombre = giro.categoria || 'Sin categoría'
        if (!categoriasMap.has(catNombre)) {
          categoriasMap.set(catNombre, {
            id: catNombre,
            nombre: catNombre,
            giros: [],
            expanded: false
          })
        }
        categoriasMap.get(catNombre).giros.push(giro)
      })

      categorias.value = Array.from(categoriasMap.values())
      showToast('success', 'Catálogo de giros cargado correctamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const searchGiros = () => {
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }

  searchTimeout = setTimeout(async () => {
    if (!searchQuery.value || searchQuery.value.length < 2) {
      searchResults.value = []
      return
    }

    try {
      const response = await execute(
        'grs_dlg_sp_search_giros',
        'padron_licencias',
        [
          { nombre: 'p_search', valor: searchQuery.value, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        searchResults.value = response.result
      }
    } catch (error) {
      handleApiError(error)
    }
  }, 500)
}

const searchGirosInModal = () => {
  if (!modalSearchQuery.value || modalSearchQuery.value.length < 2) {
    modalSearchResults.value = []
    return
  }

  // Buscar en todas las categorías
  const results = []
  categorias.value.forEach(categoria => {
    categoria.giros.forEach(giro => {
      const searchLower = modalSearchQuery.value.toLowerCase()
      if (
        giro.codigo?.toLowerCase().includes(searchLower) ||
        giro.nombre?.toLowerCase().includes(searchLower)
      ) {
        results.push({
          ...giro,
          categoria: categoria.nombre
        })
      }
    })
  })

  modalSearchResults.value = results
}

const openSelectionDialog = () => {
  tempSelectedGiros.value = [...selectedGiros.value]
  modalSearchQuery.value = ''
  modalSearchResults.value = []
  showSelectionDialog.value = true
}

const confirmSelection = () => {
  selectedGiros.value = [...tempSelectedGiros.value]
  showSelectionDialog.value = false
  showToast('success', `${selectedGiros.value.length} giros seleccionados`)
}

const toggleCategory = (categoryId) => {
  const categoria = categorias.value.find(c => c.id === categoryId)
  if (categoria) {
    categoria.expanded = !categoria.expanded
  }
}

const isGiroSelected = (giroId) => {
  return tempSelectedGiros.value.some(g => g.id === giroId)
}

const toggleGiroSelection = (giro) => {
  const index = tempSelectedGiros.value.findIndex(g => g.id === giro.id)
  if (index > -1) {
    tempSelectedGiros.value.splice(index, 1)
  } else {
    tempSelectedGiros.value.push(giro)
  }
}

const addGiroFromSearch = (giro) => {
  if (!isGiroSelected(giro.id)) {
    selectedGiros.value.push(giro)
    showToast('success', 'Giro agregado')
  }
}

const removeGiro = async (giro) => {
  const result = await Swal.fire({
    title: '¿Eliminar giro?',
    text: `¿Está seguro de eliminar "${giro.nombre}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    const index = selectedGiros.value.findIndex(g => g.id === giro.id)
    if (index > -1) {
      selectedGiros.value.splice(index, 1)
      showToast('success', 'Giro eliminado')
    }
  }
}

// Lifecycle
onMounted(() => {
  loadGiros()
})

onBeforeUnmount(() => {
  showSelectionDialog.value = false
})
</script>

<style scoped>
.selected-giros-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.selected-giro-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 4px;
  border-left: 3px solid #ea8215;
}

.giro-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.giro-code {
  font-family: monospace;
  font-weight: bold;
  color: #ea8215;
  min-width: 80px;
}

.giro-name {
  flex: 1;
  color: #333;
}

.search-results {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.search-results h6 {
  margin-bottom: 0.75rem;
  color: #495057;
}

.results-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-height: 400px;
  overflow-y: auto;
}

.result-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  transition: all 0.2s;
}

.result-item:hover {
  border-color: #ea8215;
  box-shadow: 0 2px 4px rgba(234, 130, 21, 0.1);
}

.result-item.selected {
  background: #fff3e0;
  border-color: #ea8215;
}

.result-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.giro-selector {
  min-height: 500px;
}

.modal-search {
  margin-bottom: 1.5rem;
}

.categories-tree {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 1rem;
  background: #f8f9fa;
}

.category-node {
  margin-bottom: 1rem;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.category-header:hover {
  background: #e9ecef;
}

.expand-icon {
  color: #6c757d;
  width: 12px;
}

.category-icon {
  color: #ea8215;
}

.category-name {
  flex: 1;
  font-weight: bold;
  color: #333;
}

.category-giros {
  margin-top: 0.5rem;
  margin-left: 2rem;
  padding-left: 1rem;
  border-left: 2px solid #dee2e6;
}

.giro-item {
  padding: 0.5rem 0;
}

.giro-checkbox {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 4px;
  transition: background 0.2s;
}

.giro-checkbox:hover {
  background: rgba(234, 130, 21, 0.1);
}

.giro-checkbox input[type="checkbox"] {
  cursor: pointer;
  width: 18px;
  height: 18px;
}

.modal-search-results .results-count {
  margin-bottom: 1rem;
  font-weight: bold;
  color: #495057;
}

.selection-summary {
  margin-top: 1.5rem;
  padding: 1rem;
  background: #e7f3ff;
  border-radius: 4px;
  text-align: center;
  font-size: 1.1rem;
}

.selection-summary .badge-primary {
  font-size: 1.2rem;
  margin-left: 0.5rem;
}

.empty-state {
  text-align: center;
  padding: 3rem 2rem;
  color: #6c757d;
}

.empty-icon {
  color: #dee2e6;
  margin-bottom: 1rem;
}
</style>
