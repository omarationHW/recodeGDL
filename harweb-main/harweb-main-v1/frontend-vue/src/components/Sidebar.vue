<template>
  <aside class="municipal-sidebar" :class="{ 'sidebar-collapsed': isCollapsed }">
    <!-- Header Simple -->
    <div class="sidebar-header">
      <button class="sidebar-toggle" @click="toggleSidebar">
        <i class="fas fa-bars"></i>
      </button>

      <div class="sidebar-brand" v-if="!isCollapsed">
        <div class="logo-container">
          <img src="@/assets/logo/Gdl Logo blanco.png" alt="Guadalajara" class="brand-logo" />
        </div>
        <div class="brand-text">
          <div class="brand-title">Sistema Municipal</div>
          <div class="brand-subtitle">Guadalajara, Jalisco</div>
        </div>
      </div>

      <div class="sidebar-brand-small" v-if="isCollapsed">
        <img src="@/assets/logo/Gdl Logo blanco.png" alt="Guadalajara" class="brand-logo-small" />
      </div>

      <!-- Search Mejorado -->
      <div class="search-box" v-if="!isCollapsed">
        <i class="fas fa-search search-icon"></i>
        <input
          type="text"
          placeholder="Buscar componentes..."
          class="search-input"
          v-model="searchTerm"
          @input="handleSearch"
        />

        <!-- Search Status -->
        <div v-if="searchTerm" class="search-status">
          <div v-if="searchResults.length > 0" class="search-status-found">
            <i class="fas fa-search"></i>
            {{ searchResults.length }} resultado{{ searchResults.length !== 1 ? 's' : '' }}
          </div>
          <div v-else class="search-status-empty">
            <i class="fas fa-search"></i>
            Sin resultados
          </div>
          <button class="search-clear" @click="clearSearch">
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- Navigation Simple -->
    <nav class="sidebar-nav">
      <!-- Dashboard -->
      <div class="nav-section">
        <router-link
          to="/dashboard"
          class="nav-item"
          active-class="nav-item-active"
          :title="isCollapsed ? 'Dashboard' : ''"
        >
          <div class="nav-icon">
            <i class="fas fa-tachometer-alt"></i>
          </div>
          <span class="nav-text" v-if="!isCollapsed">Dashboard</span>
        </router-link>
      </div>

      <!-- Modules Tree (always shown, but filtered) -->
      <div class="modules-tree">
        <div v-for="module in filteredModules" :key="module.name" class="nav-group">
          <button
            @click="toggleModule(module.name)"
            class="module-button"
            :class="{
              'module-expanded': expandedModules[module.name] || (searchTerm && getFilteredRoutes(module).length > 0),
              'module-has-matches': searchTerm && getFilteredRoutes(module).length > 0
            }"
            :title="isCollapsed ? module.displayName : ''"
          >
            <div class="module-icon">
              <i v-if="module.name === 'estacionamientos'" class="fas fa-car-side"></i>
              <i v-else-if="module.name === 'aseo'" class="fas fa-broom"></i>
              <i v-else-if="module.name === 'licencias'" class="fas fa-file-contract"></i>
              <i v-else-if="module.name === 'mercados'" class="fas fa-store-alt"></i>
              <i v-else-if="module.name === 'recaudadora'" class="fas fa-coins"></i>
              <i v-else-if="module.name === 'tramite-trunk'" class="fas fa-file-invoice"></i>
              <i v-else-if="module.name === 'convenios'" class="fas fa-handshake"></i>
              <i v-else-if="module.name === 'apremios'" class="fas fa-exclamation-triangle"></i>
              <i v-else-if="module.name === 'cementerios'" class="fas fa-cross"></i>
              <i v-else-if="module.name === 'otras-oblig'" class="fas fa-tasks"></i>
              <i v-else class="fas fa-folder"></i>
            </div>
            <div class="module-content" v-if="!isCollapsed">
              <span class="module-name" :class="{ 'module-name-highlight': searchTerm && module.displayName.toLowerCase().includes(searchTerm.toLowerCase()) }">
                {{ module.displayName }}
              </span>
              <span class="module-count" :class="{ 'module-count-search': searchTerm }">
                {{ searchTerm ? getFilteredRoutes(module).length : module.routes.length }}
              </span>
            </div>
            <div class="module-arrow" v-if="!isCollapsed">
              <i class="fas fa-chevron-right" :class="{ 'arrow-expanded': expandedModules[module.name] || (searchTerm && getFilteredRoutes(module).length > 0) }"></i>
            </div>
          </button>

          <!-- Submenu with filtered results -->
          <div class="submenu" v-if="(expandedModules[module.name] || (searchTerm && getFilteredRoutes(module).length > 0)) && !isCollapsed && getFilteredRoutes(module).length > 0">
            <router-link
              v-for="route in getFilteredRoutes(module)"
              :key="route.path"
              :to="route.path"
              class="submenu-item"
              :class="{ 'submenu-highlight': searchTerm && isHighlighted(route) }"
              active-class="submenu-item-active"
            >
              <span class="submenu-text">{{ route.displayName || route.name }}</span>
              <span v-if="searchTerm && isHighlighted(route)" class="submenu-match-indicator">
                <i class="fas fa-search"></i>
              </span>
            </router-link>
          </div>
        </div>
      </div>
    </nav>
  </aside>
