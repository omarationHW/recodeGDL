/**
 * Servicio de Niveles de Usuario
 * Obtiene información de niveles desde el catálogo de la BD
 */

import axios from 'axios';

class NivelesService {
  constructor() {
    this.niveles = null;
    this.loading = false;
    this.fallbackNiveles = {
      1: { nombre: 'Administrador', color: '#dc3545', icono: 'user-shield' },
      2: { nombre: 'Operador', color: '#ea8215', icono: 'user-cog' },
      3: { nombre: 'Supervisor', color: '#28a745', icono: 'user-tie' },
      4: { nombre: 'Usuario Avanzado', color: '#17a2b8', icono: 'user-plus' },
      5: { nombre: 'Usuario Básico', color: '#6c757d', icono: 'user' },
      6: { nombre: 'Consulta', color: '#6c757d', icono: 'eye' },
      7: { nombre: 'Invitado', color: '#95a5a6', icono: 'user-clock' },
      9: { nombre: 'Sistema', color: '#343a40', icono: 'robot' }
    };
  }

  /**
   * Cargar catálogo de niveles desde la BD
   */
  async cargarNiveles() {
    if (this.loading) return;
    if (this.niveles !== null) return this.niveles;

    this.loading = true;

    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_list_niveles',
          Base: 'mercados',
          Parametros: []
        }
      });

      if (response.data.eResponse && response.data.eResponse.success) {
        const result = response.data.eResponse.data.result;

        if (result && result.length > 0) {
          // Convertir array a objeto indexado por nivel
          this.niveles = {};
          result.forEach(nivel => {
            this.niveles[nivel.nivel] = {
              nombre: nivel.nombre,
              descripcion: nivel.descripcion,
              color: nivel.color_badge,
              icono: nivel.icono,
              orden: nivel.orden,
              total_usuarios: nivel.total_usuarios,
              usuarios_activos: nivel.usuarios_activos
            };
          });

          console.log('✅ Catálogo de niveles cargado:', this.niveles);
          return this.niveles;
        }
      }

      // Si falla, usar fallback
      console.warn('⚠️ No se pudo cargar catálogo de niveles, usando valores por defecto');
      this.niveles = this.fallbackNiveles;
      return this.niveles;

    } catch (error) {
      console.error('❌ Error al cargar niveles:', error);
      this.niveles = this.fallbackNiveles;
      return this.niveles;
    } finally {
      this.loading = false;
    }
  }

  /**
   * Obtener nombre de un nivel
   * @param {number} nivel - Número de nivel (1-9)
   * @returns {string}
   */
  async getNombreNivel(nivel) {
    if (!this.niveles) {
      await this.cargarNiveles();
    }

    return this.niveles[nivel]?.nombre || `Nivel ${nivel}`;
  }

  /**
   * Obtener color del badge de un nivel
   * @param {number} nivel
   * @returns {string}
   */
  async getColorNivel(nivel) {
    if (!this.niveles) {
      await this.cargarNiveles();
    }

    return this.niveles[nivel]?.color || '#6c757d';
  }

  /**
   * Obtener icono de un nivel
   * @param {number} nivel
   * @returns {string}
   */
  async getIconoNivel(nivel) {
    if (!this.niveles) {
      await this.cargarNiveles();
    }

    return this.niveles[nivel]?.icono || 'user';
  }

  /**
   * Obtener información completa de un nivel
   * @param {number} nivel
   * @returns {Object}
   */
  async getInfoNivel(nivel) {
    if (!this.niveles) {
      await this.cargarNiveles();
    }

    return this.niveles[nivel] || {
      nombre: `Nivel ${nivel}`,
      descripcion: 'Nivel sin descripción',
      color: '#6c757d',
      icono: 'user',
      orden: nivel
    };
  }

  /**
   * Obtener todos los niveles
   * @returns {Object}
   */
  async getTodosLosNiveles() {
    if (!this.niveles) {
      await this.cargarNiveles();
    }

    return this.niveles;
  }

  /**
   * Obtener nombre de nivel de forma síncrona (usar fallback si no está cargado)
   * @param {number} nivel
   * @returns {string}
   */
  getNombreNivelSync(nivel) {
    const niveles = this.niveles || this.fallbackNiveles;
    return niveles[nivel]?.nombre || `Nivel ${nivel}`;
  }

  /**
   * Obtener color de nivel de forma síncrona
   * @param {number} nivel
   * @returns {string}
   */
  getColorNivelSync(nivel) {
    const niveles = this.niveles || this.fallbackNiveles;
    return niveles[nivel]?.color || '#6c757d';
  }

  /**
   * Obtener icono de nivel de forma síncrona
   * @param {number} nivel
   * @returns {string}
   */
  getIconoNivelSync(nivel) {
    const niveles = this.niveles || this.fallbackNiveles;
    return niveles[nivel]?.icono || 'user';
  }

  /**
   * Resetear caché (útil para recargar después de cambios en BD)
   */
  resetCache() {
    this.niveles = null;
    this.loading = false;
  }
}

// Exportar instancia singleton
export default new NivelesService();
