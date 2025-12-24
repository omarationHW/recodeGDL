<template>
  <header class="app-header">
    <div class="header-content">
      <div class="header-left">
        <img src="/img/GDL_LACIUDAD_BCO.png" alt="Guadalajara" class="header-logo" />
        <button class="sidebar-toggle" @click="toggleSidebar" title="Mostrar/Ocultar menu">
          <font-awesome-icon icon="bars" />
        </button>
      </div>
      <div class="header-center">
        <h1>RefactorX</h1>
        <span class="subtitle">Sistema de Gestion Administrativa</span>
      </div>
      <div class="header-actions">
        <!-- Selector de modulos para administradores -->
        <div v-if="esAdmin" class="module-selector" @click.stop="toggleModuleMenu" ref="moduleMenuRef">
          <font-awesome-icon icon="th-large" class="module-icon" />
          <span class="module-label">Modulos</span>
          <font-awesome-icon icon="chevron-down" class="dropdown-icon" :class="{ rotated: showModuleMenu }" />
          <div v-if="showModuleMenu" class="module-dropdown" @click.stop>
            <div class="dropdown-title">
              <font-awesome-icon icon="th-large" />
              <span>Cambiar Modulo</span>
            </div>
            <div class="dropdown-divider"></div>
            <a href="#" class="module-item" @click.prevent="navigateToModule('/dashboard', null)">
              <font-awesome-icon icon="home" />
              <span>Dashboard Principal</span>
            </a>
            <div class="dropdown-divider"></div>
            <a v-for="mod in modulos" :key="mod.path" href="#" class="module-item" @click.prevent="navigateToModule(mod.path, mod.sistema)">
              <font-awesome-icon :icon="mod.icon" />
              <span>{{ mod.nombre }}</span>
            </a>
          </div>
        </div>
        <div class="user-menu" @click.stop="toggleUserMenu" ref="userMenuRef">
          <font-awesome-icon icon="user" class="user-icon" />
          <span class="user-info">{{ usuarioNombre }}</span>
          <font-awesome-icon icon="chevron-down" class="dropdown-icon" :class="{ rotated: showUserMenu }" />
          <div v-if="showUserMenu" class="user-dropdown" @click.stop>
            <div class="dropdown-header">
              <font-awesome-icon icon="user" class="dropdown-user-icon" />
              <div class="dropdown-user-info">
                <strong>{{ usuarioNombre }}</strong>
                <span>{{ usuarioEmail }}</span>
              </div>
            </div>
            <div v-if="esAdmin" class="admin-badge">
              <font-awesome-icon icon="shield-alt" />
              <span>Administrador</span>
            </div>
            <div class="dropdown-divider"></div>
            <a href="#" class="dropdown-item" @click.prevent="handleProfile"><font-awesome-icon icon="user" />Mi Perfil</a>
            <a href="#" class="dropdown-item" @click.prevent="handleSettings"><font-awesome-icon icon="cog" />Configuracion</a>
            <div class="dropdown-divider"></div>
            <a href="#" class="dropdown-item logout" @click.prevent="handleLogout"><font-awesome-icon icon="sign-out-alt" />Cerrar Sesion</a>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>
<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useSidebar } from '@/composables/useSidebar'
import sessionService from '@/services/sessionService'

const router = useRouter()
const { toggleSidebar } = useSidebar()

const usuarioNombre = computed(() => sessionService.getNombre() || sessionService.getUsuario() || 'Usuario')
const usuarioEmail = computed(() => {
  const usuario = sessionService.getUsuario()
  return usuario ? usuario + '@guadalajara.gob.mx' : ''
})
const esAdmin = computed(() => sessionService.esAdministrador())

const modulos = [
  { path: '/mercados', nombre: 'Mercados', icon: 'store', sistema: 'mercados' },
  { path: '/cementerios', nombre: 'Cementerios', icon: 'cross', sistema: 'cementerios' },
  { path: '/estacionamiento-exclusivo', nombre: 'Est. Exclusivo', icon: 'parking', sistema: 'estacionamiento_exclusivo' },
  { path: '/estacionamiento-publico', nombre: 'Est. Publico', icon: 'car', sistema: 'estacionamiento_publico' },
  { path: '/aseo-contratado', nombre: 'Aseo Contratado', icon: 'broom', sistema: 'aseo_contratado' },
  { path: '/multas-reglamentos', nombre: 'Multas y Reglamentos', icon: 'gavel', sistema: 'multas_reglamentos' },
  { path: '/otras-obligaciones', nombre: 'Otras Obligaciones', icon: 'file-invoice-dollar', sistema: 'otras_obligaciones' },
  { path: '/padron-licencias', nombre: 'Padron y Licencias', icon: 'id-card', sistema: 'padron_licencias' }
]

const showUserMenu = ref(false)
const showModuleMenu = ref(false)
const userMenuRef = ref(null)
const moduleMenuRef = ref(null)

const toggleUserMenu = () => { showUserMenu.value = !showUserMenu.value }
const toggleModuleMenu = () => { showModuleMenu.value = !showModuleMenu.value }

const navigateToModule = (path, sistema) => {
  showModuleMenu.value = false

  if (path === '/dashboard') {
    // Ir al dashboard limpia la sesion
    sessionService.clearSession()
    router.push('/')
    return
  }

  // Actualizar el sistema en la sesion antes de navegar
  const session = sessionService.getSession()
  if (session && sistema) {
    sessionService.setSession({
      usuario: session.usuario,
      id_usuario: session.id_usuario,
      nombre: session.nombre,
      nivel: session.nivel,
      sistema: sistema,
      cvedepto: session.cvedepto
    }, session.ejercicio)
  }

  router.push(path)
}

