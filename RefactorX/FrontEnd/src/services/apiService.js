import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

//const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || ''

// ==================== CONFIGURACIÓN DE AXIOS ====================
const axiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  timeout: 120000, // 120 segundos de timeout para operaciones largas
  withCredentials: true // Para enviar cookies en CORS
})

// ==================== GESTIÓN DE SESIÓN ====================
class SessionManager {
  constructor() {
    this.sessionKey = 'app_session'
    this.userKey = 'app_user'
    this.tokenKey = 'app_token'
    this.sessionTimeout = 30 * 60 * 1000 // 30 minutos
    this.warningTime = 5 * 60 * 1000 // Advertencia 5 minutos antes
    this.sessionTimer = null
    this.warningTimer = null
  }

  startSession(userData, token) {
    const sessionData = {
      user: userData,
      token: token,
      startTime: Date.now(),
      lastActivity: Date.now()
    }

    localStorage.setItem(this.sessionKey, JSON.stringify(sessionData))
    localStorage.setItem(this.userKey, JSON.stringify(userData))
    if (token) {
      localStorage.setItem(this.tokenKey, token)
    }

    this.startSessionTimer()
  }

  updateActivity() {
    const session = this.getSession()
    if (session) {
      session.lastActivity = Date.now()
      localStorage.setItem(this.sessionKey, JSON.stringify(session))
      this.resetSessionTimer()
    }
  }

  getSession() {
    const sessionStr = localStorage.getItem(this.sessionKey)
    if (!sessionStr) return null

    try {
      const session = JSON.parse(sessionStr)
      const now = Date.now()

      if (now - session.lastActivity > this.sessionTimeout) {
        this.endSession()
        return null
      }

      return session
    } catch {
      return null
    }
  }

  getUser() {
    const userStr = localStorage.getItem(this.userKey)
    try {
      return userStr ? JSON.parse(userStr) : null
    } catch {
      return null
    }
  }

  getToken() {
    return localStorage.getItem(this.tokenKey)
  }

  isAuthenticated() {
    const session = this.getSession()
    return session !== null
  }

  startSessionTimer() {
    this.clearTimers()

    // Timer para advertencia
    this.warningTimer = setTimeout(() => {
      if (window.onSessionWarning) {
        window.onSessionWarning()
      }
    }, this.sessionTimeout - this.warningTime)

    // Timer para expiración
    this.sessionTimer = setTimeout(() => {
      this.endSession()
      if (window.onSessionExpired) {
        window.onSessionExpired()
      }
    }, this.sessionTimeout)
  }

  resetSessionTimer() {
    this.clearTimers()
    this.startSessionTimer()
  }

  clearTimers() {
    if (this.sessionTimer) {
      clearTimeout(this.sessionTimer)
      this.sessionTimer = null
    }
    if (this.warningTimer) {
      clearTimeout(this.warningTimer)
      this.warningTimer = null
    }
  }

  endSession() {
    this.clearTimers()
    localStorage.removeItem(this.sessionKey)
    localStorage.removeItem(this.userKey)
    localStorage.removeItem(this.tokenKey)
  }
}

const sessionManager = new SessionManager()

// ==================== GESTIÓN DE CACHÉ ====================
class CacheManager {
  constructor() {
    this.cache = new Map()
    this.cacheTimeout = 5 * 60 * 1000 // 5 minutos por defecto
  }

  generateKey(operacion, base, parametros) {
    return `${operacion}_${base}_${JSON.stringify(parametros)}`
  }

  set(key, data, timeout = this.cacheTimeout) {
    this.cache.set(key, {
      data: data,
      timestamp: Date.now(),
      timeout: timeout
    })

    // Limpiar caché antiguo
    setTimeout(() => this.delete(key), timeout)
  }

  get(key) {
    const cached = this.cache.get(key)
    if (!cached) return null

    const now = Date.now()
    if (now - cached.timestamp > cached.timeout) {
      this.delete(key)
      return null
    }

    return cached.data
  }

  delete(key) {
    this.cache.delete(key)
  }

  clear() {
    this.cache.clear()
  }

  clearPattern(pattern) {
    const keys = Array.from(this.cache.keys())
    keys.forEach(key => {
      if (key.includes(pattern)) {
        this.delete(key)
      }
    })
  }
}

const cacheManager = new CacheManager()

// ==================== GESTIÓN DE ESTADOS DE CARGA ====================
class LoadingStateManager {
  constructor() {
    this.loadingStates = new Map()
    this.listeners = new Map()
  }

  setLoading(key, isLoading, message = '') {
    this.loadingStates.set(key, { isLoading, message, timestamp: Date.now() })
    this.notifyListeners(key)
  }

  getLoading(key) {
    return this.loadingStates.get(key) || { isLoading: false, message: '' }
  }

