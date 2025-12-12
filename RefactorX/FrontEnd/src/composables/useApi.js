import { ref } from 'vue'
import apiService from '@/services/apiService'

// Esquema por defecto para todas las llamadas API
export const DEFAULT_SCHEMA = 'publico'

export function useApi() {
  const loading = ref(false)
  const error = ref(null)
  const data = ref(null)

  const execute = async (operacion, base, parametros = [], tenant = '', pagination = null, esquema = DEFAULT_SCHEMA) => {
    loading.value = true
    error.value = null
    data.value = null

    try {
      const response = await apiService.execute(operacion, base, parametros, tenant, pagination, esquema)

      if (response.success) {
        data.value = response.data
        return response.data
      } else {
        error.value = response.message
        throw new Error(response.message)
      }
    } catch (err) {
      error.value = err.message || 'Error desconocido'
      throw err
    } finally {
      loading.value = false
    }
  }

  const reset = () => {
    loading.value = false
    error.value = null
    data.value = null
  }

  return {
    loading,
    error,
    data,
    execute,
    reset
  }
}
