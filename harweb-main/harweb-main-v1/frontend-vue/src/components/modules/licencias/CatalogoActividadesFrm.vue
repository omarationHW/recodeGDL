<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/licencias">Licencias</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Actividades</li>
      </ol>
    </nav>

    <div class="row">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">📋 Catálogo de Actividades Comerciales</h4>
            <span class="badge bg-primary">{{ actividades.length }} Actividad(es)</span>
          </div>
          <div class="card-body">
            <!-- Filtros y Acciones -->
            <div class="row g-3 mb-4">
              <div class="col-md-6">
                <label for="filtroDescripcion" class="form-label">Buscar Actividad:</label>
                <input
                  v-model="filtros.descripcion"
                  @input="debounceSearch"
                  id="filtroDescripcion"
                  type="text"
                  class="form-control"
                  placeholder="Escriba para buscar por descripción..."
                />
              </div>
              <div class="col-md-3">
                <label for="filtroGiro" class="form-label">Filtrar por Giro:</label>
                <select v-model="filtros.giro" @change="buscarActividades" id="filtroGiro" class="form-select">
                  <option value="">Todos los giros</option>
                  <option v-for="giro in giros" :key="giro.id" :value="giro.id">
                    {{ giro.descripcion }}
                  </option>
                </select>
              </div>
              <div class="col-md-3">
                <label for="filtroEstatus" class="form-label">Estado:</label>
                <select v-model="filtros.estatus" @change="buscarActividades" id="filtroEstatus" class="form-select">
                  <option value="">Todos</option>
                  <option value="V">Vigentes</option>
                  <option value="C">Canceladas</option>
                </select>
              </div>
              <div class="col-12">
                <hr>
                <button class="btn btn-success me-2" @click="abrirModalNueva">
                  ➕ Nueva Actividad
                </button>
                <button class="btn btn-secondary" @click="limpiarFiltros">
                  🗑️ Limpiar Filtros
                </button>
              </div>
            </div>

            <!-- Tabla de Actividades -->
            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-dark">
                  <tr>
                    <th width="60">ID</th>
                    <th>Giro</th>
                    <th>Descripción</th>
                    <th>Observaciones</th>
                    <th width="100">Estado</th>
                    <th width="110">Fecha Alta</th>
                    <th width="120">Usuario Alta</th>
                    <th width="140">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="actividad in actividades" :key="actividad.id">
                    <td>
                      <code>{{ actividad.id }}</code>
                    </td>
                    <td>
                      <span class="badge bg-info">{{ obtenerNombreGiro(actividad.id_giro) }}</span>
                    </td>
                    <td>
                      <strong>{{ actividad.descripcion }}</strong>
                    </td>
                    <td>
                      <small class="text-muted">{{ actividad.observaciones || 'Sin observaciones' }}</small>
                    </td>
                    <td>
                      <span class="badge" :class="actividad.vigente === 'V' ? 'bg-success' : 'bg-danger'">
                        {{ actividad.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                      </span>
                    </td>
                    <td>
                      <small>{{ formatearFecha(actividad.fecha_alta) }}</small>
                    </td>
                    <td>
                      <small class="text-muted">{{ actividad.usuario_alta || '-' }}</small>
                    </td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button
                          class="btn btn-outline-primary"
                          @click="abrirModalEditar(actividad)"
                          title="Editar actividad"
                        >
                          ✏️
                        </button>
                        <button
                          class="btn btn-outline-danger"
                          @click="confirmarEliminar(actividad)"
                          :disabled="actividad.vigente !== 'V'"
                          title="Eliminar actividad"
                        >
                          🗑️
                        </button>
                        <button
                          class="btn btn-outline-info"
                          @click="verDetalleActividad(actividad)"
                          title="Ver detalles"
                        >
                          👁️
                        </button>
                      </div>
                    </td>
                  </tr>
                  <tr v-if="actividades.length === 0 && !loading">
                    <td colspan="8" class="text-center py-4">
                      <div class="text-muted">
                        <i class="fas fa-search fa-3x mb-3"></i>
                        <br>
                        No se encontraron actividades con los criterios especificados
                      </div>
                    </td>
                  </tr>
                  <tr v-if="loading">
                    <td colspan="8" class="text-center py-4">
                      <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                      </div>
                      <br>
                      <small class="text-muted">Cargando actividades...</small>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="mensaje.texto" class="row mt-3">
      <div class="col-12">
        <div :class="`alert alert-${mensaje.tipo} alert-dismissible fade show`" role="alert">
          {{ mensaje.texto }}
          <button type="button" class="btn-close" @click="mensaje.texto = ''"></button>
        </div>
      </div>
    </div>

    <!-- Modal Formulario -->
    <div class="modal fade" id="modalFormulario" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ esEdicion ? '✏️ Editar Actividad' : '➕ Nueva Actividad' }}
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <form @submit.prevent="guardarActividad">
            <div class="modal-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <label for="formGiro" class="form-label">Giro: <span class="text-danger">*</span></label>
                  <select v-model="form.id_giro" id="formGiro" class="form-select" required>
                    <option value="">Seleccione un giro</option>
                    <option v-for="giro in giros" :key="giro.id" :value="giro.id">
                      {{ giro.codigo }} - {{ giro.descripcion }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label for="formEstatus" class="form-label">Estado: <span class="text-danger">*</span></label>
                  <select v-model="form.vigente" id="formEstatus" class="form-select" required>
                    <option value="V">Vigente</option>
                    <option value="C">Cancelada</option>
                  </select>
                </div>
                <div class="col-12">
                  <label for="formDescripcion" class="form-label">Descripción: <span class="text-danger">*</span></label>
                  <input
                    v-model="form.descripcion"
                    id="formDescripcion"
                    type="text"
                    class="form-control"
                    required
                    maxlength="250"
                    placeholder="Descripción de la actividad comercial"
                  />
                  <div class="form-text">Máximo 250 caracteres</div>
                </div>
                <div class="col-12">
                  <label for="formObservaciones" class="form-label">Observaciones:</label>
                  <textarea
                    v-model="form.observaciones"
                    id="formObservaciones"
                    class="form-control"
                    rows="3"
                    maxlength="500"
                    placeholder="Observaciones adicionales (opcional)"
                  ></textarea>
                  <div class="form-text">Máximo 500 caracteres</div>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                Cancelar
              </button>
              <button type="submit" class="btn btn-success" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                {{ esEdicion ? '💾 Actualizar' : '💾 Guardar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal fade" id="modalDetalle" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">👁️ Detalle de Actividad</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="actividadDetalle">
            <div class="row">
              <div class="col-md-6">
                <h6>Información General</h6>
                <table class="table table-sm">
                  <tr><td><strong>ID:</strong></td><td>{{ actividadDetalle.id }}</td></tr>
                  <tr><td><strong>Descripción:</strong></td><td>{{ actividadDetalle.descripcion }}</td></tr>
                  <tr><td><strong>Giro:</strong></td><td>{{ obtenerNombreGiro(actividadDetalle.id_giro) }}</td></tr>
                  <tr><td><strong>Estado:</strong></td><td>{{ actividadDetalle.vigente === 'V' ? 'Vigente' : 'Cancelada' }}</td></tr>
                </table>
              </div>
              <div class="col-md-6">
                <h6>Auditoría</h6>
                <table class="table table-sm">
                  <tr><td><strong>Fecha Alta:</strong></td><td>{{ formatearFecha(actividadDetalle.fecha_alta) }}</td></tr>
                  <tr><td><strong>Usuario Alta:</strong></td><td>{{ actividadDetalle.usuario_alta || '-' }}</td></tr>
                  <tr><td><strong>Fecha Baja:</strong></td><td>{{ formatearFecha(actividadDetalle.fecha_baja) }}</td></tr>
                  <tr><td><strong>Usuario Baja:</strong></td><td>{{ actividadDetalle.usuario_baja || '-' }}</td></tr>
                </table>
              </div>
            </div>
            <div class="row mt-3" v-if="actividadDetalle.observaciones">
              <div class="col-12">
                <h6>Observaciones</h6>
                <div class="alert alert-info">
                  {{ actividadDetalle.observaciones }}
                </div>
              </div>
            </div>
            <div class="row mt-3" v-if="actividadDetalle.motivo_baja">
              <div class="col-12">
                <h6>Motivo de Baja</h6>
                <div class="alert alert-warning">
                  {{ actividadDetalle.motivo_baja }}
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            <button
              v-if="actividadDetalle && actividadDetalle.vigente === 'V'"
              type="button"
              class="btn btn-primary"
              @click="abrirModalEditarDetalle"
              data-bs-dismiss="modal"
            >
              Editar Actividad
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatalogoActividadesPage',
  data() {
    return {
      loading: false,
      actividades: [],
      giros: [],
      filtros: {
        descripcion: '',
        giro: '',
        estatus: ''
      },
      esEdicion: false,
      form: {
        id: null,
        id_giro: '',
        descripcion: '',
        observaciones: '',
        vigente: 'V'
      },
      actividadDetalle: null,
      mensaje: {
        texto: '',
        tipo: 'info'
      },
      searchTimeout: null
    };
  },
  mounted() {
    this.cargarGiros();
    this.cargarActividades();
  },
  methods: {
    async cargarGiros() {
      try {
        const eRequest = {
          Operacion: 'sp_giros_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.giros = data.eResponse.data || [];
        }
      } catch (error) {
        console.error('Error al cargar giros:', error);
        this.mostrarMensaje('Error al cargar los giros disponibles', 'danger');
      }
    },

    async cargarActividades() {
      this.loading = true;
      try {
        const eRequest = {
          Operacion: 'sp_actividades_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.actividades = data.eResponse.data || [];
        } else {
          this.mostrarMensaje('Error al cargar actividades: ' + (data.eResponse?.message || 'Error desconocido'), 'danger');
        }
      } catch (error) {
        console.error('Error al cargar actividades:', error);
        this.mostrarMensaje('Error de conexión al cargar actividades', 'danger');
      } finally {
        this.loading = false;
      }
    },

    async buscarActividades() {
      this.loading = true;
      try {
        const eRequest = {
          Operacion: 'sp_actividades_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_descripcion', valor: this.filtros.descripcion || null, tipo: 'varchar' },
            { nombre: 'p_id_giro', valor: this.filtros.giro || null, tipo: 'integer' },
            { nombre: 'p_estatus', valor: this.filtros.estatus || null, tipo: 'char' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.actividades = data.eResponse.data || [];
          if (this.actividades.length === 0) {
            this.mostrarMensaje('No se encontraron actividades con los criterios especificados', 'info');
          }
        } else {
          this.mostrarMensaje('Error al buscar actividades: ' + (data.eResponse?.message || 'Error desconocido'), 'danger');
        }
      } catch (error) {
        console.error('Error al buscar actividades:', error);
        this.mostrarMensaje('Error de conexión al buscar actividades', 'danger');
      } finally {
        this.loading = false;
      }
    },

    debounceSearch() {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        this.buscarActividades();
      }, 500);
    },

    limpiarFiltros() {
      this.filtros = {
        descripcion: '',
        giro: '',
        estatus: ''
      };
      this.cargarActividades();
    },

    abrirModalNueva() {
      this.form = {
        id: null,
        id_giro: '',
        descripcion: '',
        observaciones: '',
        vigente: 'V'
      };
      this.esEdicion = false;
      const modal = new bootstrap.Modal(document.getElementById('modalFormulario'));
      modal.show();
    },

    abrirModalEditar(actividad) {
      this.form = {
        id: actividad.id,
        id_giro: actividad.id_giro,
        descripcion: actividad.descripcion,
        observaciones: actividad.observaciones || '',
        vigente: actividad.vigente
      };
      this.esEdicion = true;
      const modal = new bootstrap.Modal(document.getElementById('modalFormulario'));
      modal.show();
    },

    abrirModalEditarDetalle() {
      if (this.actividadDetalle) {
        this.abrirModalEditar(this.actividadDetalle);
      }
    },

    async guardarActividad() {
      if (!this.form.id_giro || !this.form.descripcion.trim()) {
        this.mostrarMensaje('Debe seleccionar un giro y escribir una descripción', 'warning');
        return;
      }

      this.loading = true;
      try {
        const operacion = this.esEdicion ? 'sp_actividad_actualizar' : 'sp_actividad_crear';
        const parametros = this.esEdicion ? [
          { nombre: 'p_id', valor: this.form.id, tipo: 'integer' },
          { nombre: 'p_id_giro', valor: parseInt(this.form.id_giro), tipo: 'integer' },
          { nombre: 'p_descripcion', valor: this.form.descripcion, tipo: 'varchar' },
          { nombre: 'p_observaciones', valor: this.form.observaciones || null, tipo: 'varchar' },
          { nombre: 'p_vigente', valor: this.form.vigente, tipo: 'char' },
          { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
        ] : [
          { nombre: 'p_id_giro', valor: parseInt(this.form.id_giro), tipo: 'integer' },
          { nombre: 'p_descripcion', valor: this.form.descripcion, tipo: 'varchar' },
          { nombre: 'p_observaciones', valor: this.form.observaciones || null, tipo: 'varchar' },
          { nombre: 'p_vigente', valor: this.form.vigente, tipo: 'char' },
          { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
        ];

        const eRequest = {
          Operacion: operacion,
          Base: 'licencias',
          Parametros: parametros,
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.mostrarMensaje(
            this.esEdicion ? 'Actividad actualizada exitosamente' : 'Actividad creada exitosamente',
            'success'
          );
          this.buscarActividades();
          bootstrap.Modal.getInstance(document.getElementById('modalFormulario')).hide();
        } else {
          this.mostrarMensaje(
            'Error al guardar: ' + (data.eResponse?.message || 'Error desconocido'),
            'danger'
          );
        }
      } catch (error) {
        console.error('Error al guardar actividad:', error);
        this.mostrarMensaje('Error de conexión al guardar', 'danger');
      } finally {
        this.loading = false;
      }
    },

    async confirmarEliminar(actividad) {
      if (!confirm(`¿Está seguro de eliminar la actividad "${actividad.descripcion}"?`)) {
        return;
      }

      await this.eliminarActividad(actividad);
    },

    async eliminarActividad(actividad) {
      this.loading = true;
      try {
        const eRequest = {
          Operacion: 'sp_actividad_eliminar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: actividad.id, tipo: 'integer' },
            { nombre: 'p_motivo_baja', valor: 'Eliminación manual por usuario', tipo: 'varchar' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.mostrarMensaje('Actividad eliminada exitosamente', 'success');
          this.buscarActividades();
        } else {
          this.mostrarMensaje(
            'Error al eliminar: ' + (data.eResponse?.message || 'Error desconocido'),
            'danger'
          );
        }
      } catch (error) {
        console.error('Error al eliminar actividad:', error);
        this.mostrarMensaje('Error de conexión al eliminar', 'danger');
      } finally {
        this.loading = false;
      }
    },

    verDetalleActividad(actividad) {
      this.actividadDetalle = actividad;
      const modal = new bootstrap.Modal(document.getElementById('modalDetalle'));
      modal.show();
    },

    obtenerNombreGiro(id_giro) {
      const giro = this.giros.find(g => g.id === id_giro);
      return giro ? giro.descripcion : `ID: ${id_giro}`;
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      try {
        return new Date(fecha).toLocaleDateString('es-MX', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric'
        });
      } catch {
        return fecha;
      }
    },

    mostrarMensaje(texto, tipo = 'info') {
      this.mensaje = { texto, tipo };
      setTimeout(() => {
        this.mensaje.texto = '';
      }, 5000);
    }
  }
};
</script>

<style scoped>
/* Estilos específicos para el catálogo de actividades */
.table th {
  font-weight: 600;
  white-space: nowrap;
}

.card-header {
  border-bottom: 2px solid #dee2e6;
}

.btn-group-sm .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.badge {
  font-size: 0.75em;
}

.table-responsive {
  max-height: 600px;
  overflow-y: auto;
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}
</style>
