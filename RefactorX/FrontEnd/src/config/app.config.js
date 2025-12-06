/**
 * Configuración de la aplicación
 * Centraliza las variables de entorno y configuraciones globales
 */

export const appConfig = {
  // API Configuration
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8100',

  // Municipio Configuration
  // ID del municipio de Guadalajara
  municipioId: parseInt(import.meta.env.VITE_MUNICIPIO_ID) || 39,

  // Tenant/Database
  tenant: 'guadalajara'
}

export default appConfig
