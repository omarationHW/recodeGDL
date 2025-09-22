import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../views/Dashboard.vue'

const routes = [
  {
    path: '/',
    name: 'Dashboard',
    component: Dashboard
  },
  {
    path: '/dashboard',
    name: 'DashboardAlias',
    component: Dashboard
  },
  {
    path: '/module/:module',
    name: 'Module',
    component: () => import('../views/ModuleView.vue')
  },
  {
    path: '/module/:module/:submodule',
    name: 'Submodule', 
    component: () => import('../views/ModuleView.vue')
  },
  // Rutas específicas para estacionamientos
  {
    path: '/estacionamientos/acceso',
    name: 'EstacionamientosAcceso',
    component: () => import('../views/modules/EstacionamientosAcceso.vue')
  },
  {
    path: '/estacionamientos/aplicapgo_divadmin',
    name: 'EstacionamientosAplicaPgoDivAdmin',
    component: () => import('../views/modules/EstacionamientosPagos.vue')
  },
  {
    path: '/estacionamientos/bja_multiple',
    name: 'EstacionamientosBjaMultiple',
    component: () => import('../views/modules/EstacionamientosBajas.vue')
  },
  {
    path: '/estacionamientos/bja_multiple_ind',
    name: 'EstacionamientosBjaMultipleInd',
    component: () => import('../views/modules/EstacionamientosBajas.vue')
  },
  {
    path: '/estacionamientos/cga_arcedoex',
    name: 'EstacionamientosCgaArcEdoEx',
    component: () => import('../views/modules/EstacionamientosAdmin.vue')
  },
  {
    path: '/estacionamientos/consgral',
    name: 'EstacionamientosConsGral',
    component: () => import('../views/modules/EstacionamientosConsultas.vue')
  },
  {
    path: '/estacionamientos/consremesas',
    name: 'EstacionamientosConsRemesas',
    component: () => import('../views/modules/EstacionamientosConsultas.vue')
  },
  {
    path: '/estacionamientos/gen_arcaltas',
    name: 'EstacionamientosGenArcAltas',
    component: () => import('../views/modules/EstacionamientosGenerar.vue')
  },
  {
    path: '/estacionamientos/gen_arcdiario',
    name: 'EstacionamientosGenArcDiario',
    component: () => import('../views/modules/EstacionamientosGenerar.vue')
  },
  {
    path: '/estacionamientos/gen_individual',
    name: 'EstacionamientosGenIndividual',
    component: () => import('../views/modules/EstacionamientosGenerar.vue')
  },
  {
    path: '/estacionamientos/gen_individual_b',
    name: 'EstacionamientosGenIndividualB',
    component: () => import('../views/modules/EstacionamientosGenerar.vue')
  },
  {
    path: '/estacionamientos/gen_pgosbanorte',
    name: 'EstacionamientosGenPgosBanorte',
    component: () => import('../views/modules/EstacionamientosGenerar.vue')
  },
  {
    path: '/estacionamientos/pagoselec_caja_14',
    name: 'EstacionamientosPagosElecCaja14',
    component: () => import('../views/modules/EstacionamientosPagos.vue')
  },
  {
    path: '/estacionamientos/pagoselec_caja_14_cm',
    name: 'EstacionamientosPagosElecCaja14CM',
    component: () => import('../views/modules/EstacionamientosPagos.vue')
  },
  {
    path: '/estacionamientos/dspasswords',
    name: 'EstacionamientosPasswords',
    component: () => import('../views/modules/EstacionamientosAdmin.vue')
  },
  {
    path: '/estacionamientos/metrometers',
    name: 'EstacionamientosMetrometers',
    component: () => import('../views/modules/EstacionamientosAdmin.vue')
  },
  // Rutas específicas para aseo
  {
    path: '/aseo/abc_cves_operacion',
    name: 'AseoCvesOperacion',
    component: () => import('../views/modules/AseoOperaciones.vue')
  },
  {
    path: '/aseo/abc_empresas',
    name: 'AseoEmpresas',
    component: () => import('../views/modules/AseoEmpresas.vue')
  },
  {
    path: '/aseo/abc_gastos',
    name: 'AseoGastos',
    component: () => import('../views/modules/AseoGastos.vue')
  },
  {
    path: '/aseo/abc_recargos',
    name: 'AseoRecargos',
    component: () => import('../views/modules/AseoRecargos.vue')
  },
  // Ruta genérica para todos los módulos de licencias
  {
    path: '/licencias/:submodule',
    name: 'LicenciasGeneric',
    component: () => import('../views/modules/LicenciasGeneric.vue')
  },
  // Ruta genérica para todos los demás módulos de estacionamientos
  {
    path: '/estacionamientos/:submodule',
    name: 'EstacionamientosGeneric',
    component: () => import('../views/modules/EstacionamientosGeneric.vue')
  },
  // Ruta genérica para todos los demás módulos de aseo
  {
    path: '/aseo/:submodule',
    name: 'AseoGeneric',
    component: () => import('../views/modules/AseoGeneric.vue')
  },
  // Ruta genérica para todos los módulos de mercados
  {
    path: '/mercados/:submodule',
    name: 'MercadosGeneric',
    component: () => import('../views/modules/MercadosGeneric.vue')
  },
  // Rutas específicas para recaudadora
  {
    path: '/recaudadora/busque',
    name: 'RecaudadoraBusque',
    component: () => import('../views/modules/RecaudadoraBusque.vue')
  },
  // Ruta genérica para todos los demás módulos de recaudadora
  {
    path: '/recaudadora/:submodule',
    name: 'RecaudadoraGeneric',
    component: () => import('../views/modules/RecaudadoraGeneric.vue')
  },
  // Rutas específicas para tramite-trunk
  {
    path: '/tramite-trunk/busque',
    name: 'TramiteTrunkBusque',
    component: () => import('../views/modules/TramiteTrunkBusque.vue')
  },
  // Ruta genérica para todos los demás módulos de tramite-trunk
  {
    path: '/tramite-trunk/:submodule',
    name: 'TramiteTrunkGeneric',
    component: () => import('../views/modules/TramiteTrunkGeneric.vue')
  },
  // Ruta genérica para todos los módulos de convenios
  {
    path: '/convenios/:submodule',
    name: 'ConveniosGeneric',
    component: () => import('../views/modules/ConveniosGeneric.vue')
  },
  // Ruta genérica para todos los módulos de apremios
  {
    path: '/apremios/:submodule',
    name: 'ApremiosGeneric',
    component: () => import('../views/modules/ApremiosGeneric.vue')
  },
  // Ruta genérica para todos los módulos de cementerios
  {
    path: '/cementerios/:submodule',
    name: 'CementeriosGeneric',
    component: () => import('../views/modules/CementeriosGeneric.vue')
  },
  // Ruta genérica para todos los módulos de otras obligaciones
  {
    path: '/otras-oblig/:submodule',
    name: 'OtrasObligGeneric',
    component: () => import('../views/modules/OtrasObligGeneric.vue')
  },
  // Rutas para páginas informativas de módulos
  {
    path: '/info/:module',
    name: 'ModuleInfo',
    component: () => import('../views/ModuleInfo.vue')
  },
  {
    path: '/info/licencias',
    name: 'LicenciasInfo',
    component: () => import('../views/modules/LicenciasInfo.vue')
  },
  {
    path: '/info/apremios',
    name: 'ApremiosInfo',
    component: () => import('../views/modules/ApremiosInfo.vue')
  },
  {
    path: '/info/aseo',
    name: 'AseoInfo',
    component: () => import('../views/modules/AseoInfo.vue')
  },
  {
    path: '/info/catastral',
    name: 'CatastralInfo',
    component: () => import('../views/modules/CatastralInfo.vue')
  },
  {
    path: '/info/cementerios',
    name: 'CementeriosInfo',
    component: () => import('../views/modules/CementeriosInfo.vue')
  },
  {
    path: '/info/convenios',
    name: 'ConveniosInfo',
    component: () => import('../views/modules/ConveniosInfo.vue')
  },
  {
    path: '/info/estacionamientos',
    name: 'EstacionamientosInfo',
    component: () => import('../views/modules/EstacionamientosInfo.vue')
  },
  {
    path: '/info/mercados',
    name: 'MercadosInfo',
    component: () => import('../views/modules/MercadosInfo.vue')
  },
  {
    path: '/info/otras-oblig',
    name: 'OtrasObligInfo',
    component: () => import('../views/modules/OtrasObligInfo.vue')
  },
  {
    path: '/info/recaudadora',
    name: 'RecaudadoraInfo',
    component: () => import('../views/modules/RecaudadoraInfo.vue')
  },
  {
    path: '/info/tramite-trunk',
    name: 'TramiteTrunkInfo',
    component: () => import('../views/modules/TramiteTrunkInfo.vue')
  },
  // Ruta para prueba de usuarios con base de datos real
  {
    path: '/test/usuarios',
    name: 'TestUsuarios',
    component: () => import('../views/TestUsuarios.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    // Siempre hacer scroll al inicio de la página
    return { top: 0, behavior: 'smooth' }
  }
})

export default router