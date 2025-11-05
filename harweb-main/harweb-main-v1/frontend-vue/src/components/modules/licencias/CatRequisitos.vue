<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/licencias">Licencias</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Requisitos</li>
      </ol>
    </nav>

    <div class="row">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">📋 Catálogo de Requisitos</h4>
            <span class="badge bg-primary">{{ requisitos.length }} Requisito(s)</span>
          </div>
          <div class="card-body">
            <!-- Filtros y Acciones -->
            <div class="row g-3 mb-4">
              <div class="col-md-8">
                <label for="filtroDescripcion" class="form-label">Buscar Requisito:</label>
                <input
                  v-model="filtros.descripcion"
                  @input="debounceSearch"
                  id="filtroDescripcion"
                  type="text"
                  class="form-control"
                  placeholder="Escriba para buscar por descripción..."
                />
              </div>
              <div class="col-md-4">
                <label class="form-label">&nbsp;</label>
                <div class="d-flex gap-2">
                  <button class="btn btn-success" @click="abrirModalNuevo">
                    ➕ Nuevo Requisito
                  </button>
                  <button class="btn btn-info" @click="abrirModalImprimir">
                    🖨️ Imprimir
                  </button>
                </div>
              </div>
            </div>

            <!-- Tabla de Requisitos -->
            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-dark">
                  <tr>
                    <th width="80">Número</th>
                    <th>Descripción</th>
                    <th width="100">Estado</th>
                    <th width="140">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="requisito in requisitos" :key="requisito.id">
                    <td>
                      <span class="badge bg-secondary">{{ requisito.numero }}</span>
                    </td>
                    <td>
                      <strong>{{ requisito.descripcion }}</strong>
                    </td>
                    <td>
                      <span class="badge" :class="requisito.activo === 'S' ? 'bg-success' : 'bg-danger'">
                        {{ requisito.activo === 'S' ? 'Activo' : 'Inactivo' }}
                      </span>
                    </td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button
                          class="btn btn-outline-primary"
                          @click="abrirModalEditar(requisito)"
                          title="Editar requisito"
                        >
                          ✏️
                        </button>
                        <button
                          class="btn btn-outline-danger"
                          @click="confirmarEliminar(requisito)"
                          :disabled="requisito.activo !== 'S'"
                          title="Eliminar requisito"
                        >
                          🗑️
                        </button>
                        <button
                          class="btn btn-outline-info"
                          @click="verDetalleRequisito(requisito)"
                          title="Ver detalles"
                        >
                          👁️
                        </button>
                      </div>
                    </td>
                  </tr>
                  <tr v-if="requisitos.length === 0 && !loading">
                    <td colspan="4" class="text-center py-4">
                      <div class="text-muted">
                        <i class="fas fa-search fa-3x mb-3"></i>
                        <br>
                        No se encontraron requisitos
                      </div>
                    </td>
                  </tr>
                  <tr v-if="loading">
                    <td colspan="4" class="text-center py-4">
                      <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                      </div>
                      <br>
                      <small class="text-muted">Cargando requisitos...</small>
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
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ esEdicion ? '✏️ Editar Requisito' : '➕ Nuevo Requisito' }}
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <form @submit.prevent="guardarRequisito">
            <div class="modal-body">
              <div class="row g-3">
                <div class="col-md-6" v-if="esEdicion">
                  <label for="formNumero" class="form-label">Número:</label>
                  <input
                    v-model="form.numero"
                    id="formNumero"
                    type="number"
                    class="form-control"
                    readonly
                  />
                </div>
                <div class="col-md-6">
                  <label for="formEstado" class="form-label">Estado:</label>
                  <select v-model="form.activo" id="formEstado" class="form-select" required>
                    <option value="S">Activo</option>
                    <option value="N">Inactivo</option>
                  </select>
                </div>
                <div class="col-12">
                  <label for="formDescripcion" class="form-label">Descripción: <span class="text-danger">*</span></label>
                  <textarea
                    v-model="form.descripcion"
                    id="formDescripcion"
                    class="form-control"
                    rows="3"
                    required
                    maxlength="255"
                    placeholder="Descripción del requisito"
                  ></textarea>
                  <div class="form-text">Máximo 255 caracteres</div>
                </div>
                <div class="col-12" v-if="!esEdicion">
                  <div class="alert alert-info">
                    <i class="fas fa-info-circle me-2"></i>
                    El número de requisito se asignará automáticamente
                  </div>
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
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">👁️ Detalle del Requisito</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="requisitoDetalle">
            <table class="table table-sm">
              <tr><td><strong>Número:</strong></td><td>{{ requisitoDetalle.numero }}</td></tr>
              <tr><td><strong>Descripción:</strong></td><td>{{ requisitoDetalle.descripcion }}</td></tr>
              <tr><td><strong>Estado:</strong></td><td>{{ requisitoDetalle.activo === 'S' ? 'Activo' : 'Inactivo' }}</td></tr>
              <tr><td><strong>Fecha Creación:</strong></td><td>{{ formatearFecha(requisitoDetalle.fecha_creacion) }}</td></tr>
              <tr><td><strong>Última Actualización:</strong></td><td>{{ formatearFecha(requisitoDetalle.fecha_actualizacion) }}</td></tr>
            </table>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            <button
              v-if="requisitoDetalle && requisitoDetalle.activo === 'S'"
              type="button"
              class="btn btn-primary"
              @click="abrirModalEditarDetalle"
              data-bs-dismiss="modal"
            >
              Editar Requisito
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Imprimir -->
    <div class="modal fade" id="modalImprimir" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">🖨️ Listado de Requisitos</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <div class="table-responsive">
              <table class="table table-bordered">
                <thead>
                  <tr>
                    <th>Número</th>
                    <th>Descripción</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="req in requisitos" :key="req.id">
                    <td>{{ req.numero }}</td>
                    <td>{{ req.descripcion }}</td>
                    <td>{{ req.activo === 'S' ? 'Activo' : 'Inactivo' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            <button type="button" class="btn btn-success" @click="imprimirListado">
              🖨️ Imprimir
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatRequisitosPage',
  data() {
    return {
      loading: false,
      requisitos: [],
      filtros: {
        descripcion: ''
      },
      esEdicion: false,
      form: {
        id: null,
        numero: '',
        descripcion: '',
        activo: 'S'
      },
      requisitoDetalle: null,
      mensaje: {
        texto: '',
        tipo: 'info'
      },
      searchTimeout: null
    };
  },
  mounted() {
    this.cargarRequisitos();
  },
  methods: {
    async cargarRequisitos() {
      this.loading = true;
      try {
        const eRequest = {
          Operacion: 'sp_requisitos_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.requisitos = data.eResponse.data || [];
        } else {
          this.mostrarMensaje('Error al cargar requisitos: ' + (data.eResponse?.message || 'Error desconocido'), 'danger');
        }
      } catch (error) {
        console.error('Error al cargar requisitos:', error);
        this.mostrarMensaje('Error de conexión al cargar requisitos', 'danger');
      } finally {
        this.loading = false;
      }
    },

    async buscarRequisitos() {
      this.loading = true;
      try {
        const eRequest = {
          Operacion: 'sp_requisitos_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_descripcion', valor: this.filtros.descripcion || null, tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.requisitos = data.eResponse.data || [];
          if (this.requisitos.length === 0) {
            this.mostrarMensaje('No se encontraron requisitos con los criterios especificados', 'info');
          }
        } else {
          this.mostrarMensaje('Error al buscar requisitos: ' + (data.eResponse?.message || 'Error desconocido'), 'danger');
        }
      } catch (error) {
        console.error('Error al buscar requisitos:', error);
        this.mostrarMensaje('Error de conexión al buscar requisitos', 'danger');
      } finally {
        this.loading = false;
      }
    },

    debounceSearch() {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        if (this.filtros.descripcion.trim()) {
          this.buscarRequisitos();
        } else {
          this.cargarRequisitos();
        }
      }, 500);
    },

    abrirModalNuevo() {
      this.form = {
        id: null,
        numero: '',
        descripcion: '',
        activo: 'S'
      };
      this.esEdicion = false;
      const modal = new bootstrap.Modal(document.getElementById('modalFormulario'));
      modal.show();
    },

    abrirModalEditar(requisito) {
      this.form = {
        id: requisito.id,
        numero: requisito.numero,
        descripcion: requisito.descripcion,
        activo: requisito.activo
      };
      this.esEdicion = true;
      const modal = new bootstrap.Modal(document.getElementById('modalFormulario'));
      modal.show();
    },

    abrirModalEditarDetalle() {
      if (this.requisitoDetalle) {
        this.abrirModalEditar(this.requisitoDetalle);
      }
    },

    async guardarRequisito() {
      if (!this.form.descripcion.trim()) {
        this.mostrarMensaje('La descripción es obligatoria', 'warning');
        return;
      }

      this.loading = true;
      try {
        const operacion = this.esEdicion ? 'sp_requisito_actualizar' : 'sp_requisito_crear';
        const parametros = this.esEdicion ? [
          { nombre: 'p_id', valor: this.form.id, tipo: 'integer' },
          { nombre: 'p_descripcion', valor: this.form.descripcion, tipo: 'varchar' },
          { nombre: 'p_activo', valor: this.form.activo, tipo: 'char' },
          { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
        ] : [
          { nombre: 'p_descripcion', valor: this.form.descripcion, tipo: 'varchar' },
          { nombre: 'p_activo', valor: this.form.activo, tipo: 'char' },
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
          body: JSON.stringify({ eRequest })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.mostrarMensaje(
            this.esEdicion ? 'Requisito actualizado exitosamente' : 'Requisito creado exitosamente',
            'success'
          );
          this.cargarRequisitos();
          bootstrap.Modal.getInstance(document.getElementById('modalFormulario')).hide();
        } else {
          this.mostrarMensaje(
            'Error al guardar: ' + (data.eResponse?.message || 'Error desconocido'),
            'danger'
          );
        }
      } catch (error) {
        console.error('Error al guardar requisito:', error);
        this.mostrarMensaje('Error de conexión al guardar', 'danger');
      } finally {
        this.loading = false;
      }
    },

    async confirmarEliminar(requisito) {
      if (!confirm(`¿Está seguro de eliminar el requisito "${requisito.descripcion}"?`)) {
        return;
      }

      await this.eliminarRequisito(requisito);
    },

    async eliminarRequisito(requisito) {
      this.loading = true;
      try {
        const eRequest = {
          Operacion: 'sp_requisito_eliminar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: requisito.id, tipo: 'integer' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.mostrarMensaje('Requisito eliminado exitosamente', 'success');
          this.cargarRequisitos();
        } else {
          this.mostrarMensaje(
            'Error al eliminar: ' + (data.eResponse?.message || 'Error desconocido'),
            'danger'
          );
        }
      } catch (error) {
        console.error('Error al eliminar requisito:', error);
        this.mostrarMensaje('Error de conexión al eliminar', 'danger');
      } finally {
        this.loading = false;
      }
    },

    verDetalleRequisito(requisito) {
      this.requisitoDetalle = requisito;
      const modal = new bootstrap.Modal(document.getElementById('modalDetalle'));
      modal.show();
    },

    abrirModalImprimir() {
      const modal = new bootstrap.Modal(document.getElementById('modalImprimir'));
      modal.show();
    },

    imprimirListado() {
      window.print();
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      try {
        return new Date(fecha).toLocaleDateString('es-MX', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
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
/* Estilos específicos para el catálogo de requisitos */
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
  max-height: 500px;
  overflow-y: auto;
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

@media print {
  .btn, .card-header, .breadcrumb {
    display: none !important;
  }
}
</style>
