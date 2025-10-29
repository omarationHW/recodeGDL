import { ref } from 'vue'

const sidebarCollapsed = ref(false)

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

  return {
    sidebarCollapsed,
    toggleSidebar,
    collapseSidebar,
    expandSidebar
  }
}
