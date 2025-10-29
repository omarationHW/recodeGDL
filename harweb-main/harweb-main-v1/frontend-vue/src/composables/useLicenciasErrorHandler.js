/**
 * =======================================================
 * LICENCIAS ERROR HANDLER COMPOSABLE
 * =======================================================
 * Composable para manejo centralizado de errores, loading states
 * y notificaciones para los componentes del módulo de licencias
 * =======================================================
 */

import { ref, reactive } from 'vue'

export function useLicenciasErrorHandler() {
  // Estados de carga
  const loading = ref(false)
  const loadingMessage = ref('Cargando...')

  // Estados de error
  const error = ref('')
  const validationErrors = reactive({})

  // Estados de toast/notificaciones
  const toast = reactive({
    show: false,
    type: 'info', // 'success', 'error', 'warning', 'info'
    message: '',
    timeout: null
  })

  // Estados de SweetAlert
  const sweetAlert = reactive({
    show: false,
    type: 'info', // 'success', 'error', 'warning', 'question'
    title: '',
    text: '',
    showCancelButton: false,
    confirmButtonText: 'Aceptar',
    cancelButtonText: 'Cancelar',
    backdrop: true,
    onConfirm: () => {},
    onCancel: () => {}
  })

  /**
   * Establece el estado de carga
   */
  const setLoading = (isLoading, message = 'Cargando...') => {
    loading.value = isLoading
    loadingMessage.value = message
    if (!isLoading) {
      error.value = '' // Limpiar errores al terminar carga
    }
  }

  /**
   * Establece un error
   */
  const setError = (errorMessage) => {
    error.value = errorMessage
    console.error('Error Handler:', errorMessage)
  }

  /**
   * Limpia todos los errores
   */
  const clearErrors = () => {
    error.value = ''
    Object.keys(validationErrors).forEach(key => {
      delete validationErrors[key]
    })
  }

  /**
   * Establece errores de validación
   */
  const setValidationError = (field, message) => {
    validationErrors[field] = message
  }

  /**
   * Limpia un error de validación específico
   */
  const clearValidationError = (field) => {
    delete validationErrors[field]
  }

  /**
   * Muestra una notificación toast
   */
  const showToast = (type, message, duration = 5000) => {
    // Limpiar timeout previo si existe
    if (toast.timeout) {
      clearTimeout(toast.timeout)
    }

    toast.show = true
    toast.type = type
    toast.message = message

    // Auto-ocultar el toast
    toast.timeout = setTimeout(() => {
      hideToast()
    }, duration)
  }

  /**
   * Oculta la notificación toast
   */
  const hideToast = () => {
    toast.show = false
    if (toast.timeout) {
      clearTimeout(toast.timeout)
      toast.timeout = null
    }
  }

  /**
   * Muestra un SweetAlert y retorna una promesa
   */
  const showSweetAlert = (options) => {
    return new Promise((resolve) => {
      sweetAlert.show = true
      sweetAlert.type = options.type || 'info'
      sweetAlert.title = options.title || ''
      sweetAlert.text = options.text || ''
      sweetAlert.showCancelButton = options.showCancelButton || false
      sweetAlert.confirmButtonText = options.confirmButtonText || 'Aceptar'
      sweetAlert.cancelButtonText = options.cancelButtonText || 'Cancelar'
      sweetAlert.backdrop = options.backdrop !== false

      sweetAlert.onConfirm = () => {
        resolve(true)
        closeSweetAlert()
      }

      sweetAlert.onCancel = () => {
        resolve(false)
        closeSweetAlert()
      }
    })
  }

  /**
   * Cierra el SweetAlert
   */
  const closeSweetAlert = () => {
    sweetAlert.show = false
  }

  /**
   * Manejo de errores de API con logging y notificación
   */
  const handleApiError = (error, customMessage = null) => {
    console.error('API Error:', error)

    let errorMessage = customMessage || 'Ha ocurrido un error inesperado'

    // Personalizar mensaje según el tipo de error
    if (error.message?.includes('fetch')) {
      errorMessage = 'Error de conexión con el servidor'
    } else if (error.message?.includes('404')) {
      errorMessage = 'Recurso no encontrado'
    } else if (error.message?.includes('500')) {
      errorMessage = 'Error interno del servidor'
    } else if (error.message?.includes('timeout')) {
      errorMessage = 'Tiempo de espera agotado'
    } else if (error.message) {
      errorMessage = error.message
    }

    setError(errorMessage)
    showToast('error', errorMessage)

    return errorMessage
  }

  /**
   * Wrapper para operaciones async con manejo de loading y errores
   */
  const withLoadingAndError = async (operation, loadingMsg = 'Procesando...') => {
    setLoading(true, loadingMsg)
    clearErrors()

    try {
      const result = await operation()
      return result
    } catch (error) {
      handleApiError(error)
      throw error
    } finally {
      setLoading(false)
    }
  }

  /**
   * Validador genérico de campos
   */
  const validateField = (fieldName, value, rules) => {
    clearValidationError(fieldName)

    for (const rule of rules) {
      const errorMessage = rule.validator(value)
      if (errorMessage) {
        setValidationError(fieldName, errorMessage)
        return false
      }
    }

    return true
  }

  /**
   * Reglas de validación comunes
   */
  const validationRules = {
    required: (message = 'Este campo es obligatorio') => ({
      validator: (value) => {
        if (!value || (typeof value === 'string' && value.trim().length === 0)) {
          return message
        }
        return null
      }
    }),

    minLength: (min, message = null) => ({
      validator: (value) => {
        if (value && value.length < min) {
          return message || `Debe tener al menos ${min} caracteres`
        }
        return null
      }
    }),

    maxLength: (max, message = null) => ({
      validator: (value) => {
        if (value && value.length > max) {
          return message || `No puede tener más de ${max} caracteres`
        }
        return null
      }
    }),

    email: (message = 'Formato de email inválido') => ({
      validator: (value) => {
        if (value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
          return message
        }
        return null
      }
    }),

    numeric: (message = 'Debe ser un número válido') => ({
      validator: (value) => {
        if (value && isNaN(Number(value))) {
          return message
        }
        return null
      }
    })
  }

  /**
   * Obtiene el icono apropiado para el tipo de toast
   */
  const getToastIcon = (type) => {
    const icons = {
      success: 'fas fa-check-circle',
      error: 'fas fa-exclamation-circle',
      warning: 'fas fa-exclamation-triangle',
      info: 'fas fa-info-circle'
    }
    return icons[type] || icons.info
  }

  /**
   * Obtiene el icono apropiado para el tipo de SweetAlert
   */
  const getSweetAlertIcon = (type) => {
    const icons = {
      success: 'fas fa-check-circle',
      error: 'fas fa-times-circle',
      warning: 'fas fa-exclamation-triangle',
      question: 'fas fa-question-circle',
      info: 'fas fa-info-circle'
    }
    return icons[type] || icons.info
  }

  return {
    // Estados
    loading,
    loadingMessage,
    error,
    validationErrors,
    toast,
    sweetAlert,

    // Métodos de loading
    setLoading,

    // Métodos de error
    setError,
    clearErrors,
    setValidationError,
    clearValidationError,
    handleApiError,

    // Métodos de notificaciones
    showToast,
    hideToast,
    showSweetAlert,
    closeSweetAlert,

    // Utilidades
    withLoadingAndError,
    validateField,
    validationRules,
    getToastIcon,
    getSweetAlertIcon
  }
}