/**
 * Navigation Guards para Vue Router
 * Protege rutas que requieren autenticación, permisos y niveles de acceso
 * Soporta múltiples sistemas: mercados, multas_reglamentos, etc.
 */

import sessionService from '@/services/sessionService';

/**
 * Mapeo de sistemas a sus rutas de login
 */
const LOGIN_ROUTES = {
  mercados: '/mercados/acceso',
  multas_reglamentos: '/multas-reglamentos/acceso',
  aseo_contratado: '/aseo-contratado/acceso',
  cementerios: '/cementerios/acceso',
  licencias: '/licencias/acceso',
  default: '/login'
};

/**
 * Detectar sistema desde la ruta
 * @param {string} path - Ruta actual
 * @returns {string} - Sistema detectado
 */
function detectarSistemaDesdeRuta(path) {
  if (path.startsWith('/mercados')) return 'mercados';
  if (path.startsWith('/multas-reglamentos')) return 'multas_reglamentos';
  if (path.startsWith('/aseo-contratado')) return 'aseo_contratado';
  if (path.startsWith('/cementerios')) return 'cementerios';
  if (path.startsWith('/licencias')) return 'licencias';
  if (path.startsWith('/estacionamiento-publico')) return 'estacionamiento_publico';
  return 'default';
}

/**
 * Obtener ruta de login para un sistema
 * @param {string} sistema - Sistema actual
 * @returns {string} - Ruta de login
 */
function getLoginRoute(sistema) {
  return LOGIN_ROUTES[sistema] || LOGIN_ROUTES.default;
}

/**
 * Guard principal para verificar autenticación
 * Redirige al login del sistema correspondiente si no hay sesión
 */
export function requireAuth(to, from, next) {
  // Detectar sistema desde la ruta de destino
  const sistemaRuta = detectarSistemaDesdeRuta(to.path);
  const sistemaActual = sessionService.getSistema();

  if (!sessionService.isAuthenticated()) {
    console.warn('⚠️ Acceso denegado: No hay sesión activa');
    const loginRoute = getLoginRoute(sistemaRuta);
    next({
      path: loginRoute,
      query: { redirect: to.fullPath }
    });
    return;
  }

  // Verificar si la sesión ha expirado (más de 8 horas)
  if (!sessionService.isSessionValid(8)) {
    console.warn('⚠️ Sesión expirada');
    sessionService.clearSession();
    const loginRoute = getLoginRoute(sistemaRuta);
    next({
      path: loginRoute,
      query: { redirect: to.fullPath, expired: 'true' }
    });
    return;
  }

  // Verificar que el sistema de la sesión coincida con el sistema de la ruta
  if (sistemaActual !== sistemaRuta && sistemaRuta !== 'default') {
    console.warn(`⚠️ Sistema incorrecto: sesión=${sistemaActual}, ruta=${sistemaRuta}`);
    const loginRoute = getLoginRoute(sistemaRuta);
    next({
      path: loginRoute,
      query: { redirect: to.fullPath }
    });
    return;
  }

  // Renovar timestamp de sesión en cada navegación
  sessionService.renovarSesion();
  next();
}

/**
 * Guard para verificar que existe ejercicio fiscal (solo para mercados)
 * @param {Object} to - Ruta destino
 * @param {Object} from - Ruta origen
 * @param {Function} next - Callback
 */
export function requireEjercicio(to, from, next) {
  if (!sessionService.isAuthenticated()) {
    console.warn('⚠️ Acceso denegado: No hay sesión activa');
    next('/mercados/acceso');
    return;
  }

  const ejercicio = sessionService.getEjercicio();
  if (!ejercicio) {
    console.warn('⚠️ No se ha seleccionado ejercicio fiscal');
    next({
      path: '/mercados/acceso',
      query: { error: 'ejercicio_requerido' }
    });
    return;
  }

  sessionService.renovarSesion();
  next();
}

/**
 * Guard para verificar permisos específicos (para sistemas con permisos granulares)
 * @param {number|Array<number>} numTags - Número(s) de tag requerido(s)
 * @param {boolean} requireAll - Si true, requiere todos los permisos; si false, requiere al menos uno
 * @returns {Function} - Guard function
 */
