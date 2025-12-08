import { ref } from 'vue'

const sidebarCollapsed = ref(false)
const sidebarWidth = ref(280) // Ancho por defecto del sidebar

export function useSidebar() {
  const toggleSidebar = () => {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  const collapseSidebar = () => {
    sidebarCollapsed.value = true
  }

  const expandSidebar = () => {
    sidebarCollapsed.value = false
  }

  const setSidebarWidth = (width) => {
    sidebarWidth.value = width
  }

  return {
    sidebarCollapsed,
    sidebarWidth,
    toggleSidebar,
    collapseSidebar,
    expandSidebar,
    setSidebarWidth
  }
}