  subscribe(key, callback) {
    if (!this.listeners.has(key)) {
      this.listeners.set(key, new Set())
    }
    this.listeners.get(key).add(callback)

    return () => {
      const keyListeners = this.listeners.get(key)
      if (keyListeners) {
        keyListeners.delete(callback)
      }
    }
  }

  notifyListeners(key) {
    const keyListeners = this.listeners.get(key)
    if (keyListeners) {
      const state = this.getLoading(key)
      keyListeners.forEach(callback => callback(state))
    }
  }
}

const loadingStateManager = new LoadingStateManager()

// ==================== INTERCEPTORES ====================
// Request interceptor
axiosInstance.interceptors.request.use(
  config => {
    // Agregar token si existe
    const token = sessionManager.getToken()
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }

    // Actualizar actividad de sesión
    sessionManager.updateActivity()

    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// Response interceptor
axiosInstance.interceptors.response.use(
  response => {
    // Actualizar actividad de sesión en respuestas exitosas
    sessionManager.updateActivity()
    return response
  },
  error => {
    // Manejo mejorado de errores
    if (error.response) {
      switch (error.response.status) {
        case 401:
          // No autorizado - cerrar sesión
          sessionManager.endSession()
          if (window.onAuthenticationRequired) {
            window.onAuthenticationRequired()
          }
          break
        case 403:
          // Prohibido - sin permisos
          console.error('Acceso denegado:', error.response.data)
          break
        case 404:
          console.error('Recurso no encontrado:', error.response.data)
          break
        case 422:
          // Error de validación
          console.error('Error de validación:', error.response.data)
          break
        case 500:
          console.error('Error del servidor:', error.response.data)
          break
        case 503:
          console.error('Servicio no disponible:', error.response.data)
          break
        default:
          console.error('Error HTTP:', error.response.status, error.response.data)
      }
    } else if (error.request) {
      // Error de red
      console.error('Error de red: No se pudo conectar con el servidor')
      if (window.onNetworkError) {
        window.onNetworkError(error)
      }
    } else {
      console.error('Error:', error.message)
    }

    return Promise.reject(error)
  }
)

// ==================== VALIDACIÓN DE DATOS ====================
class DataValidator {
  static validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return re.test(email)
  }

  static validatePhone(phone) {
    const re = /^[\d\s\-\+\(\)]+$/
    return re.test(phone) && phone.replace(/\D/g, '').length >= 10
  }

  static validateRFC(rfc) {
    const re = /^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/
    return re.test(rfc.toUpperCase())
  }

  static validateCURP(curp) {
    const re = /^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]{2}$/
    return re.test(curp.toUpperCase())
  }

  static validateRequired(value) {
    return value !== null && value !== undefined && value !== ''
  }

  static validateMinLength(value, minLength) {
    return value && value.length >= minLength
  }

  static validateMaxLength(value, maxLength) {
    return !value || value.length <= maxLength
  }

  static validateNumeric(value) {
    return !isNaN(value) && isFinite(value)
  }

  static validateInteger(value) {
    return Number.isInteger(Number(value))
  }

  static validateDecimal(value, decimals = 2) {
    const re = new RegExp(`^\\d+(\\.\\d{1,${decimals}})?$`)
    return re.test(value)
  }

  static validateDate(date) {
    return date instanceof Date && !isNaN(date)
  }

  static validateDateString(dateStr, format = 'YYYY-MM-DD') {
    if (format === 'YYYY-MM-DD') {
      const re = /^\d{4}-\d{2}-\d{2}$/
      if (!re.test(dateStr)) return false
      const date = new Date(dateStr)
      return date instanceof Date && !isNaN(date)
    }
    return false
  }

  static validateForm(data, rules) {
    const errors = {}

    for (const field in rules) {
      const fieldRules = rules[field]
      const value = data[field]

      for (const rule of fieldRules) {
        let isValid = true
        let message = ''

        switch (rule.type) {
          case 'required':
            isValid = this.validateRequired(value)
            message = rule.message || `${field} es requerido`
            break
          case 'email':
            isValid = !value || this.validateEmail(value)
            message = rule.message || 'Email inválido'
            break
          case 'phone':
            isValid = !value || this.validatePhone(value)
            message = rule.message || 'Teléfono inválido'
            break
          case 'rfc':
            isValid = !value || this.validateRFC(value)
            message = rule.message || 'RFC inválido'
            break
          case 'curp':
            isValid = !value || this.validateCURP(value)
            message = rule.message || 'CURP inválido'
            break
          case 'minLength':
            isValid = this.validateMinLength(value, rule.value)
            message = rule.message || `Mínimo ${rule.value} caracteres`
            break
          case 'maxLength':
            isValid = this.validateMaxLength(value, rule.value)
            message = rule.message || `Máximo ${rule.value} caracteres`
            break
          case 'numeric':
            isValid = !value || this.validateNumeric(value)
            message = rule.message || 'Debe ser numérico'
            break
          case 'integer':
            isValid = !value || this.validateInteger(value)
            message = rule.message || 'Debe ser entero'
            break
          case 'custom':
            isValid = rule.validator(value, data)
            message = rule.message || 'Validación personalizada falló'
            break
        }

        if (!isValid) {
          if (!errors[field]) {
            errors[field] = []
          }
          errors[field].push(message)
        }
      }
    }

    return {
      isValid: Object.keys(errors).length === 0,
      errors: errors
    }
  }
}

