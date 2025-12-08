import { ref } from 'vue'

// Estado global compartido entre todos los componentes
const isLoading = ref(false)
const loadingMessage = ref('Cargando...')
const loadingSubMessage = ref('')

export function useGlobalLoading() {
  /**
   * Muestra el loading global
   * @param {string} message - Mensaje principal (default: 'Cargando...')
   * @param {string} subMessage - Mensaje secundario opcional
   */
  const showLoading = (message = 'Cargando...', subMessage = '') => {
    loadingMessage.value = message
    loadingSubMessage.value = subMessage
    isLoading.value = true
  }

  /**
   * Oculta el loading global
   */
  const hideLoading = () => {
    isLoading.value = false
  }

  /**
   * Ejecuta una función async con loading automático
   * @param {Function} asyncFn - Función async a ejecutar
   * @param {string} message - Mensaje del loading
   * @param {string} subMessage - Submensaje del loading
   * @returns {Promise} - Resultado de la función
   */
  const withLoading = async (asyncFn, message = 'Procesando...', subMessage = 'Por favor espere') => {
    showLoading(message, subMessage)
    try {
      return await asyncFn()
    } finally {
      hideLoading()
    }
  }

  return {
    isLoading,
    loadingMessage,
    loadingSubMessage,
    showLoading,
    hideLoading,
    withLoading
  }
}