export function requirePermiso(numTags, requireAll = false) {
  return (to, from, next) => {
    if (!sessionService.isAuthenticated()) {
      console.warn('⚠️ Acceso denegado: No hay sesión activa');
      const sistema = detectarSistemaDesdeRuta(to.path);
      const loginRoute = getLoginRoute(sistema);
      next(loginRoute);
      return;
    }

    const tags = Array.isArray(numTags) ? numTags : [numTags];
    const tienePermiso = requireAll
      ? sessionService.tieneTodosLosPermisos(tags)
      : sessionService.tieneAlgunPermiso(tags);

    if (!tienePermiso) {
      console.warn(`⚠️ Acceso denegado: Se requiere permiso(s) ${tags.join(', ')}`);
      const sistema = sessionService.getSistema();
      next({
        path: `/${sistema}`,
        query: { error: 'insufficient_permissions' }
      });
      return;
    }

    sessionService.renovarSesion();
    next();
  };
}

/**
 * Guard para verificar nivel de acceso (para sistemas con niveles)
 * @param {number} nivelRequerido - Nivel mínimo necesario
 * @returns {Function} - Guard function
 */
export function requireNivel(nivelRequerido) {
  return (to, from, next) => {
    if (!sessionService.isAuthenticated()) {
      console.warn('⚠️ Acceso denegado: No hay sesión activa');
      const sistema = detectarSistemaDesdeRuta(to.path);
      const loginRoute = getLoginRoute(sistema);
      next(loginRoute);
      return;
    }

    if (!sessionService.tieneNivel(nivelRequerido)) {
      const nivelUsuario = sessionService.getNivel();
      console.warn(
        `⚠️ Acceso denegado: Se requiere nivel ${nivelRequerido}, usuario tiene nivel ${nivelUsuario}`
      );
      const sistema = sessionService.getSistema();
      next({
        path: `/${sistema}`,
        query: { error: 'insufficient_permissions' }
      });
      return;
    }

    sessionService.renovarSesion();
    next();
  };
}

/**
 * Guard para verificar que el usuario sea administrador (nivel 1)
 */
export function requireAdmin(to, from, next) {
  return requireNivel(1)(to, from, next);
}

/**
 * Guard para verificar que el usuario sea operador o superior (nivel 2)
 */
export function requireOperador(to, from, next) {
  return requireNivel(2)(to, from, next);
}

/**
 * Guard para verificar que el usuario sea supervisor o superior (nivel 3)
 */
export function requireSupervisor(to, from, next) {
  return requireNivel(3)(to, from, next);
}

/**
 * Guard para evitar acceso a login si ya hay sesión activa
 * Redirige al sistema correspondiente según la sesión
 */
export function redirectIfAuthenticated(to, from, next) {
  if (sessionService.isAuthenticated()) {
    const sistema = sessionService.getSistema();
    console.log(`✅ Ya hay sesión activa (${sistema}), redirigiendo...`);

    // Redirigir al dashboard del sistema actual
    const dashboardRoutes = {
      mercados: '/mercados',
      multas_reglamentos: '/multas-reglamentos',
      aseo_contratado: '/aseo-contratado',
      cementerios: '/cementerios',
      licencias: '/licencias'
    };

    next(dashboardRoutes[sistema] || '/');
  } else {
    next();
  }
}

/**
 * Guard combinado: autenticación + ejercicio (para mercados)
 */
export function requireAuthAndEjercicio(to, from, next) {
  requireAuth(to, from, (result) => {
    if (result) {
      next(result);
    } else {
      requireEjercicio(to, from, next);
    }
  });
}

/**
 * Guard global para aplicar a todas las rutas
 * Configura beforeEach en el router
 */
export function setupGlobalGuards(router) {
  router.beforeEach((to, from, next) => {
    // Log de navegación
    console.log(`🔄 Navegación: ${from.path} -> ${to.path}`);

    // Si la ruta no requiere autenticación, permitir acceso
    if (to.meta.requiresAuth === false) {
      next();
      return;
    }

    // Por defecto, todas las rutas requieren autenticación
    // excepto las que explícitamente lo desactivan
    const requiereAuth = to.meta.requiresAuth !== false;

    if (requiereAuth) {
      requireAuth(to, from, next);
    } else {
      next();
    }
  });
}

/**
 * Exportar constantes útiles
 */
export const SISTEMAS = {
  MERCADOS: 'mercados',
  MULTAS: 'multas_reglamentos',
  ASEO: 'aseo_contratado',
  CEMENTERIOS: 'cementerios',
  LICENCIAS: 'licencias'
};

/**
 * Rangos de num_tag por sistema
 */
export const RANGOS_PERMISOS = {
  mercados: [8000, 8099],
  multas_reglamentos: [8500, 8599],
  aseo_contratado: [8200, 8299],
  cementerios: [8300, 8399],
  licencias: [8400, 8499],
  estacionamiento_publico: [8100, 8199]
};
