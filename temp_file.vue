<template>
  <div class="formatos-ecologia-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Formatos de Ecología</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="alert alert-primary mb-4">
      <h4 class="alert-heading">🌿 Formatos y Requisitos de Ecología</h4>
      <p class="mb-0">Gestión de formatos y documentación ecológica requerida para licencias comerciales</p>
    </div>

    <!-- Controles superiores -->
    <div class="controls-section">
      <button @click="loadFormatos" class="btn btn-info me-2" :disabled="loading">
        🔄 Actualizar
      </button>
      <button @click="mostrarFormularioCrear = !mostrarFormularioCrear" class="btn btn-success">
        ➕ Nuevo Formato
      </button>
    </div>

    <!-- Formulario de nuevo formato -->
    <div v-if="mostrarFormularioCrear" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">📄 {{ nuevoFormato.id ? 'Editar' : 'Nuevo' }} Formato Ecológico</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="crearFormato">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="form-label"><strong>Nombre del Formato:*</strong></label>
              <input v-model="nuevoFormato.nombre" type="text" class="form-control" required />
            </div>
            <div class="col-md-6 mb-3">
              <label class="form-label"><strong>Código:</strong></label>
              <input v-model="nuevoFormato.codigo" type="text" class="form-control" />
            </div>
          </div>
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="form-label"><strong>Tipo:</strong></label>
              <select v-model="nuevoFormato.tipo" class="form-select">
                <option value="">Seleccionar...</option>
                <option value="IMPACTO_AMBIENTAL">Impacto Ambiental</option>
                <option value="RESIDUOS">Gestión de Residuos</option>
                <option value="EMISIONES">Control de Emisiones</option>
                <option value="AGUA">Uso de Agua</option>
                <option value="RUIDO">Control de Ruido</option>
                <option value="CERTIFICACION">Certificación Ambiental</option>
              </select>
            </div>
            <div class="col-md-6 mb-3">
              <label class="form-label"><strong>Vigencia (meses):</strong></label>
              <input v-model="nuevoFormato.vigencia_meses" type="number" class="form-control" min="1" max="120" />
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label"><strong>Descripción:</strong></label>
            <textarea v-model="nuevoFormato.descripcion" class="form-control" rows="3"></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label"><strong>Observaciones:</strong></label>
            <textarea v-model="nuevoFormato.observaciones" class="form-control" rows="2"></textarea>
          </div>
          <div class="row">
            <div class="col-md-6 mb-3">
              <div class="form-check">
                <input v-model="nuevoFormato.es_obligatorio" class="form-check-input" type="checkbox" id="obligatorio">
                <label class="form-check-label" for="obligatorio">
                  Es Obligatorio
                </label>
              </div>
            </div>
            <div class="col-md-6 mb-3">
              <div class="form-check">
                <input v-model="nuevoFormato.activo" class="form-check-input" type="checkbox" id="activo" checked>
                <label class="form-check-label" for="activo">
                  Activo
                </label>
              </div>
            </div>
          </div>
          <div class="d-flex justify-content-end">
            <button type="button" class="btn btn-secondary me-2" @click="cancelarCreacion">Cancelar</button>
            <button type="submit" class="btn btn-primary" :disabled="loading">
              {{ nuevoFormato.id ? 'Actualizar' : 'Crear' }} Formato
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h6 class="mb-0">🔍 Filtros de Búsqueda</h6>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-4 mb-3">
            <label class="form-label"><strong>Nombre:</strong></label>
            <input v-model="filtros.nombre" type="text" class="form-control" @keyup.enter="aplicarFiltros" />
          </div>
          <div class="col-md-4 mb-3">
            <label class="form-label"><strong>Tipo:</strong></label>
            <select v-model="filtros.tipo" class="form-select">
              <option value="">Todos</option>
              <option value="IMPACTO_AMBIENTAL">Impacto Ambiental</option>
              <option value="RESIDUOS">Gestión de Residuos</option>
              <option value="EMISIONES">Control de Emisiones</option>
              <option value="AGUA">Uso de Agua</option>
              <option value="RUIDO">Control de Ruido</option>
              <option value="CERTIFICACION">Certificación Ambiental</option>
            </select>
          </div>
          <div class="col-md-4 mb-3">
            <label class="form-label"><strong>Estado:</strong></label>
            <select v-model="filtros.activo" class="form-select">
              <option value="">Todos</option>
              <option value="true">Activos</option>
              <option value="false">Inactivos</option>
            </select>
          </div>
        </div>
        <div class="d-flex justify-content-end">
          <button @click="limpiarFiltros" class="btn btn-outline-secondary me-2">Limpiar</button>
          <button @click="aplicarFiltros" class="btn btn-primary" :disabled="loading">Buscar</button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="mb-0">📋 Formatos Ecológicos ({{ totalRegistros }} encontrados)</h6>
        <small class="text-muted">Página {{ currentPage }} de {{ totalPages }}</small>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary"></div>
          <p class="mt-2">Cargando formatos...</p>
        </div>

        <table v-else class="table table-hover mb-0">
          <thead class="table-dark">
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Tipo</th>
              <th>Descripción</th>
              <th>Archivo</th>
              <th>Estado</th>
              <th>Fecha Creación</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="formato in resultados" :key="formato.id">
              <td><span class="badge bg-primary">{{ formato.id }}</span></td>
              <td><strong>{{ formato.nombre }}</strong></td>
              <td>
                <span class="badge" :class="getTipoBadgeClass(formato.tipo)">
                  {{ formatTipo(formato.tipo) }}
                </span>
              </td>
              <td>{{ formato.descripcion }}</td>
              <td>
                <small class="text-muted">{{ formato.archivo_path }}</small>
              </td>
              <td>
                <span class="badge" :class="formato.activo ? 'bg-success' : 'bg-danger'">
                  {{ formato.activo ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td>{{ formatDate(formato.fecha_creacion) }}</td>
              <td>
                <div class="btn-group">
                  <button @click="verDetalle(formato)" class="btn btn-sm btn-outline-primary">👁️ Ver</button>
                  <button @click="editarFormato(formato)" class="btn btn-sm btn-outline-warning">✏️ Editar</button>
                  <button @click="cambiarEstado(formato)" class="btn btn-sm"
                          :class="formato.activo ? 'btn-outline-danger' : 'btn-outline-success'">
                    {{ formato.activo ? '🔒 Desactivar' : '🔓 Activar' }}
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="resultados.length === 0">
              <td colspan="8" class="text-center py-4 text-muted">
                No se encontraron formatos ecológicos
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div v-if="totalPages > 1" class="card-footer">
        <nav>
          <ul class="pagination pagination-sm justify-content-center mb-0">
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <button class="page-link" @click="irPagina(1)">Primera</button>
            </li>
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <button class="page-link" @click="irPagina(currentPage - 1)">Anterior</button>
            </li>
            <li class="page-item active">
              <span class="page-link">{{ currentPage }} de {{ totalPages }}</span>
            </li>
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <button class="page-link" @click="irPagina(currentPage + 1)">Siguiente</button>
            </li>
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <button class="page-link" @click="irPagina(totalPages)">Última</button>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- Modal de detalle -->
    <div v-if="detalle" class="modal fade show d-block" tabindex="-1" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">📄 Detalle del Formato Ecológico</h5>
            <button type="button" class="btn-close" @click="cerrarDetalle"></button>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-md-6">
                <p><strong>Código:</strong> {{ detalle.codigo || 'No asignado' }}</p>
                <p><strong>Nombre:</strong> {{ detalle.nombre }}</p>
                <p><strong>Tipo:</strong>
                  <span class="badge" :class="getTipoBadgeClass(detalle.tipo)">
                    {{ formatTipo(detalle.tipo) }}
                  </span>
                </p>
                <p><strong>Vigencia:</strong> {{ detalle.vigencia_meses }} meses</p>
              </div>
              <div class="col-md-6">
                <p><strong>Obligatorio:</strong>
                  <span class="badge" :class="detalle.es_obligatorio ? 'bg-warning text-dark' : 'bg-secondary'">
                    {{ detalle.es_obligatorio ? 'Sí' : 'No' }}
                  </span>
                </p>
                <p><strong>Estado:</strong>
                  <span class="badge" :class="detalle.activo ? 'bg-success' : 'bg-danger'">
                    {{ detalle.activo ? 'Activo' : 'Inactivo' }}
                  </span>
                </p>
                <p><strong>Fecha Creación:</strong> {{ formatDateTime(detalle.fecha_creacion) }}</p>
                <p><strong>Última Actualización:</strong> {{ formatDateTime(detalle.fecha_actualizacion) }}</p>
              </div>
            </div>
            <div v-if="detalle.descripcion">
              <h6>Descripción:</h6>
              <p class="text-muted">{{ detalle.descripcion }}</p>
            </div>
            <div v-if="detalle.observaciones">
              <h6>Observaciones:</h6>
              <p class="text-muted">{{ detalle.observaciones }}</p>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarDetalle">Cerrar</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Estados generales -->
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'FormatosEcologiafrm',
  data() {
    return {
      // Filtros de búsqueda
      filtros: {
        nombre: '',
        tipo: '',
        activo: ''
      },

      // Resultados y paginación
      resultados: [],
      loading: false,
      error: '',
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,
      totalRegistros: 0,

      // Detalle de formato
      detalle: null,

      // Formulario de nuevo formato
      mostrarFormularioCrear: false,
      nuevoFormato: {
        nombre: '',
        codigo: '',
        tipo: '',
        descripcion: '',
        observaciones: '',
        vigencia_meses: 12,
        es_obligatorio: false,
        activo: true
      }
    };
  },
  mounted() {
    this.loadFormatos();
  },
  methods: {
    // Cargar formatos con filtros y paginación
    async loadFormatos() {
      this.loading = true;
      this.error = '';

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_formatosecologia_list',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_nombre', valor: this.filtros.nombre || null },
              { nombre: 'p_tipo', valor: this.filtros.tipo || null },
              { nombre: 'p_activo', valor: this.filtros.activo === '' ? null : this.filtros.activo === 'true' },
              { nombre: 'p_limite', valor: this.itemsPerPage },
              { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
            ],
            Tenant: 'public'
          }
        });

        if (response.data.eResponse.success) {
          this.resultados = response.data.eResponse.data.result || [];

          // Calcular información de paginación
          if (this.resultados.length > 0) {
            this.totalRegistros = parseInt(this.resultados[0].total_registros) || this.resultados.length;
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage);
          } else {
            this.totalRegistros = 0;
            this.totalPages = 0;
          }
        } else {
          this.error = response.data.eResponse.message || 'Error al cargar formatos';
          this.resultados = [];
        }
      } catch (error) {
        console.error('Error:', error);
        this.error = 'Error de conexión con el servidor';
        this.resultados = [];
      } finally {
        this.loading = false;
      }
    },

    // Aplicar filtros de búsqueda
    aplicarFiltros() {
      this.currentPage = 1;
      this.loadFormatos();
    },

    // Limpiar filtros
    limpiarFiltros() {
      this.filtros = {
        nombre: '',
        tipo: '',
        activo: ''
      };
      this.aplicarFiltros();
    },

    // Navegación de páginas
    irPagina(pagina) {
      if (pagina >= 1 && pagina <= this.totalPages) {
        this.currentPage = pagina;
        this.loadFormatos();
      }
    },

    // Ver detalle de formato
    async verDetalle(formato) {
      this.loading = true;

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_formatosecologia_get',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: formato.id }
            ],
            Tenant: 'public'
          }
        });

        if (response.data.eResponse.success && response.data.eResponse.data.result.length > 0) {
          this.detalle = response.data.eResponse.data.result[0];
        } else {
          this.error = 'No se pudo cargar el detalle del formato';
        }
      } catch (error) {
        console.error('Error:', error);
        this.error = 'Error al cargar detalle del formato';
      } finally {
        this.loading = false;
      }
    },

    // Cerrar detalle
    cerrarDetalle() {
      this.detalle = null;
    },

    // Crear nuevo formato
    async crearFormato() {
      // Si tiene ID, es una actualización
      if (this.nuevoFormato.id) {
        return this.actualizarFormato();
      }

      this.loading = true;
      this.error = '';

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_formatosecologia_create',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_nombre', valor: this.nuevoFormato.nombre },
              { nombre: 'p_codigo', valor: this.nuevoFormato.codigo || null },
              { nombre: 'p_tipo', valor: this.nuevoFormato.tipo || null },
              { nombre: 'p_descripcion', valor: this.nuevoFormato.descripcion || null },
              { nombre: 'p_observaciones', valor: this.nuevoFormato.observaciones || null },
              { nombre: 'p_vigencia_meses', valor: this.nuevoFormato.vigencia_meses || 12 },
              { nombre: 'p_es_obligatorio', valor: this.nuevoFormato.es_obligatorio },
              { nombre: 'p_activo', valor: this.nuevoFormato.activo }
            ],
            Tenant: 'public'
          }
        });

        if (response.data.eResponse.success) {
          alert('Formato ecológico creado exitosamente');
          this.cancelarCreacion();
          this.loadFormatos();
        } else {
          this.error = response.data.eResponse.message || 'Error al crear el formato';
        }
      } catch (error) {
        console.error('Error:', error);
        this.error = 'Error de conexión al crear formato';
      } finally {
        this.loading = false;
      }
    },

    // Cancelar creación
    cancelarCreacion() {
      this.mostrarFormularioCrear = false;
      this.nuevoFormato = {
        nombre: '',
        codigo: '',
        tipo: '',
        descripcion: '',
        observaciones: '',
        vigencia_meses: 12,
        es_obligatorio: false,
        activo: true
      };
      this.error = '';
    },

    // Editar formato
    async editarFormato(formato) {
      // Cargar datos del formato seleccionado en el formulario
      this.nuevoFormato = {
        id: formato.id,
        nombre: formato.nombre || '',
        codigo: formato.codigo || '',
        tipo: formato.tipo || '',
        descripcion: formato.descripcion || '',
        observaciones: formato.observaciones || '',
        vigencia_meses: formato.vigencia_meses || 12,
        es_obligatorio: formato.es_obligatorio || false,
        activo: formato.activo !== false
      };
      this.mostrarFormularioCrear = true;
    },

    // Actualizar formato existente
    async actualizarFormato() {
      this.loading = true;
      this.error = '';

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_formatosecologia_update',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: this.nuevoFormato.id },
              { nombre: 'p_nombre', valor: this.nuevoFormato.nombre },
              { nombre: 'p_codigo', valor: this.nuevoFormato.codigo || null },
              { nombre: 'p_tipo', valor: this.nuevoFormato.tipo || null },
              { nombre: 'p_descripcion', valor: this.nuevoFormato.descripcion || null },
              { nombre: 'p_observaciones', valor: this.nuevoFormato.observaciones || null },
              { nombre: 'p_vigencia_meses', valor: this.nuevoFormato.vigencia_meses || 12 },
              { nombre: 'p_es_obligatorio', valor: this.nuevoFormato.es_obligatorio },
              { nombre: 'p_activo', valor: this.nuevoFormato.activo }
            ],
            Tenant: 'public'
          }
        });

        if (response.data.eResponse.success) {
          alert('Formato ecológico actualizado exitosamente');
          this.cancelarCreacion();
          this.loadFormatos();
        } else {
          this.error = response.data.eResponse.message || 'Error al actualizar el formato';
        }
      } catch (error) {
        console.error('Error:', error);
        this.error = 'Error de conexión al actualizar formato';
      } finally {
        this.loading = false;
      }
    },

    // Cambiar estado de formato
    async cambiarEstado(formato) {
      const nuevoEstado = !formato.activo;
      const accion = nuevoEstado ? 'activar' : 'desactivar';

      if (!confirm(`¿Está seguro de ${accion} este formato?`)) {
        return;
      }

      this.loading = true;

      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_formatosecologia_cambiar_estado',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: formato.id },
              { nombre: 'p_activo', valor: nuevoEstado }
            ],
            Tenant: 'public'
          }
        });

        if (response.data.eResponse.success) {
          alert(`Formato ${accion} correctamente`);
          this.loadFormatos();
        } else {
          this.error = response.data.eResponse.message || `Error al ${accion} formato`;
        }
      } catch (error) {
        console.error('Error:', error);
        this.error = `Error de conexión al ${accion} formato`;
      } finally {
        this.loading = false;
      }
    },

    // Formatear fecha
    formatDate(dateString) {
      if (!dateString) return '-';
      const date = new Date(dateString);
      return date.toLocaleDateString('es-MX');
    },

    // Formatear fecha y hora
    formatDateTime(dateString) {
      if (!dateString) return '-';
      const date = new Date(dateString);
      return date.toLocaleString('es-MX');
    },

    // Formatear tipo
    formatTipo(tipo) {
      const tipos = {
        'IMPACTO_AMBIENTAL': 'Impacto Ambiental',
        'RESIDUOS': 'Gestión de Residuos',
        'EMISIONES': 'Control de Emisiones',
        'AGUA': 'Uso de Agua',
        'RUIDO': 'Control de Ruido',
        'CERTIFICACION': 'Certificación Ambiental'
      };
      return tipos[tipo] || tipo;
    },

    // Obtener clase CSS para badge de tipo
    getTipoBadgeClass(tipo) {
      const classes = {
        'IMPACTO_AMBIENTAL': 'bg-danger',
        'RESIDUOS': 'bg-warning text-dark',
        'EMISIONES': 'bg-info',
        'AGUA': 'bg-primary',
        'RUIDO': 'bg-secondary',
        'CERTIFICACION': 'bg-success'
      };
      return classes[tipo] || 'bg-light text-dark';
    }
  }
}
</script>

<style scoped>
.formatos-ecologia-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 1rem;
}

.controls-section {
  margin-bottom: 1.5rem;
}

.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border: 1px solid #dee2e6;
  margin-bottom: 1rem;
}

.table th {
  background-color: #343a40;
  color: white;
  font-weight: 600;
  border: none;
}

.table td {
  vertical-align: middle;
}

.btn-group .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.badge {
  font-size: 0.75rem;
}

.modal {
  z-index: 1050;
}

.alert-heading {
  color: #0c5460;
}

.form-check-input:checked {
  background-color: #0d6efd;
  border-color: #0d6efd;
}

.spinner-border {
  width: 2rem;
  height: 2rem;
}

.pagination .page-link {
  color: #0d6efd;
}

.pagination .page-item.active .page-link {
  background-color: #0d6efd;
  border-color: #0d6efd;
}

@media (max-width: 768px) {
  .formatos-ecologia-page {
    padding: 0.5rem;
  }

  .btn-group {
    flex-direction: column;
  }

  .btn-group .btn {
    margin-bottom: 0.25rem;
  }

  .table-responsive {
    font-size: 0.875rem;
  }
}
</style>