</template>

<script>
import { tramiteTrunkRoutes, recaudadoraRoutes, licenciasRoutes, mercadosRoutes, aseoRoutes, estacionamientosRoutes, conveniosRoutes, apremiosRoutes, cementeriosRoutes, otrasObligRoutes } from '../config/modules-config.js'

export default {
  name: 'Sidebar',
  data() {
    return {
      isCollapsed: false,
      searchTerm: '',
      searchResults: [],
      expandedModules: {},
      modules: [
        {
          name: 'apremios',
          displayName: 'Apremios',
          routes: apremiosRoutes
        },
        {
          name: 'aseo',
          displayName: 'Aseo',
          routes: aseoRoutes
        },
        {
          name: 'cementerios',
          displayName: 'Cementerios',
          routes: cementeriosRoutes
        },
        {
          name: 'convenios',
          displayName: 'Convenios',
          routes: conveniosRoutes
        },
        {
          name: 'estacionamientos',
          displayName: 'Estacionamientos',
          routes: estacionamientosRoutes
        },
        {
          name: 'licencias',
          displayName: 'Licencias',
          routes: licenciasRoutes
        },
        {
          name: 'mercados',
          displayName: 'Mercados',
          routes: mercadosRoutes
        },
        {
          name: 'otras-oblig',
          displayName: 'Otras Obligaciones',
          routes: otrasObligRoutes
        },
        {
          name: 'recaudadora',
          displayName: 'Padrón Recaudación',
          routes: recaudadoraRoutes
        },
        {
          name: 'tramite-trunk',
          displayName: 'Padrón Catastral',
          routes: tramiteTrunkRoutes
        }
      ]
    }
  },
  computed: {
    filteredModules() {
      if (!this.searchTerm) return this.modules;

      // Si hay búsqueda, mostrar solo módulos que tengan rutas que coincidan
      return this.modules.filter(module => {
        return this.getFilteredRoutes(module).length > 0 ||
               module.displayName.toLowerCase().includes(this.searchTerm.toLowerCase());
      });
    }
  },
  methods: {
    toggleSidebar() {
      this.isCollapsed = !this.isCollapsed;
      this.$emit('toggle', this.isCollapsed);
    },
    toggleModule(moduleName) {
      this.expandedModules[moduleName] = !this.expandedModules[moduleName];
    },
    handleSearch() {
      console.log('🔍 BÚSQUEDA EN SIDEBAR INICIADA')
      console.log('Query:', this.searchTerm)

      if (!this.searchTerm || !this.searchTerm.trim()) {
        this.searchResults = []
        return
      }

      const query = this.searchTerm.toLowerCase().trim()
      console.log('🎯 Buscando:', query)

      this.searchResults = []

      // Buscar en todos los módulos y sus rutas
      this.modules.forEach(module => {
        if (module.routes && module.routes.length > 0) {
          module.routes.forEach(route => {
            // Buscar en rutas directas
            if (this.matchesSearch(route, query)) {
              this.searchResults.push({
                name: route.name,
                displayName: route.displayName || route.name,
                path: route.path,
                module: module.displayName,
                category: 'Principal'
              })
            }

            // Buscar en children si existen
            if (route.children && route.children.length > 0) {
              route.children.forEach(child => {
                if (this.matchesSearch(child, query)) {
                  this.searchResults.push({
                    name: child.name,
                    displayName: child.displayName || child.name,
                    path: child.path,
                    module: module.displayName,
                    category: route.displayName || route.name
                  })
                }
              })
            }
          })
        }
      })

      console.log('🎯 RESULTADOS ENCONTRADOS:', this.searchResults.length)
      if (this.searchResults.length > 0) {
        this.searchResults.forEach((r, index) => {
          console.log(`   ${index + 1}. "${r.displayName}" - ${r.module} → ${r.category}`)
        })
      } else {
        console.log('❌ NO SE ENCONTRARON RESULTADOS')
      }
    },
    matchesSearch(item, query) {
      const name = (item.name || '').toLowerCase()
      const displayName = (item.displayName || '').toLowerCase()

      return name.includes(query) || displayName.includes(query)
    },
    navigateToResult(result) {
      console.log('🚀 Navegando a:', result.path)
      this.$router.push(result.path)
      this.clearSearch()
    },
    clearSearch() {
      this.searchTerm = ''
      this.searchResults = []
      // Collapse all modules when clearing search
      this.expandedModules = {}
    },
    getFilteredRoutes(module) {
      if (!this.searchTerm) return module.routes;

      const query = this.searchTerm.toLowerCase().trim();
      return module.routes.filter(route => {
        const name = (route.name || '').toLowerCase();
        const displayName = (route.displayName || '').toLowerCase();
        return name.includes(query) || displayName.includes(query);
      });
    },
    isHighlighted(route) {
      if (!this.searchTerm) return false;
      const query = this.searchTerm.toLowerCase().trim();
      const name = (route.name || '').toLowerCase();
      const displayName = (route.displayName || '').toLowerCase();
      return name.includes(query) || displayName.includes(query);
    }
  },
  mounted() {
    const savedCollapsed = localStorage.getItem('sidebarCollapsed');
    if (savedCollapsed) {
      this.isCollapsed = JSON.parse(savedCollapsed);
    }
  },
  watch: {
    isCollapsed(newVal) {
      localStorage.setItem('sidebarCollapsed', JSON.stringify(newVal));
    },
    searchTerm(newVal, oldVal) {
      if (newVal && newVal !== oldVal) {
        // Auto-expand modules that have matching results when starting search
        this.modules.forEach(module => {
          if (this.getFilteredRoutes(module).length > 0) {
            this.expandedModules[module.name] = true;
          }
        });
      } else if (!newVal && oldVal) {
        // Don't auto-collapse when clearing search - let user manage their state
        // this.expandedModules = {}; // Comentado para preservar estado del usuario
      }
    }
  }
}
</script>

