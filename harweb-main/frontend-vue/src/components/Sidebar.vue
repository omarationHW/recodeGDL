<template>
  <aside class="position-fixed start-0 top-0 bottom-0 bg-white shadow border-end d-flex flex-column" style="width: 280px; z-index: 1050;">
    <!-- Header con búsqueda - Fijo -->
    <div class="flex-shrink-0 p-4 border-bottom bg-white">
      <div class="d-flex align-items-center mb-4">
        <div class="bg-primary rounded me-3 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
          <i class="fas fa-code text-white"></i>
        </div>
        <div>
          <div class="h6 fw-semibold text-dark mb-0">RefactorX</div>
          <div class="small text-muted">Sistema Municipal</div>
        </div>
      </div>
      
      <div class="position-relative">
        <input 
          type="text" 
          placeholder="Buscar módulo o funcionalidad..." 
          class="form-control form-control-sm ps-5"
          v-model="searchTerm"
        />
        <i class="fas fa-search position-absolute text-muted" style="left: 12px; top: 8px; font-size: 12px;"></i>
      </div>
    </div>

    <!-- Área de navegación con scroll -->
    <nav class="flex-grow-1 overflow-auto px-4 py-4">
        <!-- Dashboard -->
        <div class="mb-3">
          <router-link 
            to="/dashboard"
            class="d-flex align-items-center w-100 px-3 py-2 text-start text-decoration-none text-dark bg-white hover-bg-light rounded-3 transition"
            active-class="bg-primary bg-opacity-10 text-primary"
          >
            <div class="me-3 flex-shrink-0 d-flex align-items-center justify-content-center">
              <i class="fas fa-tachometer-alt text-primary"></i>
            </div>
            <span class="flex-grow-1 text-start">Dashboard</span>
          </router-link>
        </div>

        <!-- Módulos dinámicos -->
        <div v-for="module in filteredModules" :key="module.name" class="mb-3">
          <button 
            @click="toggleModule(module.name)"
            class="d-flex align-items-center justify-content-between w-100 px-3 py-2 text-start btn btn-outline-secondary border-0 bg-white hover-bg-light rounded-3 transition"
            :class="{ 'bg-primary bg-opacity-10 text-primary': expandedModules[module.name] }"
          >
            <div class="d-flex align-items-center flex-grow-1">
              <!-- Icono específico según el módulo -->
              <div class="me-3 d-flex align-items-center justify-content-center">
                <i v-if="module.name === 'estacionamientos'" class="fas fa-car text-secondary"></i>
                <i v-else-if="module.name === 'aseo'" class="fas fa-broom text-secondary"></i>
                <i v-else-if="module.name === 'licencias'" class="fas fa-file-contract text-secondary"></i>
                <i v-else-if="module.name === 'mercados'" class="fas fa-shopping-cart text-secondary"></i>
                <i v-else-if="module.name === 'recaudadora'" class="fas fa-coins text-secondary"></i>
                <i v-else-if="module.name === 'tramite-trunk'" class="fas fa-file-alt text-secondary"></i>
                <i v-else-if="module.name === 'convenios'" class="fas fa-handshake text-secondary"></i>
                <i v-else-if="module.name === 'apremios'" class="fas fa-exclamation-triangle text-secondary"></i>
                <i v-else-if="module.name === 'cementerios'" class="fas fa-cross text-secondary"></i>
                <i v-else-if="module.name === 'otras-oblig'" class="fas fa-tasks text-secondary"></i>
                <i v-else class="fas fa-folder text-secondary"></i>
              </div>
              <span class="flex-grow-1 text-start text-truncate">{{ module.displayName }}</span>
            </div>
            <div class="d-flex align-items-center justify-content-center">
              <i :class="{ 'fa-rotate-90': expandedModules[module.name] }" class="fas fa-chevron-right text-muted transition"></i>
            </div>
          </button>
          
          <!-- Submódulos -->
          <div v-if="expandedModules[module.name]" class="ms-4 mt-2">
            <router-link 
              v-for="submodule in module.routes" 
              :key="submodule.name"
              :to="submodule.path"
              class="d-flex align-items-center px-3 py-2 text-decoration-none text-muted small hover-bg-light rounded-2 transition mb-1"
              active-class="bg-primary bg-opacity-10 text-primary fw-medium"
            >
              <div class="me-2 d-flex align-items-center justify-content-center">
                <!-- Iconos FontAwesome para todos los submódulos - TODOS EN GRIS -->
                <!-- Casos específicos primero para evitar conflictos -->
                <i v-if="submodule.name.includes('empleadoslistado')" class="fas fa-users-cog text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('acceso')" class="fas fa-key text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('agenda')" class="fas fa-calendar text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('alta') || submodule.name.includes('nuevo') || submodule.name.includes('nvo')" class="fas fa-plus text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('aplicar') || submodule.name.includes('aplica')" class="fas fa-check-circle text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('archivo') || submodule.name.includes('arc')" class="fas fa-file-archive text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('aspecto')" class="fas fa-palette text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('baja') || submodule.name.includes('bja')" class="fas fa-trash text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('bloquear')" class="fas fa-ban text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('busqueda') || submodule.name.includes('buscar') || submodule.name.includes('busque')" class="fas fa-search text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('calendario')" class="fas fa-calendar-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('cancelar') || submodule.name.includes('cancela')" class="fas fa-times-circle text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('carga') || submodule.name.includes('cargar') || submodule.name.includes('cga')" class="fas fa-upload text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('carton') || submodule.name.includes('tarjeta')" class="fas fa-credit-card text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('catastro') || submodule.name.includes('predial')" class="fas fa-map text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('catalogo') || submodule.name.includes('cat') || submodule.name.includes('abc')" class="fas fa-list text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('conciliacion') || submodule.name.includes('conci')" class="fas fa-balance-scale text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('configuracion') || submodule.name.includes('config')" class="fas fa-cog text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('cons') || submodule.name.includes('consulta')" class="fas fa-search text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('contrato')" class="fas fa-file-contract text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('control')" class="fas fa-sliders-h text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('datos')" class="fas fa-database text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('descuento') || submodule.name.includes('descto')" class="fas fa-percent text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('diario')" class="fas fa-calendar-day text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('editar') || submodule.name.includes('modif')" class="fas fa-edit text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('eliminar') || submodule.name.includes('del')" class="fas fa-trash-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('empresa')" class="fas fa-building text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('estado')" class="fas fa-flag text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('exclusivo') || submodule.name.includes('exclu')" class="fas fa-crown text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('expediente') || submodule.name.includes('exp')" class="fas fa-folder-open text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('folio')" class="fas fa-receipt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('gasto')" class="fas fa-dollar-sign text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('gen') || submodule.name.includes('generar') || submodule.name.includes('genera')" class="fas fa-plus-circle text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('imprimir') || submodule.name.includes('imp')" class="fas fa-print text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('individual') || submodule.name.includes('ind')" class="fas fa-user text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('insertar') || submodule.name.includes('ins')" class="fas fa-plus-square text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('listado')" class="fas fa-list-ul text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('menu')" class="fas fa-bars text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('mensaje')" class="fas fa-comment text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('meter')" class="fas fa-tachometer-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('modulo') || submodule.name.includes('mod')" class="fas fa-cube text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('multa')" class="fas fa-exclamation-triangle text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('multiple') || submodule.name.includes('mult')" class="fas fa-layer-group text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('municipio') || submodule.name.includes('mpio')" class="fas fa-city text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('oficio')" class="fas fa-file-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('operacion') || submodule.name.includes('cves')" class="fas fa-calculator text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('padron')" class="fas fa-list-ol text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('pago') || submodule.name.includes('pag') || submodule.name.includes('banorte')" class="fas fa-credit-card text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('parametros') || submodule.name.includes('param')" class="fas fa-sliders-h text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('pasar')" class="fas fa-arrow-right text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('password') || submodule.name.includes('pass')" class="fas fa-lock text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('pdf')" class="fas fa-file-pdf text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('periodo') || submodule.name.includes('per')" class="fas fa-calendar-week text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('propietario') || submodule.name.includes('prop')" class="fas fa-user-tie text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('publico') || submodule.name.includes('pub')" class="fas fa-users text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('reactiva')" class="fas fa-power-off text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('recargo')" class="fas fa-plus-circle text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('recaudadora') || submodule.name.includes('recaud')" class="fas fa-coins text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('relacion') || submodule.name.includes('rel')" class="fas fa-link text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('remesa')" class="fas fa-envelope text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('reporte') || submodule.name.includes('rep')" class="fas fa-chart-bar text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('scian')" class="fas fa-industry text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('transferir') || submodule.name.includes('trans')" class="fas fa-exchange-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('tipo')" class="fas fa-tags text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('ubicacion')" class="fas fa-map-marker-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('unidad') || submodule.name.includes('und')" class="fas fa-truck text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('update') || submodule.name.includes('upd') || submodule.name.includes('up')" class="fas fa-sync-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('usuario')" class="fas fa-user text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('valet')" class="fas fa-car text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('vencido') || submodule.name.includes('venc')" class="fas fa-clock text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('viewer')" class="fas fa-eye text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('webservice')" class="fas fa-globe text-secondary" style="font-size: 12px;"></i>
                <i v-else-if="submodule.name.includes('zona')" class="fas fa-map-marked-alt text-secondary" style="font-size: 12px;"></i>
                <i v-else class="fas fa-file text-muted" style="font-size: 10px;"></i>
              </div>
              <span class="flex-grow-1 text-start text-truncate">{{ submodule.displayName }}</span>
            </router-link>
          </div>
        </div>
      </nav>

    <!-- Footer del sidebar - Fijo en la parte inferior -->
    <div class="flex-shrink-0 p-4 border-top bg-white">
      <div class="text-center small text-muted">
        <div><i class="fas fa-bolt text-warning"></i> Power by <strong>generic.studio</strong> <i class="fas fa-bolt text-warning"></i></div>
        <div class="mt-1">ver. 1.0.0.570</div>
      </div>
    </div>
  </aside>
