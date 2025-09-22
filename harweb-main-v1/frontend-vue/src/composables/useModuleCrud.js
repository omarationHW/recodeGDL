import { ref, reactive, computed, watch } from 'vue'
import { createModuleService } from '@/services/api'

export function useModuleCrud(moduleName, options = {}) {
  // Estado reactivo
  const state = reactive({
    items: [],
    currentItem: null,
    loading: false,
    error: null,
    pagination: null,
    filters: {},
    selectedIds: new Set(),
    searchTerm: ''
  })

  // Configuración
  const config = reactive({
    autoLoad: options.autoLoad !== false,
    pageSize: options.pageSize || 15,
    debounceMs: options.debounceMs || 500,
    ...options
  })

  // Servicio API
  const apiService = createModuleService(moduleName)

  // Computed properties
  const hasSelection = computed(() => state.selectedIds.size > 0)
  const selectedItems = computed(() => 
    state.items.filter(item => state.selectedIds.has(item.id))
  )
  const totalSelected = computed(() => state.selectedIds.size)

  // Funciones principales CRUD
  const loadItems = async (filters = {}) => {
    state.loading = true
    state.error = null

    try {
      const finalFilters = { 
        ...state.filters, 
        ...filters,
        per_page: config.pageSize
      }

      if (state.searchTerm) {
        finalFilters.search = state.searchTerm
      }

      const result = await apiService.getAll(finalFilters)
      
      if (result.success) {
        state.items = result.data
        state.pagination = result.pagination
      } else {
        state.error = result.error
        console.error('Error loading items:', result)
      }
    } catch (error) {
      state.error = 'Error inesperado al cargar los datos'
      console.error('Unexpected error:', error)
    } finally {
      state.loading = false
    }
  }

  const loadItem = async (id) => {
    state.loading = true
    state.error = null

    try {
      const result = await apiService.getById(id)
      
      if (result.success) {
        state.currentItem = result.data
        return result.data
      } else {
        state.error = result.error
        return null
      }
    } catch (error) {
      state.error = 'Error inesperado al cargar el registro'
      console.error('Unexpected error:', error)
      return null
    } finally {
      state.loading = false
    }
  }

  const createItem = async (data) => {
    state.loading = true
    state.error = null

    try {
      const result = await apiService.create(data)
      
      if (result.success) {
        await loadItems() // Recargar la lista
        return { success: true, data: result.data, message: result.message }
      } else {
        state.error = result.error
        return { success: false, error: result.error, errors: result.errors }
      }
    } catch (error) {
      const errorMsg = 'Error inesperado al crear el registro'
      state.error = errorMsg
      console.error('Unexpected error:', error)
      return { success: false, error: errorMsg }
    } finally {
      state.loading = false
    }
  }

  const updateItem = async (id, data) => {
    state.loading = true
    state.error = null

    try {
      const result = await apiService.update(id, data)
      
      if (result.success) {
        // Actualizar el item en la lista local
        const index = state.items.findIndex(item => item.id === id)
        if (index !== -1) {
          state.items[index] = result.data
        }
        
        // Actualizar currentItem si coincide
        if (state.currentItem?.id === id) {
          state.currentItem = result.data
        }
        
        return { success: true, data: result.data, message: result.message }
      } else {
        state.error = result.error
        return { success: false, error: result.error, errors: result.errors }
      }
    } catch (error) {
      const errorMsg = 'Error inesperado al actualizar el registro'
      state.error = errorMsg
      console.error('Unexpected error:', error)
      return { success: false, error: errorMsg }
    } finally {
      state.loading = false
    }
  }

  const deleteItem = async (id) => {
    state.loading = true
    state.error = null

    try {
      const result = await apiService.delete(id)
      
      if (result.success) {
        // Remover el item de la lista local
        state.items = state.items.filter(item => item.id !== id)
        
        // Limpiar currentItem si coincide
        if (state.currentItem?.id === id) {
          state.currentItem = null
        }
        
        // Remover de selección
        state.selectedIds.delete(id)
        
        return { success: true, message: result.message }
      } else {
        state.error = result.error
        return { success: false, error: result.error }
      }
    } catch (error) {
      const errorMsg = 'Error inesperado al eliminar el registro'
      state.error = errorMsg
      console.error('Unexpected error:', error)
      return { success: false, error: errorMsg }
    } finally {
      state.loading = false
    }
  }

  // Funciones de selección
  const toggleSelection = (id) => {
    if (state.selectedIds.has(id)) {
      state.selectedIds.delete(id)
    } else {
      state.selectedIds.add(id)
    }
  }

  const selectAll = () => {
    state.items.forEach(item => state.selectedIds.add(item.id))
  }

  const clearSelection = () => {
    state.selectedIds.clear()
  }

  const toggleSelectAll = () => {
    if (state.selectedIds.size === state.items.length) {
      clearSelection()
    } else {
      selectAll()
    }
  }

  // Operaciones masivas
  const bulkDelete = async () => {
    if (state.selectedIds.size === 0) return { success: false, error: 'No hay elementos seleccionados' }

    state.loading = true
    state.error = null

    try {
      const ids = Array.from(state.selectedIds)
      const result = await apiService.bulkAction('delete', ids)
      
      if (result.success) {
        // Remover items eliminados de la lista local
        state.items = state.items.filter(item => !state.selectedIds.has(item.id))
        clearSelection()
        
        return { success: true, message: result.message, affectedCount: result.affectedCount }
      } else {
        state.error = result.error
        return { success: false, error: result.error }
      }
    } catch (error) {
      const errorMsg = 'Error inesperado en la eliminación masiva'
      state.error = errorMsg
      console.error('Unexpected error:', error)
      return { success: false, error: errorMsg }
    } finally {
      state.loading = false
    }
  }

  const bulkStatusChange = async (status) => {
    if (state.selectedIds.size === 0) return { success: false, error: 'No hay elementos seleccionados' }

    state.loading = true
    state.error = null

    try {
      const ids = Array.from(state.selectedIds)
      const action = status === 'active' ? 'activate' : 'deactivate'
      const result = await apiService.bulkAction(action, ids)
      
      if (result.success) {
        // Actualizar el status en la lista local
        state.items.forEach(item => {
          if (state.selectedIds.has(item.id)) {
            item.status = status
          }
        })
        
        clearSelection()
        
        return { success: true, message: result.message, affectedCount: result.affectedCount }
      } else {
        state.error = result.error
        return { success: false, error: result.error }
      }
    } catch (error) {
      const errorMsg = 'Error inesperado al cambiar el estado'
      state.error = errorMsg
      console.error('Unexpected error:', error)
      return { success: false, error: errorMsg }
    } finally {
      state.loading = false
    }
  }

  // Funciones de filtrado y búsqueda
  const setFilters = (newFilters) => {
    Object.assign(state.filters, newFilters)
    loadItems()
  }

  const clearFilters = () => {
    state.filters = {}
    state.searchTerm = ''
    loadItems()
  }

  const search = (term) => {
    state.searchTerm = term
    loadItems()
  }

  // Funciones de paginación
  const goToPage = (page) => {
    setFilters({ page })
  }

  const nextPage = () => {
    if (state.pagination && state.pagination.current_page < state.pagination.last_page) {
      goToPage(state.pagination.current_page + 1)
    }
  }

  const prevPage = () => {
    if (state.pagination && state.pagination.current_page > 1) {
      goToPage(state.pagination.current_page - 1)
    }
  }

  // Auto-cargar si está habilitado
  if (config.autoLoad) {
    loadItems()
  }

  // Retornar API del composable
  return {
    // Estado
    state,
    config,
    
    // Computed
    hasSelection,
    selectedItems,
    totalSelected,
    
    // CRUD principal
    loadItems,
    loadItem,
    createItem,
    updateItem,
    deleteItem,
    
    // Selección
    toggleSelection,
    selectAll,
    clearSelection,
    toggleSelectAll,
    
    // Operaciones masivas
    bulkDelete,
    bulkStatusChange,
    
    // Filtrado y búsqueda
    setFilters,
    clearFilters,
    search,
    
    // Paginación
    goToPage,
    nextPage,
    prevPage,
    
    // Utilidades
    refresh: () => loadItems(),
    reset: () => {
      state.items = []
      state.currentItem = null
      state.error = null
      state.pagination = null
      clearSelection()
      clearFilters()
    }
  }
}