// ==================== UTILIDADES DE PAGINACIÓN ====================
class PaginationHelper {
  static createPaginationParams(page = 1, pageSize = 10, sortBy = null, sortDesc = false) {
    const offset = (page - 1) * pageSize
    const params = {
      limit: pageSize,
      offset: offset
    }

    if (sortBy) {
      params.orderBy = sortBy
      params.orderDirection = sortDesc ? 'DESC' : 'ASC'
    }

    return params
  }

  static processPaginatedResponse(response, page, pageSize) {
    const totalCount = response.totalCount || 0
    const totalPages = Math.ceil(totalCount / pageSize)

    return {
      data: response.data || [],
      pagination: {
        page: page,
        pageSize: pageSize,
        totalCount: totalCount,
        totalPages: totalPages,
        hasNext: page < totalPages,
        hasPrevious: page > 1
      }
    }
  }
}

// ==================== REINTENTOS AUTOMÁTICOS ====================
class RetryManager {
  static async executeWithRetry(fn, options = {}) {
    const {
      maxRetries = 3,
      delay = 1000,
      backoff = 2,
      shouldRetry = (error) => {
        // Reintentar solo en errores de red o 5xx
        return !error.response || (error.response.status >= 500 && error.response.status < 600)
      }
    } = options

    let lastError

    for (let i = 0; i < maxRetries; i++) {
      try {
        return await fn()
      } catch (error) {
        lastError = error

        if (!shouldRetry(error) || i === maxRetries - 1) {
          throw error
        }

        const waitTime = delay * Math.pow(backoff, i)
        await new Promise(resolve => setTimeout(resolve, waitTime))
      }
    }

    throw lastError
  }
}