</template>

<script>
import { tramiteTrunkRoutes, recaudadoraRoutes, licenciasRoutes, mercadosRoutes, aseoRoutes, estacionamientosRoutes, conveniosRoutes, apremiosRoutes, cementeriosRoutes, otrasObligRoutes } from '../config/modules-config.js'

export default {
  name: 'Sidebar',
  data() {
    return {
      searchTerm: '',
      expandedModules: {
        // Todos los módulos empiezan contraídos por defecto
        'apremios': false,
        'aseo': false,
        'cementerios': false,
        'convenios': false,
        'estacionamientos': false,
        'licencias': false,
        'mercados': false,
        'otras-oblig': false,
        'recaudadora': false,
        'tramite-trunk': false
      },
      modules: []
    }
  },
  mounted() {
    this.loadFallbackModules()
  },
  computed: {
    filteredModules() {
      if (!this.searchTerm) return this.modules
      
      const searchLower = this.searchTerm.toLowerCase()
      
      return this.modules.map(module => {
        // Filtrar submódulos que coincidan con la búsqueda
        const filteredRoutes = module.routes.filter(route =>
          route.displayName.toLowerCase().includes(searchLower) ||
          route.name.toLowerCase().includes(searchLower)
        )
        
        // Si el módulo principal coincide o tiene submódulos que coinciden, incluirlo
        const moduleMatches = module.displayName.toLowerCase().includes(searchLower)
        
        if (moduleMatches || filteredRoutes.length > 0) {
          // Auto-expandir módulos que tienen coincidencias en submódulos
          if (filteredRoutes.length > 0 && !moduleMatches) {
            this.$nextTick(() => {
              if (!this.expandedModules[module.name]) {
                const newExpandedModules = { ...this.expandedModules }
                newExpandedModules[module.name] = true
                this.expandedModules = newExpandedModules
              }
            })
          }
          
          return {
            ...module,
            routes: moduleMatches ? module.routes : filteredRoutes
          }
        }
        
        return null
      }).filter(Boolean)
    }
  },
  methods: {
    toggleModule(moduleName) {
      console.log('Toggling module:', moduleName)
      console.log('Current state:', this.expandedModules[moduleName])
      
      // Crear una copia del objeto para forzar reactividad
      const newExpandedModules = { ...this.expandedModules }
      newExpandedModules[moduleName] = !newExpandedModules[moduleName]
      this.expandedModules = newExpandedModules
      
      console.log('New state:', this.expandedModules[moduleName])
      console.log('All expanded modules:', this.expandedModules)
      
      // Force reactivity update
      this.$forceUpdate()
    },
    
    loadFallbackModules() {
      console.log('Cargando módulos completos (631 componentes)...')
      this.modules = [
        {
          name: "apremios",
          displayName: "Apremios",
          routes: apremiosRoutes
        },
        {
          name: "aseo",
          displayName: "Aseo",
          routes: aseoRoutes
        },
        {
          name: "cementerios",
          displayName: "Cementerios",
          routes: cementeriosRoutes
        },
        {
          name: "convenios",
          displayName: "Convenios",
          routes: conveniosRoutes
        },
        {
          name: "estacionamientos",
          displayName: "Estacionamientos",
          routes: estacionamientosRoutes
        },
        {
          name: "licencias",
          displayName: "Licencias",
          routes: licenciasRoutes
        },
        {
          name: "mercados",
          displayName: "Mercados",
          routes: mercadosRoutes
        },
        {
          name: "otras-oblig",
          displayName: "Otras Obligaciones",
          routes: otrasObligRoutes
        },
        {
          name: "recaudadora",
          displayName: "Padrón Recaudación",
          routes: recaudadoraRoutes
        },
        {
          name: "tramite-trunk",
          displayName: "Padrón Catastral",
          routes: tramiteTrunkRoutes
        }
      ]
      console.log('Módulos fallback cargados:', this.modules)
    }
  }
}
</script>

<style scoped>
.hover-bg-light:hover {
  background-color: #f8f9fa !important;
}

.transition {
  transition: all 0.2s ease;
}

nav::-webkit-scrollbar {
  width: 6px;
}

nav::-webkit-scrollbar-track {
  background: #f8f9fa;
  border-radius: 3px;
}

nav::-webkit-scrollbar-thumb {
  background: #dee2e6;
  border-radius: 3px;
}

nav::-webkit-scrollbar-thumb:hover {
  background: #adb5bd;
}

.fa-rotate-90 {
  transform: rotate(90deg);
}

@media (max-width: 1024px) {
  aside { width: 280px !important; }
}

@media (max-width: 768px) {
  aside { width: 250px !important; }
}

@media (max-width: 640px) {
  aside { width: 100vw !important; position: fixed !important; z-index: 1060 !important; }
}
</style>