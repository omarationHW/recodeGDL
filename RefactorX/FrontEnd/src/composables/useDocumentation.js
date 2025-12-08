import { ref } from 'vue'

/**
 * Composable para manejar la documentación y ayuda de los componentes
 * Uso: const { showHelp, showDocs, ... } = useDocumentation('aseo_contratado', 'ABC_Recaudadoras')
 */
export function useDocumentation(moduleName, componentName) {
  // Estados para los modales
  const showHelpModal = ref(false)
  const showDocsModal = ref(false)
  const helpContent = ref('')
  const docsContent = ref('')
  const loadingHelp = ref(false)
  const loadingDocs = ref(false)

  /**
   * Carga el contenido de un archivo markdown
   */
  const loadMarkdownFile = async (type) => {
    const basePath = type === 'help'
      ? `/docs/ayuda/${moduleName}/${componentName}.md`
      : `/docs/documentacion/${moduleName}/${componentName}.md`

    try {
      const response = await fetch(basePath)
      if (!response.ok) {
        return null
      }
      const text = await response.text()
      return text
    } catch (error) {
      console.error(`Error loading ${type} documentation:`, error)
      return null
    }
  }

  /**
   * Abre el modal de ayuda
   */
  const openHelp = async () => {
    loadingHelp.value = true
    showHelpModal.value = true

    const content = await loadMarkdownFile('help')
    if (content) {
      helpContent.value = content
    } else {
      helpContent.value = '# Archivo no disponible\n\nNo existe archivo de ayuda para este componente.'
    }
    loadingHelp.value = false
  }

  /**
   * Cierra el modal de ayuda
   */
  const closeHelp = () => {
    showHelpModal.value = false
  }

  /**
   * Abre el modal de documentación técnica
   */
  const openDocs = async () => {
    loadingDocs.value = true
    showDocsModal.value = true

    const content = await loadMarkdownFile('docs')
    if (content) {
      docsContent.value = content
    } else {
      docsContent.value = '# Archivo no disponible\n\nNo existe archivo de documentación para este componente.'
    }
    loadingDocs.value = false
  }

  /**
   * Cierra el modal de documentación
   */
  const closeDocs = () => {
    showDocsModal.value = false
  }

  return {
    // Estados
    showHelpModal,
    showDocsModal,
    helpContent,
    docsContent,
    loadingHelp,
    loadingDocs,
    // Métodos
    openHelp,
    closeHelp,
    openDocs,
    closeDocs
  }
}