const handleProfile = () => { showUserMenu.value = false }
const handleSettings = () => { showUserMenu.value = false }
const handleLogout = () => {
  sessionService.clearSession()
  showUserMenu.value = false
  router.push('/login')
}

const handleClickOutside = (event) => {
  if (userMenuRef.value && !userMenuRef.value.contains(event.target)) {
    showUserMenu.value = false
  }
  if (moduleMenuRef.value && !moduleMenuRef.value.contains(event.target)) {
    showModuleMenu.value = false
  }
}

onMounted(() => { document.addEventListener('click', handleClickOutside) })
onUnmounted(() => { document.removeEventListener('click', handleClickOutside) })
</script>
<style scoped>
.app-header { background: linear-gradient(135deg, #f59e0b 0%, #ea8215 50%, #d97706 100%); padding: 0 1.5rem; box-shadow: 0 4px 20px rgba(234, 130, 21, 0.3); position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1000; }
.header-content { display: flex; justify-content: space-between; align-items: center; height: 100%; }
.header-left { display: flex; align-items: center; gap: 1rem; }
.header-logo { height: 45px; width: auto; }
.sidebar-toggle { background: transparent; border: none; color: white; font-size: 1.4rem; cursor: pointer; padding: 0.5rem; border-radius: 0.5rem; transition: all 0.2s ease; display: flex; align-items: center; justify-content: center; }
.sidebar-toggle:hover { background: rgba(255, 255, 255, 0.2); }
.sidebar-toggle:active { transform: scale(0.95); }
.header-center { flex: 1; text-align: center; }
.header-center h1 { color: white; font-size: 1.25rem; font-weight: 700; margin: 0; }
.subtitle { color: rgba(255, 255, 255, 0.9); font-size: 0.75rem; }
.header-actions { display: flex; align-items: center; gap: 0.75rem; }

/* Module Selector Styles */
.module-selector { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; padding: 0.5rem 0.75rem; border-radius: 0.5rem; transition: all 0.2s ease; position: relative; background: rgba(255, 255, 255, 0.15); border: 1px solid rgba(255, 255, 255, 0.2); }
.module-selector:hover { background: rgba(255, 255, 255, 0.25); }
.module-selector .module-icon { font-size: 1rem; color: white; }
.module-selector .module-label { font-size: 0.85rem; font-weight: 500; color: white; }
.module-dropdown { position: absolute; top: 100%; right: 0; margin-top: 0.5rem; background: white; border-radius: 0.75rem; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2); min-width: 240px; overflow: hidden; z-index: 1001; max-height: 400px; overflow-y: auto; }
.dropdown-title { display: flex; align-items: center; gap: 0.75rem; padding: 1rem; background: linear-gradient(135deg, #ea8215, #f59e0b); color: white; font-weight: 600; font-size: 0.9rem; }
.module-item { display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; color: #475569; text-decoration: none; font-size: 0.875rem; transition: all 0.2s ease; cursor: pointer; }
.module-item:hover { background: #f8fafc; color: #ea8215; }
.module-item svg { width: 18px; color: #94a3b8; }
.module-item:hover svg { color: #ea8215; }

/* User Menu Styles */
.user-menu { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; padding: 0.5rem 0.75rem; border-radius: 0.5rem; transition: all 0.2s ease; position: relative; }
.user-menu:hover { background: rgba(255, 255, 255, 0.15); }
.user-icon { font-size: 1.1rem; color: white; }
.user-info { font-size: 0.9rem; font-weight: 500; color: white; }
.dropdown-icon { font-size: 0.7rem; color: rgba(255, 255, 255, 0.8); transition: transform 0.2s ease; }
.dropdown-icon.rotated { transform: rotate(180deg); }
.user-dropdown { position: absolute; top: 100%; right: 0; margin-top: 0.5rem; background: white; border-radius: 0.75rem; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15); min-width: 220px; overflow: hidden; z-index: 1001; }
.dropdown-header { display: flex; align-items: center; gap: 0.75rem; padding: 1rem; background: #f8fafc; }
.dropdown-user-icon { width: 40px; height: 40px; background: linear-gradient(135deg, #ea8215, #f59e0b); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; }
.dropdown-user-info { display: flex; flex-direction: column; }
.dropdown-user-info strong { color: #1e293b; font-size: 0.9rem; }
.dropdown-user-info span { color: #64748b; font-size: 0.75rem; }
.admin-badge { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; background: linear-gradient(135deg, #10b981, #059669); color: white; font-size: 0.75rem; font-weight: 600; }
.admin-badge svg { font-size: 0.8rem; }
.dropdown-divider { height: 1px; background: #e2e8f0; }
.dropdown-item { display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; color: #475569; text-decoration: none; font-size: 0.875rem; transition: all 0.2s ease; }
.dropdown-item:hover { background: #f8fafc; color: #ea8215; }
.dropdown-item svg { width: 16px; color: #94a3b8; }
.dropdown-item:hover svg { color: #ea8215; }
.dropdown-item.logout { color: #ef4444; }
.dropdown-item.logout:hover { background: #fef2f2; }
.dropdown-item.logout svg { color: #ef4444; }
@media (max-width: 768px) { .header-center h1 { font-size: 1rem; } .subtitle { display: none; } .user-info { display: none; } .header-logo { height: 35px; } .module-label { display: none; } }
</style>
