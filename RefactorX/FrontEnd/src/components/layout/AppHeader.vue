<template>
  <header class="app-header municipal-header">
    <div class="header-content">
      <button
        v-if="!isDashboard"
        class="sidebar-toggle"
        @click="toggleSidebar"
        title="Mostrar/Ocultar menú"
      >
        <font-awesome-icon icon="bars" />
      </button>
      <div class="logo">
        <img src="/logo1.png?v=2" alt="Municipio de Guadalajara" class="logo-img" />
        <div class="logo-text">
          <h1>RefactorX</h1>
          <span class="subtitle">Sistema de Gestión Administrativa</span>
        </div>
      </div>
      <div class="header-actions" v-if="!isDashboard">
        <div class="user-menu" @click="toggleUserMenu" ref="userMenuRef">
          <font-awesome-icon icon="user" class="user-icon" />
          <span class="user-info">{{ usuario }}</span>
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
                <strong>{{ usuario }}</strong>
                <span class="user-role">{{ nivelTexto }}</span>
              </div>
            </div>
            <div class="dropdown-divider"></div>
            <a href="#" class="dropdown-item" @click.prevent="handleProfile">
              <font-awesome-icon icon="user" />
              Mi perfil
            </a>
            <a href="#" class="dropdown-item" @click.prevent="handleSettings">
              <font-awesome-icon icon="cog" />
              Configuración
            </a>
            <div class="dropdown-divider"></div>
            <a href="#" class="dropdown-item logout" @click.prevent="handleLogout">
              <font-awesome-icon icon="sign-out-alt" />
              Cerrar sesión
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Confirmación para Cerrar Sesión -->
    <Modal
      :show="showLogoutModal"
      @close="showLogoutModal = false"
      @confirm="confirmLogout"
      title="Cerrar sesión"      
      :show-default-footer="true"
      :show-cancel-button="true"
      :show-confirm-button="true"
      cancel-text="Cancelar"
      confirm-text="Cerrar sesión"
      confirm-button-class="btn-danger"
    >
      <div class="text-center py-3">
        <div class="mb-3">
          <font-awesome-icon icon="sign-out-alt" class="text-danger" style="font-size: 3rem;" />
        </div>
        <p class="mb-1"><strong>¿Está seguro que desea cerrar sesión?</strong></p>
        <p class="text-muted small mb-0">Se cerrará la sesión del usuario <strong>{{ usuario }}</strong></p>
      </div>
    </Modal>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSidebar } from '@/composables/useSidebar'
import sessionService from '@/services/sessionService'
import nivelesService from '@/services/nivelesService'
import { useToast } from 'vue-toastification'
import Modal from '@/components/common/Modal.vue'

const router = useRouter()
const route = useRoute()
const toast = useToast()
const { toggleSidebar } = useSidebar()
const showUserMenu = ref(false)
const showLogoutModal = ref(false)
const userMenuRef = ref(null)

// Determinar si está en el dashboard
const isDashboard = computed(() => route.path === '/')

// Obtener datos del usuario desde sessionService
const usuario = computed(() => sessionService.getUsuario() || 'Usuario')
const nivel = computed(() => sessionService.getNivel())
const nivelTexto = computed(() => nivelesService.getNombreNivelSync(nivel.value))

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

const handleProfile = () => {
  console.log('Abrir perfil')
  showUserMenu.value = false
  // TODO: Navegar a página de perfil
  // router.push('/perfil')
}

const handleSettings = () => {
  console.log('Abrir configuración')
  showUserMenu.value = false
  // TODO: Navegar a página de configuración
  // router.push('/configuracion')
}

const handleLogout = () => {
  showUserMenu.value = false
  showLogoutModal.value = true
}

const confirmLogout = () => {
  sessionService.clearSession()
  showLogoutModal.value = false
  toast.success('Sesión cerrada correctamente')
  router.push('/mercados/acceso')
}

// Cerrar menú al hacer clic fuera
const handleClickOutside = (event) => {
  if (userMenuRef.value && !userMenuRef.value.contains(event.target)) {
    showUserMenu.value = false
  }
}

onMounted(async () => {
  // Cargar catálogo de niveles
  await nivelesService.cargarNiveles()
  // Escuchar clicks fuera del menú
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
/* Estilo para el rol/nivel del usuario en el dropdown */
.dropdown-user-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.dropdown-user-info strong {
  font-size: 0.95rem;
  color: var(--slate-800);
}

.dropdown-user-info .user-role {
  font-size: 0.8rem;
  color: var(--municipal-primary);
  font-weight: 600;
}

/* Estilos para el modal de logout */
:deep(.modal-content) {
  border: none;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
}

:deep(.modal-header) {
  background: linear-gradient(135deg, var(--municipal-danger) 0%, #c82333 100%);
  color: white;
  border-bottom: none;
  border-radius: var(--radius-lg) var(--radius-lg) 0 0;
  padding: 1rem 1.5rem;
}

:deep(.modal-header .modal-title) {
  color: white;
  font-weight: var(--font-weight-bold);
  font-size: 1.1rem;
}

:deep(.modal-header .btn-close) {
  filter: brightness(0) invert(1);
}

:deep(.modal-body) {
  padding: 1.5rem;
}

:deep(.modal-footer) {
  border-top: 1px solid var(--slate-200);
  padding: 1rem 1.5rem;
  gap: 0.5rem;
}

:deep(.modal-footer .btn) {
  min-width: 100px;
  font-weight: var(--font-weight-semibold);
}

:deep(.modal-footer .btn-danger) {
  background: linear-gradient(135deg, var(--municipal-danger) 0%, #c82333 100%);
  border: none;
}

:deep(.modal-footer .btn-danger:hover) {
  background: linear-gradient(135deg, #c82333 0%, #a71d2a 100%);
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

:deep(.modal-footer .btn-secondary) {
  background: var(--slate-500);
  border: none;
}

:deep(.modal-footer .btn-secondary:hover) {
  background: var(--slate-600);
}
</style>
