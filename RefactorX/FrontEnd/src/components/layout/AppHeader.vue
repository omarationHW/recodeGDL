<template>
  <header class="app-header municipal-header">
    <div class="header-content">
      <button class="sidebar-toggle" @click="toggleSidebar" title="Mostrar/Ocultar menú">
        <font-awesome-icon icon="bars" />
      </button>
      <div class="logo">
        <img src="/logo1.png?v=2" alt="Municipio de Guadalajara" class="logo-img" />
        <div class="logo-text">
          <h1>RefactorX</h1>
          <span class="subtitle">Sistema de Gestión Administrativa</span>
        </div>
      </div>
      <div class="header-actions">
        <div class="user-menu" @click="toggleUserMenu" ref="userMenuRef">
          <font-awesome-icon icon="user" class="user-icon" />
          <span class="user-info">Administrador</span>
          <font-awesome-icon
            icon="chevron-down"
            class="dropdown-icon"
            :class="{ 'rotated': showUserMenu }"
          />

          <!-- Dropdown Menu -->
          <div v-if="showUserMenu" class="user-dropdown">
            <div class="dropdown-header">
              <font-awesome-icon icon="user" class="dropdown-user-icon" />
              <div class="dropdown-user-info">
                <strong>Administrador</strong>
                <span>admin@guadalajara.gob.mx</span>
              </div>
            </div>
            <div class="dropdown-divider"></div>
            <a href="#" class="dropdown-item" @click.prevent="handleProfile">
              <font-awesome-icon icon="user" />
              Mi Perfil
            </a>
            <a href="#" class="dropdown-item" @click.prevent="handleSettings">
              <font-awesome-icon icon="cog" />
              Configuración
            </a>
            <div class="dropdown-divider"></div>
            <a href="#" class="dropdown-item logout" @click.prevent="handleLogout">
              <font-awesome-icon icon="sign-out-alt" />
              Cerrar Sesión
            </a>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useSidebar } from '@/composables/useSidebar'
import sessionService from '@/services/sessionService'

const router = useRouter()
const { toggleSidebar } = useSidebar()
const showUserMenu = ref(false)
const userMenuRef = ref(null)

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

const handleProfile = () => {
  console.log('Abrir perfil')
  showUserMenu.value = false
}

const handleSettings = () => {
  console.log('Abrir configuración')
  showUserMenu.value = false
}

const handleLogout = () => {
  console.log('Cerrando sesión...')
  showUserMenu.value = false

  // Limpiar sesión
  sessionService.clearSession()

  // Limpiar permisos del sistema actual
  const sistema = sessionService.getSistema()
  if (sistema) {
    sessionStorage.removeItem(`permisos_${sistema}`)
  }

  // Redirigir al dashboard principal
  router.push('/')

  console.log('✅ Sesión cerrada correctamente')
}

// Cerrar menú al hacer clic fuera
const handleClickOutside = (event) => {
  if (userMenuRef.value && !userMenuRef.value.contains(event.target)) {
    showUserMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
