import axios from 'axios'

// Configuración base de Axios
const apiClient = axios.create({
  baseURL: 'http://localhost:8000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// Interceptor para manejar errores globalmente
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message)
    return Promise.reject(error)
  }
)

// Servicio genérico para CRUD de módulos
class ModuleApiService {
  constructor(moduleName) {
    this.moduleName = moduleName
    this.baseEndpoint = `/modules/${moduleName}/data`
  }

  // Obtener todos los registros con filtros opcionales
  async getAll(filters = {}) {
    try {
      const params = new URLSearchParams()
      
      Object.keys(filters).forEach(key => {
        if (filters[key] !== null && filters[key] !== undefined && filters[key] !== '') {
          params.append(key, filters[key])
        }
      })
      
      const response = await apiClient.get(
        `${this.baseEndpoint}${params.toString() ? '?' + params.toString() : ''}`
      )
      
      return {
        success: true,
        data: response.data.data || [],
        pagination: response.data.pagination || null
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Error al obtener los datos',
        details: error.response?.data
      }
    }
  }

  // Obtener un registro por ID
  async getById(id) {
    try {
      const response = await apiClient.get(`${this.baseEndpoint}/${id}`)
      
      return {
        success: true,
        data: response.data.data
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Error al obtener el registro',
        details: error.response?.data
      }
    }
  }

  // Crear un nuevo registro
  async create(data) {
    try {
      const response = await apiClient.post(this.baseEndpoint, {
        data: data,
        status: 'active'
      })
      
      return {
        success: true,
        data: response.data.data,
        message: response.data.message || 'Registro creado exitosamente'
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Error al crear el registro',
        details: error.response?.data,
        errors: error.response?.data?.errors
      }
    }
  }

  // Actualizar un registro existente
  async update(id, data) {
    try {
      const response = await apiClient.put(`${this.baseEndpoint}/${id}`, {
        data: data
      })
      
      return {
        success: true,
        data: response.data.data,
        message: response.data.message || 'Registro actualizado exitosamente'
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Error al actualizar el registro',
        details: error.response?.data,
        errors: error.response?.data?.errors
      }
    }
  }

  // Eliminar un registro
  async delete(id) {
    try {
      const response = await apiClient.delete(`${this.baseEndpoint}/${id}`)
      
      return {
        success: true,
        message: response.data.message || 'Registro eliminado exitosamente'
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Error al eliminar el registro',
        details: error.response?.data
      }
    }
  }

  // Operaciones masivas
  async bulkAction(action, ids) {
    try {
      const response = await apiClient.post(`${this.baseEndpoint}/bulk`, {
        action: action,
        ids: ids
      })
      
      return {
        success: true,
        message: response.data.message || 'Operación completada exitosamente',
        affectedCount: response.data.affected_count || 0
      }
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Error en la operación masiva',
        details: error.response?.data
      }
    }
  }

  // Cambiar estado de un registro
  async changeStatus(id, status) {
    return this.update(id, { status })
  }

  // Buscar registros
  async search(searchTerm, filters = {}) {
    return this.getAll({
      ...filters,
      search: searchTerm
    })
  }
}

// Factory para crear servicios de módulos específicos
const createModuleService = (moduleName) => {
  return new ModuleApiService(moduleName)
}

// Servicios predefinidos para los módulos principales
const moduleServices = {
  licencias: createModuleService('licencias'),
  apremios: createModuleService('apremios'),
  aseo: createModuleService('aseo'),
  cementerios: createModuleService('cementerios'),
  convenios: createModuleService('convenios'),
  estacionamientos: createModuleService('estacionamientos'),
  mercados: createModuleService('mercados'),
  otrasOblig: createModuleService('otras-oblig'),
  recaudadora: createModuleService('recaudadora'),
  tramiteTrunk: createModuleService('tramite-trunk')
}

export { 
  apiClient, 
  ModuleApiService, 
  createModuleService, 
  moduleServices 
}

export default moduleServices