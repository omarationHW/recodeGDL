/**
 * Composable para mostrar notificaciones toast
 * Utiliza el sistema de notificaciones nativo del navegador o una librería de toast
 */

export function useToast() {
  /**
   * Muestra un mensaje toast
   * @param {string} message - El mensaje a mostrar
   * @param {string} type - Tipo de mensaje: 'success', 'error', 'warning', 'info'
   * @param {number} duration - Duración en ms (por defecto 3000)
   */
  const showToast = (message, type = 'info', duration = 3000) => {
    // Implementación simple con alert por ahora
    // Puede ser reemplazado con una librería como vue-toastification

    const typeMap = {
      success: '✓',
      error: '✗',
      warning: '⚠',
      info: 'ℹ'
    }

    const icon = typeMap[type] || 'ℹ'
    const formattedMessage = `${icon} ${message}`

    // Para desarrollo, usar console
    if (type === 'error') {
      console.error(formattedMessage)
    } else if (type === 'warning') {
      console.warn(formattedMessage)
    } else {
      console.log(formattedMessage)
    }

    // Opcional: crear un div temporal para mostrar el toast
    const toastElement = document.createElement('div')
    toastElement.textContent = formattedMessage
    toastElement.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      padding: 15px 20px;
      background: ${getBackgroundColor(type)};
      color: white;
      border-radius: 5px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.2);
      z-index: 10000;
      animation: slideIn 0.3s ease-out;
    `

    document.body.appendChild(toastElement)

    setTimeout(() => {
      toastElement.style.animation = 'slideOut 0.3s ease-in'
      setTimeout(() => {
        document.body.removeChild(toastElement)
      }, 300)
    }, duration)
  }

  const getBackgroundColor = (type) => {
    const colors = {
      success: '#28a745',
      error: '#dc3545',
      warning: '#ffc107',
      info: '#17a2b8'
    }
    return colors[type] || colors.info
  }

  // Funciones de conveniencia
  const showSuccess = (message, duration = 3000) => showToast(message, 'success', duration)
  const showError = (message, duration = 3000) => showToast(message, 'error', duration)
  const showWarning = (message, duration = 3000) => showToast(message, 'warning', duration)
  const showInfo = (message, duration = 3000) => showToast(message, 'info', duration)

  return {
    showToast,
    showSuccess,
    showError,
    showWarning,
    showInfo
  }
}

// Agregar animaciones CSS al head si no existen
if (typeof document !== 'undefined') {
  const style = document.createElement('style')
  style.textContent = `
    @keyframes slideIn {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }
    @keyframes slideOut {
      from {
        transform: translateX(0);
        opacity: 1;
      }
      to {
        transform: translateX(100%);
        opacity: 0;
      }
    }
  `
  document.head.appendChild(style)
}
