// Utilidad para cargar componentes desde modules-config.js
import {
  tramiteTrunkRoutes,
  recaudadoraRoutes,
  licenciasRoutes,
  mercadosRoutes,
  aseoRoutes,
  estacionamientosRoutes,
  conveniosRoutes,
  apremiosRoutes,
  cementeriosRoutes,
  otrasObligRoutes
} from '../config/modules-config.js'

export function loadSearchableComponents() {
  console.log('🚀 Cargando componentes desde modules-config.js (estructura real)...')

  const modules = [
    { name: "licencias", displayName: "Licencias", routes: licenciasRoutes, icon: 'fas fa-file-contract' },
    { name: "aseo", displayName: "Aseo Urbano", routes: aseoRoutes, icon: 'fas fa-broom' },
    { name: "apremios", displayName: "Apremios", routes: apremiosRoutes, icon: 'fas fa-exclamation-triangle' },
    { name: "cementerios", displayName: "Cementerios", routes: cementeriosRoutes, icon: 'fas fa-cross' },
    { name: "convenios", displayName: "Convenios", routes: conveniosRoutes, icon: 'fas fa-handshake' },
    { name: "estacionamientos", displayName: "Estacionamientos", routes: estacionamientosRoutes, icon: 'fas fa-car-side' },
    { name: "mercados", displayName: "Mercados", routes: mercadosRoutes, icon: 'fas fa-store-alt' },
    { name: "otras-oblig", displayName: "Otras Obligaciones", routes: otrasObligRoutes, icon: 'fas fa-tasks' },
    { name: "recaudadora", displayName: "Recaudadora", routes: recaudadoraRoutes, icon: 'fas fa-coins' },
    { name: "tramite-trunk", displayName: "Tramite Trunk", routes: tramiteTrunkRoutes, icon: 'fas fa-file-invoice' }
  ]

  const allComponents = []

  modules.forEach(moduleData => {
    if (moduleData.routes) {
      moduleData.routes.forEach(route => {
        if (route.isCategory && route.children) {
          // Es una categoría con hijos
          route.children.forEach(childRoute => {
            allComponents.push({
              name: childRoute.name,
              displayName: childRoute.displayName,
              path: childRoute.path,
              module: moduleData.displayName,
              moduleIcon: moduleData.icon,
              category: route.displayName,
              breadcrumb: `${moduleData.displayName} → ${route.displayName}`,
              isNew: childRoute.isNew || false,
              keywords: [
                childRoute.name,
                childRoute.displayName.toLowerCase(),
                moduleData.displayName.toLowerCase(),
                route.displayName.toLowerCase(),
                childRoute.path.toLowerCase(),
                // Agregar variaciones de búsqueda comunes
                childRoute.name.replace(/([a-z])([A-Z])/g, '$1 $2').toLowerCase(),
                childRoute.displayName.toLowerCase().replace(/[^\w\s]/g, ' '),
                // Palabras clave específicas
                ...(childRoute.name === 'cruces' ? ['cruces', 'calles', 'intersecciones', 'vialidades', 'cruce'] : []),
                ...(childRoute.name === 'firmausuario' ? ['firma', 'usuario', 'firmas', 'autenticacion', 'pin'] : []),
                ...(childRoute.name.includes('empleados') ? ['empleados', 'personal', 'trabajadores'] : [])
              ].join(' ')
            })
          })
        } else {
          // Es un route directo
          allComponents.push({
            name: route.name,
            displayName: route.displayName,
            path: route.path,
            module: moduleData.displayName,
            moduleIcon: moduleData.icon,
            category: 'Principal',
            breadcrumb: `${moduleData.displayName} → Principal`,
            isNew: route.isNew || false,
            keywords: [
              route.name,
              route.displayName.toLowerCase(),
              moduleData.displayName.toLowerCase(),
              route.path.toLowerCase(),
              // Agregar variaciones de búsqueda comunes
              route.name.replace(/([a-z])([A-Z])/g, '$1 $2').toLowerCase(),
              route.displayName.toLowerCase().replace(/[^\w\s]/g, ' ')
            ].join(' ')
          })
        }
      })
    }
  })

  // Agregar dashboard manualmente
  allComponents.push({
    name: 'dashboard',
    displayName: 'Dashboard Principal',
    path: '/',
    module: 'Dashboard',
    moduleIcon: 'fas fa-home',
    category: 'Principal',
    breadcrumb: 'Dashboard → Principal',
    isNew: false,
    keywords: 'dashboard principal home inicio'
  })

  console.log('✅ Componentes cargados desde modules-config:', allComponents.length)
  console.log('📋 Muestra de componentes:', allComponents.slice(0, 5).map(c => `${c.displayName} (${c.breadcrumb})`))

  return allComponents
}

export function getFallbackComponents() {
  console.log('⚠️ Cargando componentes de respaldo...')
  return [
    {
      name: 'dashboard',
      displayName: 'Dashboard Principal',
      path: '/',
      module: 'Dashboard',
      moduleIcon: 'fas fa-home',
      category: 'Principal',
      breadcrumb: 'Dashboard → Principal',
      isNew: false,
      keywords: 'dashboard principal home inicio'
    },
    {
      name: 'cruces',
      displayName: 'Cruces de Calles',
      path: '/licencias/cruces',
      module: 'Licencias',
      moduleIcon: 'fas fa-file-contract',
      category: 'Formularios Core',
      breadcrumb: 'Licencias → Formularios Core',
      isNew: false,
      keywords: 'cruces calles intersecciones vialidades cruce licencias'
    }
  ]
}