// ==================== API SERVICE PRINCIPAL ====================
export const apiService = {
  // Propiedades públicas
  session: sessionManager,
  cache: cacheManager,
  loading: loadingStateManager,
  validator: DataValidator,

  // Método principal mejorado
  async execute(operacion, base, parametros = [], tenant = '', pagination = null, esquema = null, options = {}) {
    const {
      useCache = false,
      cacheTimeout = 5 * 60 * 1000,
      loadingKey = null,
      loadingMessage = 'Cargando...',
      retry = false,
      retryOptions = {},
      validateResponse = null
    } = options

    try {
      // Manejo de estado de carga
      if (loadingKey) {
        loadingStateManager.setLoading(loadingKey, true, loadingMessage)
      }

      // Verificar caché si está habilitado
      if (useCache) {
        const cacheKey = cacheManager.generateKey(operacion, base, parametros)
        const cachedData = cacheManager.get(cacheKey)
        if (cachedData) {
          if (loadingKey) {
            loadingStateManager.setLoading(loadingKey, false)
          }
          return cachedData
        }
      }

      const executeRequest = async () => {
        const payload = {
          eRequest: {
            Operacion: operacion,
            Base: base,
            Parametros: parametros,
            Tenant: tenant
          }
        }

        // Agregar esquema si se proporciona
        if (esquema) {
          payload.eRequest.Esquema = esquema
        }

        // Agregar paginación si se proporciona
        if (pagination && (typeof pagination.limit !== 'undefined' || typeof pagination.offset !== 'undefined')) {
          payload.eRequest.Paginacion = {
            limit: pagination.limit ?? null,
            offset: pagination.offset ?? null
          }
        }

        const response = await axiosInstance.post('/api/generic', payload)
        return response.data.eResponse
      }

      // Ejecutar con o sin reintentos
      let result
      if (retry) {
        result = await RetryManager.executeWithRetry(executeRequest, retryOptions)
      } else {
        result = await executeRequest()
      }

      // Validar respuesta si se proporciona validador
      if (validateResponse && typeof validateResponse === 'function') {
        const validationResult = validateResponse(result)
        if (!validationResult.isValid) {
          throw new Error(validationResult.message || 'La respuesta no es válida')
        }
      }

      // Guardar en caché si está habilitado
      if (useCache) {
        const cacheKey = cacheManager.generateKey(operacion, base, parametros)
        cacheManager.set(cacheKey, result, cacheTimeout)
      }

      return result

    } catch (error) {
      // Manejo mejorado de errores
      let errorMessage = 'Error en la petición'
      let errorDetails = null

      if (error.response && error.response.data) {
        if (error.response.data.eResponse) {
          errorMessage = error.response.data.eResponse.message || errorMessage
          errorDetails = error.response.data.eResponse
        } else if (error.response.data.message) {
          errorMessage = error.response.data.message
        } else if (error.response.data.error) {
          errorMessage = error.response.data.error
        }
      } else if (error.request) {
        errorMessage = 'No se pudo conectar con el servidor'
      } else if (error.message) {
        errorMessage = error.message
      }

      const enhancedError = new Error(errorMessage)
      enhancedError.originalError = error
      enhancedError.details = errorDetails
      enhancedError.statusCode = error.response?.status

      throw enhancedError

    } finally {
      // Limpiar estado de carga
      if (loadingKey) {
        loadingStateManager.setLoading(loadingKey, false)
      }
    }
  },

  // Método conveniente para stored procedures
  async executeStoredProcedure(config) {
    const {
      operacion,
      base,
      parametros = [],
      tenant = '',
      pagination = null,
      esquema = null,
      ...options
    } = config

    return this.execute(operacion, base, parametros, tenant, pagination, esquema, options)
  },

  // Métodos CRUD convenientes
  async getAll(base, filtros = {}, options = {}) {
    const { page = 1, pageSize = 10, sortBy = null, sortDesc = false, ...otherOptions } = options
    const pagination = PaginationHelper.createPaginationParams(page, pageSize, sortBy, sortDesc)

    const response = await this.execute('CC', base, filtros, '', pagination, null, {
      useCache: true,
      ...otherOptions
    })

    return PaginationHelper.processPaginatedResponse(response, page, pageSize)
  },

  async getById(base, id, options = {}) {
    return this.execute('CD', base, [id], '', null, null, {
      useCache: true,
      ...options
    })
  },

  async create(base, data, options = {}) {
    // Limpiar caché relacionado después de crear
    this.cache.clearPattern(`CC_${base}`)
    return this.execute('GD', base, [data], '', null, null, options)
  },

  async update(base, id, data, options = {}) {
    // Limpiar caché relacionado después de actualizar
    this.cache.clearPattern(`CC_${base}`)
    this.cache.clearPattern(`CD_${base}`)
    return this.execute('ED', base, [id, data], '', null, null, options)
  },

  async delete(base, id, options = {}) {
    // Limpiar caché relacionado después de eliminar
    this.cache.clearPattern(`CC_${base}`)
    this.cache.clearPattern(`CD_${base}`)
    return this.execute('BD', base, [id], '', null, null, options)
  },

  // Método para login
  async login(username, password) {
    try {
      const response = await this.execute('LOGIN', 'usuarios', [username, password])

      if (response.success && response.data) {
        const userData = response.data.user
        const token = response.data.token

        // Iniciar sesión
        this.session.startSession(userData, token)

        return response
      }

      return response
    } catch (error) {
      console.error('Error en login:', error)
      throw error
    }
  },

  // Método para logout
  async logout() {
    try {
      // Llamar al endpoint de logout si existe
      await this.execute('LOGOUT', 'usuarios', [])
    } catch (error) {
      console.error('Error en logout:', error)
    } finally {
      // Siempre cerrar sesión local
      this.session.endSession()
      this.cache.clear()
    }
  },

  // Validar formulario antes de enviar
  validateFormData(data, rules) {
    return DataValidator.validateForm(data, rules)
  },

  // Métodos de utilidad para tipos específicos
  async searchWithFilters(base, filters, options = {}) {
    const parametros = Object.entries(filters)
      .filter(([_, value]) => value !== null && value !== undefined && value !== '')
      .map(([key, value]) => ({ key, value }))

    return this.getAll(base, parametros, options)
  },

  async batchOperation(operations) {
    const results = []
    const errors = []

    for (const [index, operation] of operations.entries()) {
      try {
        const result = await this.execute(
          operation.operacion,
          operation.base,
          operation.parametros,
          operation.tenant,
          operation.pagination,
          operation.esquema,
          operation.options
        )
        results.push({ index, success: true, data: result })
      } catch (error) {
        errors.push({ index, success: false, error: error.message })
      }
    }

    return { results, errors, hasErrors: errors.length > 0 }
  }
}

// Eventos globales para manejar en la aplicación Vue
window.onAuthenticationRequired = () => {
  // Redirigir al login o mostrar modal de login
  console.log('Autenticación requerida')
}

window.onSessionWarning = () => {
  // Mostrar advertencia de que la sesión está por expirar
  console.log('La sesión está por expirar')
}

window.onSessionExpired = () => {
  // Manejar expiración de sesión
  console.log('La sesión ha expirado')
}

window.onNetworkError = (error) => {
  // Manejar errores de red
  console.log('Error de red detectado', error)
}

export default apiService
