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
                <i v-if="module.name === 'estacionamientos'" class="fas fa-car text-primary"></i>
                <i v-else-if="module.name === 'aseo'" class="fas fa-broom text-secondary"></i>
                <i v-else-if="module.name === 'licencias'" class="fas fa-file-contract text-success"></i>
                <i v-else-if="module.name === 'mercados'" class="fas fa-shopping-cart text-warning"></i>
                <i v-else-if="module.name === 'recaudadora'" class="fas fa-coins text-info"></i>
                <i v-else-if="module.name === 'tramite-trunk'" class="fas fa-file-alt text-secondary"></i>
                <i v-else-if="module.name === 'convenios'" class="fas fa-handshake text-secondary"></i>
                <i v-else-if="module.name === 'apremios'" class="fas fa-exclamation-triangle text-secondary"></i>
                <i v-else-if="module.name === 'cementerios'" class="fas fa-cross text-secondary"></i>
                <i v-else-if="module.name === 'otras-oblig'" class="fas fa-tasks text-secondary"></i>
                <i v-else class="fas fa-folder text-secondary"></i>
              </div>
              <span class="flex-grow-1 text-start text-truncate">{{ module.displayName }}</span>
              <!-- 🆕 BADGE PARA MÓDULOS CON NOVEDADES -->
              <span v-if="module.name === 'licencias'" class="badge bg-danger me-2" style="font-size: 9px;">+4 NUEVOS</span>
              <span v-if="module.name === 'mercados'" class="badge bg-warning me-2" style="font-size: 9px;">+2 NUEVOS</span>
              <span v-if="module.name === 'recaudadora'" class="badge bg-info me-2" style="font-size: 9px;">+3 NUEVOS</span>
              <span v-if="module.name === 'estacionamientos'" class="badge bg-primary me-2" style="font-size: 9px;">+3 NUEVOS</span>
              <span v-if="module.name === 'apremios'" class="badge bg-success me-2" style="font-size: 9px;">+3 NUEVOS</span>
              <span v-if="module.name === 'aseo'" class="badge bg-secondary me-2" style="font-size: 9px;">+4 NUEVOS</span>
              <span v-if="module.name === 'cementerios'" class="badge bg-warning me-2" style="font-size: 9px;">+4 NUEVOS</span>
              <span v-if="module.name === 'otras-oblig'" class="badge bg-dark me-2" style="font-size: 9px;">+4 NUEVOS</span>
            </div>
            <div class="d-flex align-items-center justify-content-center">
              <i :class="{ 'fa-rotate-90': expandedModules[module.name] }" class="fas fa-chevron-right text-muted transition"></i>
            </div>
          </button>
          
          <!-- Submódulos -->
          <div v-if="expandedModules[module.name]" class="ms-4 mt-2">
            <!-- Elemento normal (no categoría) -->
            <template v-for="submodule in module.routes" :key="submodule.name">
              <div v-if="!submodule.isCategory">
                <router-link
                  :to="submodule.path"
                  class="d-flex align-items-center px-3 py-2 text-decoration-none text-muted small hover-bg-light rounded-2 transition mb-1 position-relative"
                  active-class="bg-primary bg-opacity-10 text-primary fw-medium"
                >
                  <!-- 🆕 BADGE ROJO PARA NUEVOS COMPONENTES -->
                  <span v-if="submodule.isNew" class="badge bg-danger position-absolute top-0 end-0 translate-middle" style="font-size: 8px; z-index: 10;">NUEVO</span>

                  <div class="me-2 d-flex align-items-center justify-content-center">
                    <i :class="getIconClass(submodule.name)" class="text-secondary" style="font-size: 12px;"></i>
                  </div>
                  <span class="flex-grow-1 text-start text-truncate">{{ submodule.displayName }}</span>
                </router-link>
              </div>
              
              <!-- Elemento categoría con subcategorías -->
              <div v-else class="mb-2">
                <button 
                  @click="toggleSubcategory(module.name, submodule.name)"
                  class="d-flex align-items-center justify-content-between w-100 px-3 py-2 text-start btn btn-outline-secondary border-0 bg-light hover-bg-light rounded-3 transition"
                  :class="{ 'bg-primary bg-opacity-10 text-primary': expandedSubcategories[module.name + '_' + submodule.name] }"
                >
                  <div class="d-flex align-items-center flex-grow-1">
                    <div class="me-2 d-flex align-items-center justify-content-center">
                      <i :class="getCategoryIcon(submodule.name)" class="text-secondary" style="font-size: 12px;"></i>
                    </div>
                    <span class="flex-grow-1 text-start text-truncate small fw-medium">{{ submodule.displayName }}</span>
                  </div>
                  <div class="d-flex align-items-center justify-content-center">
                    <i :class="{ 'fa-rotate-90': expandedSubcategories[module.name + '_' + submodule.name] }" class="fas fa-chevron-right text-muted transition" style="font-size: 10px;"></i>
                  </div>
                </button>
                
                <!-- Items de la subcategoría -->
                <div v-if="expandedSubcategories[module.name + '_' + submodule.name]" class="ms-3 mt-1">
                  <router-link
                    v-for="item in submodule.children"
                    :key="item.name"
                    :to="item.path"
                    class="d-flex align-items-center px-3 py-2 text-decoration-none text-muted small hover-bg-light rounded-2 transition mb-1 position-relative"
                    active-class="bg-primary bg-opacity-10 text-primary fw-medium"
                  >
                    <!-- 🆕 BADGE ROJO PARA NUEVOS COMPONENTES EN SUBCATEGORÍAS -->
                    <span v-if="item.isNew" class="badge bg-danger position-absolute top-0 end-0 translate-middle" style="font-size: 7px; z-index: 10;">NUEVO</span>

                    <div class="me-2 d-flex align-items-center justify-content-center">
                      <i :class="getIconClass(item.name)" class="text-secondary" style="font-size: 10px;"></i>
                    </div>
                    <span class="flex-grow-1 text-start text-truncate" style="font-size: 11px;">{{ item.displayName }}</span>
                  </router-link>
                </div>
              </div>
            </template>
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
      expandedSubcategories: {},
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
    
    toggleSubcategory(moduleName, subcategoryName) {
      const key = moduleName + '_' + subcategoryName
      console.log('Toggling subcategory:', key)
      
      // Crear una copia del objeto para forzar reactividad
      const newExpandedSubcategories = { ...this.expandedSubcategories }
      newExpandedSubcategories[key] = !newExpandedSubcategories[key]
      this.expandedSubcategories = newExpandedSubcategories
      
      console.log('New subcategory state:', this.expandedSubcategories[key])
      this.$forceUpdate()
    },
    
    getIconClass(itemName) {
      const name = itemName.toLowerCase()

      // 🆕 ÍCONOS ESPECÍFICOS PARA NUEVOS COMPONENTES DE MODERNIZACIÓN
      // Licencias
      if (name.includes('perfilesusuariomoderno')) return 'fas fa-users-cog'
      if (name.includes('catalogogirosimportes')) return 'fas fa-money-check-alt'
      if (name.includes('permisosprovisionales')) return 'fas fa-clock'
      if (name.includes('sistemaconvenios')) return 'fas fa-handshake'
      // Mercados
      if (name.includes('sistemaconveniosmercados')) return 'fas fa-store'
      if (name.includes('funcionesexcluidas')) return 'fas fa-times-circle'
      // Recaudadora
      if (name.includes('sistemaconveniosrecaudadora')) return 'fas fa-handshake'
      if (name.includes('sistemaapremiosrecaudadora')) return 'fas fa-gavel'
      if (name.includes('funcionesexcluidasrecaudadora')) return 'fas fa-ban'
      // Estacionamientos
      if (name.includes('sistemaconveniosestacionamientos')) return 'fas fa-parking'
      if (name.includes('sistemaapremiosestacionamientos')) return 'fas fa-car-crash'
      if (name.includes('sistemadescuentosconversion')) return 'fas fa-percentage'

      // Casos específicos primero para evitar conflictos
      if (name.includes('empleadoslistado')) return 'fas fa-users-cog'
      if (name.includes('acceso')) return 'fas fa-key'
      if (name.includes('agenda')) return 'fas fa-calendar'
      if (name.includes('alta') || name.includes('nuevo') || name.includes('nvo')) return 'fas fa-plus'
      if (name.includes('aplicar') || name.includes('aplica')) return 'fas fa-check-circle'
      if (name.includes('archivo') || name.includes('arc')) return 'fas fa-file-archive'
      if (name.includes('aspecto')) return 'fas fa-palette'
      if (name.includes('baja') || name.includes('bja')) return 'fas fa-trash'
      if (name.includes('bloquear')) return 'fas fa-ban'
      if (name.includes('busqueda') || name.includes('buscar') || name.includes('busque')) return 'fas fa-search'
      if (name.includes('calendario')) return 'fas fa-calendar-alt'
      if (name.includes('cancelar') || name.includes('cancela')) return 'fas fa-times-circle'
      if (name.includes('carga') || name.includes('cargar') || name.includes('cga')) return 'fas fa-upload'
      if (name.includes('carton') || name.includes('tarjeta')) return 'fas fa-credit-card'
      if (name.includes('catastro') || name.includes('predial')) return 'fas fa-map'
      if (name.includes('catalogo') || name.includes('cat') || name.includes('abc')) return 'fas fa-list'
      if (name.includes('conciliacion') || name.includes('conci')) return 'fas fa-balance-scale'
      if (name.includes('configuracion') || name.includes('config')) return 'fas fa-cog'
      if (name.includes('cons') || name.includes('consulta')) return 'fas fa-search'
      if (name.includes('contrato')) return 'fas fa-file-contract'
      if (name.includes('control')) return 'fas fa-sliders-h'
      if (name.includes('datos')) return 'fas fa-database'
      if (name.includes('descuento') || name.includes('descto')) return 'fas fa-percent'
      if (name.includes('diario')) return 'fas fa-calendar-day'
      if (name.includes('editar') || name.includes('modif')) return 'fas fa-edit'
      if (name.includes('eliminar') || name.includes('del')) return 'fas fa-trash-alt'
      if (name.includes('empresa')) return 'fas fa-building'
      if (name.includes('estado')) return 'fas fa-flag'
      if (name.includes('exclusivo') || name.includes('exclu')) return 'fas fa-crown'
      if (name.includes('expediente') || name.includes('exp')) return 'fas fa-folder-open'
      if (name.includes('folio')) return 'fas fa-receipt'
      if (name.includes('gasto')) return 'fas fa-dollar-sign'
      if (name.includes('gen') || name.includes('generar') || name.includes('genera')) return 'fas fa-plus-circle'
      if (name.includes('imprimir') || name.includes('imp')) return 'fas fa-print'
      if (name.includes('individual') || name.includes('ind')) return 'fas fa-user'
      if (name.includes('insertar') || name.includes('ins')) return 'fas fa-plus-square'
      if (name.includes('listado')) return 'fas fa-list-ul'
      if (name.includes('menu')) return 'fas fa-bars'
      if (name.includes('mensaje')) return 'fas fa-comment'
      if (name.includes('meter')) return 'fas fa-tachometer-alt'
      if (name.includes('modulo') || name.includes('mod')) return 'fas fa-cube'
      if (name.includes('multa')) return 'fas fa-exclamation-triangle'
      if (name.includes('multiple') || name.includes('mult')) return 'fas fa-layer-group'
      if (name.includes('municipio') || name.includes('mpio')) return 'fas fa-city'
      if (name.includes('oficio')) return 'fas fa-file-alt'
      if (name.includes('operacion') || name.includes('cves')) return 'fas fa-calculator'
      if (name.includes('padron')) return 'fas fa-list-ol'
      if (name.includes('pago') || name.includes('pag') || name.includes('banorte')) return 'fas fa-credit-card'
      if (name.includes('parametros') || name.includes('param')) return 'fas fa-sliders-h'
      if (name.includes('pasar')) return 'fas fa-arrow-right'
      if (name.includes('password') || name.includes('pass')) return 'fas fa-lock'
      if (name.includes('pdf')) return 'fas fa-file-pdf'
      if (name.includes('periodo') || name.includes('per')) return 'fas fa-calendar-week'
      if (name.includes('propietario') || name.includes('prop')) return 'fas fa-user-tie'
      if (name.includes('publico') || name.includes('pub')) return 'fas fa-users'
      if (name.includes('reactiva')) return 'fas fa-power-off'
      if (name.includes('recargo')) return 'fas fa-plus-circle'
      if (name.includes('recaudadora') || name.includes('recaud')) return 'fas fa-coins'
      if (name.includes('relacion') || name.includes('rel')) return 'fas fa-link'
      if (name.includes('remesa')) return 'fas fa-envelope'
      if (name.includes('reporte') || name.includes('rep')) return 'fas fa-chart-bar'
      if (name.includes('scian')) return 'fas fa-industry'
      if (name.includes('transferir') || name.includes('trans')) return 'fas fa-exchange-alt'
      if (name.includes('tipo')) return 'fas fa-tags'
      if (name.includes('ubicacion')) return 'fas fa-map-marker-alt'
      if (name.includes('unidad') || name.includes('und')) return 'fas fa-truck'
      if (name.includes('update') || name.includes('upd') || name.includes('up')) return 'fas fa-sync-alt'
      if (name.includes('usuario')) return 'fas fa-user'
      if (name.includes('valet')) return 'fas fa-car'
      if (name.includes('vencido') || name.includes('venc')) return 'fas fa-clock'
      if (name.includes('viewer')) return 'fas fa-eye'
      if (name.includes('webservice')) return 'fas fa-globe'
      if (name.includes('zona')) return 'fas fa-map-marked-alt'
      
      return 'fas fa-file'
    },
    
    getCategoryIcon(categoryName) {
      const name = categoryName.toLowerCase()
      
      if (name.includes('gestion')) return 'fas fa-cogs'
      if (name.includes('anuncios')) return 'fas fa-bullhorn'
      if (name.includes('tramites')) return 'fas fa-file-alt'
      if (name.includes('catalogos')) return 'fas fa-list'
      if (name.includes('busquedas')) return 'fas fa-search'
      if (name.includes('reportes')) return 'fas fa-chart-bar'
      if (name.includes('solicitudes')) return 'fas fa-file-plus'
      if (name.includes('control')) return 'fas fa-sliders-h'
      if (name.includes('utilidades')) return 'fas fa-tools'
      if (name.includes('especiales')) return 'fas fa-star'
      if (name.includes('sistema')) return 'fas fa-cog'
      
      return 'fas fa-folder'
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