<style scoped>
/* Simple Professional Sidebar */
.municipal-sidebar {
  width: 280px;
  background: white;
  border-right: 1px solid #e2e8f0;
  height: 100vh;
  position: fixed;
  left: 0;
  top: 0;
  z-index: 1200;
  transition: width 0.3s ease;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.sidebar-collapsed {
  width: 80px;
}

/* Header */
.sidebar-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
  background: var(--municipal-primary);
  color: white;
}

.sidebar-toggle {
  background: none;
  border: none;
  color: white;
  font-size: 1.25rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.sidebar-toggle:hover {
  background: rgba(255, 255, 255, 0.1);
}

.sidebar-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.sidebar-brand-small {
  display: flex;
  justify-content: center;
  margin-bottom: 1rem;
}

.brand-logo, .brand-logo-small {
  width: 40px;
  height: 40px;
  object-fit: contain;
}

.brand-title {
  font-size: 1.125rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  line-height: 1.2;
}

.brand-subtitle {
  font-size: 0.875rem;
  font-weight: var(--font-weight-regular);
  font-family: var(--font-municipal);
  opacity: 0.9;
}

/* Search */
.search-box {
  position: relative;
}

.search-input {
  width: 100%;
  padding: 0.5rem 0.5rem 0.5rem 2rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 0.875rem;
}

.search-input:focus {
  outline: none;
  border-color: rgba(255, 255, 255, 0.4);
  background: rgba(255, 255, 255, 0.2);
}

.search-input::placeholder {
  color: rgba(255, 255, 255, 0.7);
}

.search-icon {
  position: absolute;
  left: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  font-size: 0.875rem;
  opacity: 0.7;
}

/* Search Status */
.search-status {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 0.5rem;
  padding: 0.5rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
  font-size: 0.75rem;
}

.search-status-found {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.search-status-empty {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: rgba(255, 255, 255, 0.7);
}

.search-clear {
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.7);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 3px;
  font-size: 0.75rem;
}

.search-clear:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

/* Enhanced Module Buttons for Search */
.module-has-matches {
  background: rgba(234, 130, 21, 0.08);
  border-left: 3px solid var(--municipal-primary);
}

.module-name-highlight {
  background: rgba(255, 255, 0, 0.3);
  padding: 0.125rem 0.25rem;
  border-radius: 3px;
  font-weight: 600;
}

.module-count-search {
  background: var(--municipal-primary);
  color: white;
  font-weight: 700;
  animation: pulse 1s ease-in-out;
}

/* Modules Tree */
.modules-tree {
  /* Normal module tree styles */
}

/* Enhanced Submenu for Search */
.submenu-highlight {
  background: rgba(234, 130, 21, 0.08);
  border-left: 2px solid var(--municipal-primary);
}

.submenu-match-indicator {
  margin-left: auto;
  color: var(--municipal-primary);
  font-size: 0.75rem;
  opacity: 0.8;
}

/* Navigation */
.sidebar-nav {
  flex: 1;
  padding: 1rem 0;
}

.nav-section, .nav-group {
  margin-bottom: 0.5rem;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  color: var(--slate-600);
  text-decoration: none;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
}

.nav-item:hover {
  background: #f8fafc;
  color: var(--municipal-primary);
}

.nav-item-active {
  background: rgba(234, 130, 21, 0.1);
  color: var(--municipal-primary);
  border-left-color: var(--municipal-primary);
}

.nav-icon {
  width: 20px;
  text-align: center;
  margin-right: 0.75rem;
  font-size: 1rem;
}

.sidebar-collapsed .nav-icon {
  margin-right: 0;
}

.nav-text {
  font-weight: var(--font-weight-regular);
  font-family: var(--font-municipal);
}

/* Module Buttons */
.module-button {
  width: 100%;
  display: flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  background: none;
  border: none;
  color: var(--slate-600);
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: left;
}

.module-button:hover {
  background: #f8fafc;
  color: var(--municipal-primary);
}

.module-expanded {
  background: rgba(234, 130, 21, 0.05);
  color: var(--municipal-primary);
}

.module-icon {
  width: 20px;
  text-align: center;
  margin-right: 0.75rem;
  font-size: 1rem;
}

.sidebar-collapsed .module-icon {
  margin-right: 0;
}

.module-content {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.module-name {
  font-weight: var(--font-weight-regular);
  font-family: var(--font-municipal);
}

.module-count {
  font-size: 0.75rem;
  background: var(--municipal-secondary);
  color: white;
  padding: 0.125rem 0.5rem;
  border-radius: 10px;
  font-weight: 600;
}

.module-arrow {
  margin-left: 0.5rem;
  transition: transform 0.2s ease;
}

.arrow-expanded {
  transform: rotate(90deg);
}

/* Submenu */
.submenu {
  background: #f8fafc;
  border-left: 2px solid #e2e8f0;
}

.submenu-item {
  display: block;
  padding: 0.5rem 1.5rem 0.5rem 3rem;
  color: var(--slate-500);
  text-decoration: none;
  font-size: 0.875rem;
  transition: all 0.2s ease;
}

.submenu-item:hover {
  background: #e2e8f0;
  color: var(--slate-700);
}

.submenu-item-active {
  background: rgba(234, 130, 21, 0.1);
  color: var(--municipal-primary);
}

/* Responsive */
@media (max-width: 768px) {
  .municipal-sidebar {
    transform: translateX(-100%);
  }

  .municipal-sidebar.sidebar-open {
    transform: translateX(0);
  }
}
</style>