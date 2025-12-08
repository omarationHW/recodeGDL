// Herramienta de diagnóstico para problemas de navegación
let navigationCount = 0
let navigationHistory = []

export function setupRouterDebug(router) {
  router.beforeEach((to, from, next) => {
    navigationCount++

    const debugInfo = {
      count: navigationCount,
      timestamp: new Date().toISOString(),
      from: from.fullPath,
      to: to.fullPath,
      name: to.name
    }

    navigationHistory.push(debugInfo)

    // Mantener solo las últimas 50 navegaciones
    if (navigationHistory.length > 50) {
      navigationHistory.shift()
    }

    console.log(`[Router Debug] Navegación #${navigationCount}: ${from.path} → ${to.path}`)

    // Alertar si estamos cerca del límite problemático
    if (navigationCount === 20) {
      console.warn('[Router Debug] ⚠️ Se han realizado 20 navegaciones')
    }

    if (navigationCount === 25) {
      console.error('[Router Debug] ❌ LÍMITE ALCANZADO: 25 navegaciones')
      console.table(navigationHistory.slice(-10))
    }

    next()
  })

  router.afterEach((to, from) => {
    console.log(`[Router Debug] ✓ Navegación completada #${navigationCount}`)
  })

  // Exponer funciones de debug globalmente
  window.__routerDebug = {
    getNavigationCount: () => navigationCount,
    getHistory: () => navigationHistory,
    reset: () => {
      navigationCount = 0
      navigationHistory = []
      console.log('[Router Debug] Contador reseteado')
    }
  }

  console.log('[Router Debug] Debug habilitado. Usa window.__routerDebug para diagnóstico')
}
