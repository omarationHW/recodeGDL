/**
 * Servicio de Gestión de Sesión
 * Sistema de Mercados - RefactorX
 *
 * Maneja todo lo relacionado con la sesión del usuario:
 * - Login/Logout
 * - Datos de sesión (usuario, nivel, ejercicio)
 * - Validación de permisos
 * - Gestión de ejercicio fiscal
 */

// Keys genéricas (sin prefijo de sistema específico)
const SESSION_KEY = 'session_data';
const EJERCICIO_KEY = 'ejercicio_actual';
const LAST_USER_KEY = 'ultimo_usuario';
const SISTEMA_KEY = 'sistema_actual';

/**
 * Niveles de acceso del sistema
 */
export const NIVELES = {
  ADMINISTRADOR: 1,
  OPERADOR: 2,
  SUPERVISOR: 3,
  USUARIO_AVANZADO: 4,
  USUARIO_BASICO: 5
};

/**
 * Servicio de Sesión
 */
export default {
  /**
   * Guardar sesión de usuario
   * @param {Object} userData - Datos del usuario desde el SP
   * @param {string} userData.usuario - Nombre de usuario
   * @param {number} userData.id_usuario - ID del usuario
   * @param {number} userData.nivel - Nivel de acceso (1-5) (opcional)
   * @param {string} userData.sistema - Sistema actual (mercados, multas_reglamentos, etc.)
   * @param {number} ejercicio - Año fiscal (opcional, solo para mercados)
   */
  setSession(userData, ejercicio = null) {
    const sessionData = {
      usuario: userData.usuario,
      id_usuario: userData.id_usuario,
      nivel: userData.nivel || null,
      ejercicio: ejercicio,
      sistema: userData.sistema || 'mercados',
      nombre: userData.nombre || null,
      cvedepto: userData.cvedepto || null,
      timestamp: new Date().toISOString(),
      version: '2.1'
    };

    // Guardar en localStorage (persistente)
    localStorage.setItem(SESSION_KEY, JSON.stringify(sessionData));
    localStorage.setItem(LAST_USER_KEY, userData.usuario);
    localStorage.setItem(SISTEMA_KEY, sessionData.sistema);

    // Guardar ejercicio en sessionStorage (temporal) solo si existe
    if (ejercicio !== null) {
      sessionStorage.setItem(EJERCICIO_KEY, ejercicio.toString());
    }

    console.log('✅ Sesión guardada:', sessionData);
  },

  /**
   * Obtener datos de sesión completos
   * @returns {Object|null} - Objeto con datos de sesión o null si no existe
   */
  getSession() {
    try {
      const sessionStr = localStorage.getItem(SESSION_KEY);
      if (!sessionStr) return null;

      const session = JSON.parse(sessionStr);

      // Validar que la sesión tenga los campos requeridos
      if (!session.usuario || !session.id_usuario || session.nivel === undefined) {
        console.warn('⚠️ Sesión inválida, eliminando...');
        this.clearSession();
        return null;
      }

      return session;
    } catch (error) {
      console.error('❌ Error al leer sesión:', error);
      return null;
    }
  },

  /**
   * Verificar si hay sesión activa
   * @returns {boolean}
   */
  isAuthenticated() {
    return this.getSession() !== null;
  },

  /**
   * Obtener nombre de usuario
   * @returns {string|null}
   */
  getUsuario() {
    const session = this.getSession();
    return session ? session.usuario : null;
  },

  /**
   * Obtener ID de usuario
   * @returns {number|null}
   */
  getIdUsuario() {
    const session = this.getSession();
    return session ? session.id_usuario : null;
  },

  /**
   * Obtener nivel de acceso del usuario
   * @returns {number|null} - Nivel (1-5) o null si no hay sesión
   */
  getNivel() {
    const session = this.getSession();
    return session ? session.nivel : null;
  },

  /**
   * Obtener ejercicio fiscal actual
   * @returns {number|null}
   */
  getEjercicio() {
    // Prioridad: sessionStorage > localStorage > null
    let ejercicio = sessionStorage.getItem(EJERCICIO_KEY);

    if (!ejercicio) {
      const session = this.getSession();
      ejercicio = session ? session.ejercicio : null;
    }

    return ejercicio ? parseInt(ejercicio) : null;
  },

  /**
   * Actualizar ejercicio fiscal
   * @param {number} ejercicio - Nuevo año fiscal
   */
  setEjercicio(ejercicio) {
    sessionStorage.setItem(EJERCICIO_KEY, ejercicio.toString());

    // Actualizar también en localStorage
    const session = this.getSession();
    if (session) {
      session.ejercicio = ejercicio;
      localStorage.setItem(SESSION_KEY, JSON.stringify(session));
    }

    console.log('✅ Ejercicio actualizado:', ejercicio);
  },

  /**
   * Verificar si el usuario tiene un nivel de acceso específico o superior
   * @param {number} nivelRequerido - Nivel mínimo requerido (menor número = mayor privilegio)
   * @returns {boolean}
   */
  tieneNivel(nivelRequerido) {
    const nivelUsuario = this.getNivel();
    if (nivelUsuario === null) return false;

    // Nivel 1 = mayor privilegio, Nivel 5 = menor privilegio
    return nivelUsuario <= nivelRequerido;
  },

  /**
   * Verificar si el usuario es administrador (nivel 1)
   * @returns {boolean}
   */
  esAdministrador() {
    return this.getNivel() === NIVELES.ADMINISTRADOR;
  },

  /**
   * Verificar si el usuario es operador (nivel 2 o superior)
   * @returns {boolean}
   */
  esOperador() {
    return this.tieneNivel(NIVELES.OPERADOR);
  },

  /**
   * Verificar si el usuario es supervisor (nivel 3 o superior)
   * @returns {boolean}
   */
  esSupervisor() {
    return this.tieneNivel(NIVELES.SUPERVISOR);
  },

  /**
   * Obtener último usuario que inició sesión
   * @returns {string|null}
   */
  getUltimoUsuario() {
    return localStorage.getItem(LAST_USER_KEY);
  },

  /**
   * Cerrar sesión (logout)
   */
  clearSession() {
    localStorage.removeItem(SESSION_KEY);
    localStorage.removeItem(SISTEMA_KEY);
    sessionStorage.removeItem(EJERCICIO_KEY);
    // NO eliminar ultimo_usuario para autocompletar en próximo login
    console.log('✅ Sesión cerrada');
  },

  /**
   * Obtener información completa de la sesión para debugging
   * @returns {Object}
   */
  getSessionInfo() {
    const session = this.getSession();

    return {
      autenticado: this.isAuthenticated(),
      usuario: this.getUsuario(),
      id_usuario: this.getIdUsuario(),
      nivel: this.getNivel(),
      ejercicio: this.getEjercicio(),
      es_administrador: this.esAdministrador(),
      es_operador: this.esOperador(),
      es_supervisor: this.esSupervisor(),
      timestamp: session ? session.timestamp : null,
      session_completa: session
    };
  },

  /**
   * Validar si la sesión es válida (no expirada, etc.)
   * @param {number} horasExpiracion - Horas antes de expirar (default: 8 horas)
   * @returns {boolean}
   */
  isSessionValid(horasExpiracion = 8) {
    const session = this.getSession();
    if (!session) return false;

    if (!session.timestamp) return true; // Si no hay timestamp, asumimos válida

    const ahora = new Date();
    const timestampSesion = new Date(session.timestamp);
    const horasTranscurridas = (ahora - timestampSesion) / (1000 * 60 * 60);

    return horasTranscurridas < horasExpiracion;
  },

  /**
   * Renovar timestamp de la sesión
   */
  renovarSesion() {
    const session = this.getSession();
    if (session) {
      session.timestamp = new Date().toISOString();
      localStorage.setItem(SESSION_KEY, JSON.stringify(session));
      console.log('✅ Sesión renovada');
    }
  },

  /**
   * Obtener sistema actual
   * @returns {string|null} - Sistema actual (mercados, multas_reglamentos, etc.)
   */
  getSistema() {
    const session = this.getSession();
    return session ? session.sistema : localStorage.getItem(SISTEMA_KEY);
  },

  /**
   * Verificar si el sistema actual requiere ejercicio
   * @returns {boolean}
   */
  sistemaRequiereEjercicio() {
    const sistema = this.getSistema();
    // Solo mercados requiere ejercicio
    return sistema === 'mercados';
  },

  /**
   * Obtener permisos del usuario para el sistema actual
   * @returns {Array} - Array de permisos
   */
  getPermisos() {
    const sistema = this.getSistema();
    if (!sistema) return [];

    try {
      const permisosStr = sessionStorage.getItem(`permisos_${sistema}`);
      return permisosStr ? JSON.parse(permisosStr) : [];
    } catch (error) {
      console.error('❌ Error al leer permisos:', error);
      return [];
    }
  },

  /**
   * Verificar si el usuario tiene un permiso específico
   * @param {number} numTag - Número de tag del permiso
   * @returns {boolean}
   */
  tienePermiso(numTag) {
    const permisos = this.getPermisos();
    return permisos.some(p => p.num_tag === numTag);
  },

  /**
   * Verificar si el usuario tiene alguno de los permisos especificados
   * @param {Array<number>} numTags - Array de números de tag
   * @returns {boolean}
   */
  tieneAlgunPermiso(numTags) {
    return numTags.some(tag => this.tienePermiso(tag));
  },

  /**
   * Verificar si el usuario tiene todos los permisos especificados
   * @param {Array<number>} numTags - Array de números de tag
   * @returns {boolean}
   */
  tieneTodosLosPermisos(numTags) {
    return numTags.every(tag => this.tienePermiso(tag));
  },

  /**
   * Obtener nombre completo del usuario
   * @returns {string|null}
   */
  getNombre() {
    const session = this.getSession();
    return session ? session.nombre : null;
  },

  /**
   * Obtener departamento del usuario
   * @returns {number|null}
   */
  getCveDepto() {
    const session = this.getSession();
    return session ? session.cvedepto : null;
  }
};
