import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

const axiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

axiosInstance.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error)
    return Promise.reject(error)
  }
)

export const apiService = {
  async execute(operacion, base, parametros = [], tenant = '', pagination = null) {
    try {
      const payload = {
        eRequest: {
          Operacion: operacion,
          Base: base,
          Parametros: parametros,
          Tenant: tenant
        }
      }

      if (pagination && (typeof pagination.limit !== 'undefined' || typeof pagination.offset !== 'undefined')) {
        payload.eRequest.Paginacion = {
          limit: pagination.limit ?? null,
          offset: pagination.offset ?? null
        }
      }

      const response = await axiosInstance.post('/api/generic', payload)

      return response.data.eResponse
    } catch (error) {
      if (error.response && error.response.data && error.response.data.eResponse) {
        throw new Error(error.response.data.eResponse.message || 'Error en la petición')
      }
      throw error
    }
  },

  async executeStoredProcedure(config) {
    const { operacion, base, parametros = [], tenant = '', pagination = null } = config
    return this.execute(operacion, base, parametros, tenant, pagination)
  }
}

export default apiService
