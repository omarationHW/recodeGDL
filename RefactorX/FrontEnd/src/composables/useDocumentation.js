import { ref } from 'vue'

/**
 * Composable para manejar la documentación de componentes
 * @param {string} componentName - Nombre del componente (sin extensión .vue)
 * @returns {Object} - { showDocumentation, openDocumentation, closeDocumentation }
 */
export function useDocumentation(componentName) {
  const showDocumentation = ref(false)

  const openDocumentation = () => {
    showDocumentation.value = true
  }

  const closeDocumentation = () => {
    showDocumentation.value = false
  }

  return {
    showDocumentation,
    openDocumentation,
    closeDocumentation,
    componentName
  }
}
