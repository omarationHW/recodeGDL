<template>
  <div class="container-fluid">
    <div class="row">
      <div class="col-12">
        <!-- Header Card -->
        <div class="card mb-4">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">
              <i class="fas fa-certificate text-primary me-2"></i>
              Certificación de Licencias y Anuncios
            </h4>
          </div>
          <div class="card-body">
            <div class="btn-group" role="group">
              <button
                @click="showForm('new')"
                class="btn btn-primary"
                :disabled="cargando">
                <i class="fas fa-plus me-1"></i>Nueva
              </button>
              <button
                :disabled="!selectedId || cargando"
                @click="showForm('edit')"
                class="btn btn-warning">
                <i class="fas fa-edit me-1"></i>Modificar
              </button>
              <button
                :disabled="!selectedId || cargando"
                @click="cancelCert"
                class="btn btn-danger">
                <i class="fas fa-ban me-1"></i>Cancelar
              </button>
              <button
                :disabled="!selectedId || cargando"
                @click="printCert"
                class="btn btn-info">
                <i class="fas fa-print me-1"></i>Imprimir
              </button>
              <button
                @click="showListado"
                class="btn btn-secondary"
                :disabled="cargando">
                <i class="fas fa-list me-1"></i>Listado
              </button>
            </div>
          </div>
        </div>

        <!-- Search Card -->
        <div class="card mb-4" v-if="showListadoTable">
          <div class="card-header">
            <h5 class="mb-0">
              <i class="fas fa-search text-secondary me-2"></i>
              Filtros de Búsqueda
            </h5>
          </div>
          <div class="card-body">
            <form @submit.prevent="fetchListado" class="row g-3">
              <div class="col-md-2">
                <label class="form-label">Año</label>
                <input
                  v-model="search.axo"
                  type="number"
                  class="form-control"
                  placeholder="Año">
              </div>
              <div class="col-md-2">
                <label class="form-label">Folio</label>
                <input
                  v-model="search.folio"
                  type="number"
                  class="form-control"
                  placeholder="Folio">
              </div>
              <div class="col-md-2">
                <label class="form-label">Licencia/Anuncio</label>
                <input
                  v-model="search.id_licencia"
                  type="number"
                  class="form-control"
                  placeholder="ID">
              </div>
              <div class="col-md-2">
                <label class="form-label">Fecha Inicio</label>
                <input
                  v-model="search.feccap_ini"
                  type="date"
                  class="form-control">
              </div>
              <div class="col-md-2">
                <label class="form-label">Fecha Fin</label>
                <input
                  v-model="search.feccap_fin"
                  type="date"
                  class="form-control">
              </div>
              <div class="col-md-2">
                <label class="form-label">Tipo</label>
                <select v-model="search.tipo" class="form-select">
                  <option value="">Todos</option>
                  <option value="L">Licencia</option>
                  <option value="A">Anuncio</option>
                </select>
              </div>
              <div class="col-12">
                <button
                  type="submit"
                  class="btn btn-primary"
                  :disabled="cargando">
                  <i class="fas fa-search me-1"></i>
                  {{ cargando ? 'Buscando...' : 'Buscar' }}
                </button>
                <button
                  type="button"
                  @click="limpiarFiltros"
                  class="btn btn-secondary ms-2">
                  <i class="fas fa-eraser me-1"></i>Limpiar
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Results Card -->
        <div class="card" v-if="showListadoTable">
          <div class="card-header">
            <h5 class="mb-0">
              <i class="fas fa-list text-success me-2"></i>
              Certificaciones Encontradas ({{ listado.length }})
            </h5>
          </div>
          <div class="card-body">
            <div v-if="cargando" class="text-center py-4">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Cargando...</span>
              </div>
              <p class="mt-2">Cargando certificaciones...</p>
            </div>

            <div v-else-if="listado.length === 0" class="text-center py-4">
              <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
              <p class="text-muted">No se encontraron certificaciones con los filtros especificados</p>
            </div>

            <div v-else class="table-responsive">
              <table class="table table-hover table-striped">
                <thead class="table-dark">
                  <tr>
                    <th>Año</th>
                    <th>Folio</th>
                    <th>Licencia/Anuncio</th>
                    <th>Tipo</th>
                    <th>Observación</th>
                    <th>Estado</th>
                    <th>Fecha</th>
                    <th>Capturista</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="row in listado"
                    :key="row.id"
                    @click="selectRow(row)"
                    :class="{ 'table-active': selectedId === row.id }"
                    style="cursor: pointer;">
                    <td>{{ row.axo }}</td>
                    <td>{{ row.folio }}</td>
                    <td>{{ row.licencia || row.id_licencia }}</td>
                    <td>
                      <span :class="row.tipo === 'L' ? 'badge bg-primary' : 'badge bg-info'">
                        {{ row.tipo === 'L' ? 'Licencia' : 'Anuncio' }}
                      </span>
                    </td>
                    <td>{{ row.observacion || '-' }}</td>
                    <td>
                      <span :class="row.vigente === 'V' ? 'badge bg-success' : 'badge bg-danger'">
                        {{ row.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                      </span>
                    </td>
                    <td>{{ formatearFecha(row.feccap) }}</td>
                    <td>{{ row.capturista || '-' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Form Modal -->
    <div class="modal fade" ref="formModal" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i :class="formMode === 'new' ? 'fas fa-plus' : 'fas fa-edit'" class="me-2"></i>
              {{ formMode === 'new' ? 'Nueva Certificación' : 'Modificar Certificación' }}
            </h5>
            <button type="button" class="btn-close" @click="closeForm"></button>
          </div>
          <form @submit.prevent="submitForm">
            <div class="modal-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Tipo <span class="text-danger">*</span></label>
                  <select v-model="form.tipo" class="form-select" required>
                    <option value="L">Licencia</option>
                    <option value="A">Anuncio</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">
                    {{ form.tipo === 'L' ? 'Licencia ID' : 'Anuncio ID' }} <span class="text-danger">*</span>
                  </label>
                  <input
                    v-model.number="form.id_licencia"
                    type="number"
                    class="form-control"
                    required
                    :placeholder="form.tipo === 'L' ? 'ID de la licencia' : 'ID del anuncio'">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Observación</label>
                  <input
                    v-model="form.observacion"
                    maxlength="200"
                    class="form-control"
                    placeholder="Observaciones de la certificación">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Partida de Pago</label>
                  <input
                    v-model="form.partidapago"
                    maxlength="25"
                    class="form-control"
                    placeholder="Partida de pago">
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-secondary"
                @click="closeForm">
                <i class="fas fa-times me-1"></i>Cancelar
              </button>
              <button
                type="submit"
                class="btn btn-primary"
                :disabled="guardando">
                <i class="fas fa-save me-1"></i>
                {{ guardando ? 'Guardando...' : 'Guardar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Print Modal -->
    <div class="modal fade" ref="printModal" tabindex="-1">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-print me-2"></i>
              Vista Previa de Impresión
            </h5>
            <button type="button" class="btn-close" @click="closePrint"></button>
          </div>
          <div class="modal-body">
            <div v-if="!printData" class="text-center py-4">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Generando vista previa...</span>
              </div>
              <p class="mt-2">Preparando documento para impresión...</p>
            </div>
            <div v-else>
              <pre class="bg-light p-3 rounded">{{ printData }}</pre>
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              @click="closePrint">
              <i class="fas fa-times me-1"></i>Cerrar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              v-if="printData"
              @click="imprimirDocumento">
              <i class="fas fa-print me-1"></i>Imprimir
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Cancel Modal -->
    <div class="modal fade" ref="cancelModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-ban text-danger me-2"></i>
              Cancelar Certificación
            </h5>
            <button type="button" class="btn-close" @click="closeCancel"></button>
          </div>
          <form @submit.prevent="confirmCancel">
            <div class="modal-body">
              <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Esta acción cancelará permanentemente la certificación seleccionada.
              </div>
              <div class="mb-3">
                <label class="form-label">Motivo de cancelación <span class="text-danger">*</span></label>
                <textarea
                  v-model="cancelMotivo"
                  class="form-control"
                  rows="3"
                  required
                  placeholder="Ingrese el motivo de la cancelación..."></textarea>
              </div>
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-secondary"
                @click="closeCancel">
                <i class="fas fa-times me-1"></i>Cancelar
              </button>
              <button
                type="submit"
                class="btn btn-danger"
                :disabled="cancelando">
                <i class="fas fa-ban me-1"></i>
                {{ cancelando ? 'Cancelando...' : 'Confirmar Cancelación' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Alerts -->
    <div
      v-if="alerta.mostrar"
      :class="`alert alert-${alerta.tipo} alert-dismissible fade show position-fixed`"
      style="top: 20px; right: 20px; z-index: 9999; min-width: 300px;">
      <i :class="`fas ${alerta.icono} me-2`"></i>
      {{ alerta.mensaje }}
      <button type="button" class="btn-close" @click="cerrarAlerta"></button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CertificacionesFrm',
  data() {
    return {
      listado: [],
      selectedId: null,
      showFormDialog: false,
      showListadoTable: true,
      showPrintDialog: false,
      showCancelDialog: false,
      formMode: 'new',
      cargando: false,
      guardando: false,
      cancelando: false,
      form: {
        tipo: 'L',
        id_licencia: '',
        observacion: '',
        partidapago: ''
      },
      search: {
        axo: '',
        folio: '',
        id_licencia: '',
        feccap_ini: '',
        feccap_fin: '',
        tipo: ''
      },
      printData: null,
      cancelMotivo: '',
      alerta: {
        mostrar: false,
        tipo: 'info',
        mensaje: '',
        icono: 'fa-info-circle'
      }
    };
  },
  mounted() {
    this.fetchListado();
  },
  methods: {
    async fetchListado() {
      this.cargando = true;
      this.selectedId = null;
      try {
        const eRequest = {
          Operacion: 'sp_certificaciones_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_axo', valor: this.search.axo || null, tipo: 'integer' },
            { nombre: 'p_folio', valor: this.search.folio || null, tipo: 'integer' },
            { nombre: 'p_id_licencia', valor: this.search.id_licencia || null, tipo: 'integer' },
            { nombre: 'p_fecha_inicio', valor: this.search.feccap_ini || null, tipo: 'date' },
            { nombre: 'p_fecha_fin', valor: this.search.feccap_fin || null, tipo: 'date' },
            { nombre: 'p_tipo', valor: this.search.tipo || null, tipo: 'char' }
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
        this.listado = data.eResponse?.Resultado || [];
      } catch (error) {
        console.error('Error al cargar certificaciones:', error);
        this.mostrarAlerta('error', 'Error al cargar certificaciones', 'fa-exclamation-circle');
        this.listado = [];
      } finally {
        this.cargando = false;
      }
    },

    selectRow(row) {
      this.selectedId = row.id;
      this.form = { ...row };
    },

    showForm(mode) {
      this.formMode = mode;
      if (mode === 'edit' && this.selectedId) {
        const selectedItem = this.listado.find(r => r.id === this.selectedId);
        if (selectedItem) {
          this.form = { ...selectedItem };
        }
      } else {
        this.form = {
          tipo: 'L',
          id_licencia: '',
          observacion: '',
          partidapago: ''
        };
      }
      this.showFormDialog = true;
      this.showListadoTable = false;
      this.$nextTick(() => {
        const modal = new bootstrap.Modal(this.$refs.formModal);
        modal.show();
      });
    },

    closeForm() {
      this.showFormDialog = false;
      this.showListadoTable = true;
      const modal = bootstrap.Modal.getInstance(this.$refs.formModal);
      if (modal) modal.hide();
    },

    async submitForm() {
      this.guardando = true;
      try {
        const operacion = this.formMode === 'new' ? 'sp_certificacion_crear' : 'sp_certificacion_actualizar';
        const parametros = this.formMode === 'new' ? [
          { nombre: 'p_tipo', valor: this.form.tipo, tipo: 'char' },
          { nombre: 'p_id_licencia', valor: this.form.id_licencia, tipo: 'integer' },
          { nombre: 'p_observacion', valor: this.form.observacion || null, tipo: 'varchar' },
          { nombre: 'p_partidapago', valor: this.form.partidapago || null, tipo: 'varchar' },
          { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
        ] : [
          { nombre: 'p_id', valor: this.form.id, tipo: 'integer' },
          { nombre: 'p_tipo', valor: this.form.tipo, tipo: 'char' },
          { nombre: 'p_id_licencia', valor: this.form.id_licencia, tipo: 'integer' },
          { nombre: 'p_observacion', valor: this.form.observacion || null, tipo: 'varchar' },
          { nombre: 'p_partidapago', valor: this.form.partidapago || null, tipo: 'varchar' },
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

        if (data.eResponse?.success) {
          this.mostrarAlerta('success', data.eResponse.message, 'fa-check-circle');
          this.closeForm();
          this.fetchListado();
        } else {
          this.mostrarAlerta('error', data.eResponse?.message || 'Error al guardar', 'fa-exclamation-circle');
        }
      } catch (error) {
        console.error('Error al guardar certificación:', error);
        this.mostrarAlerta('error', 'Error al guardar certificación', 'fa-exclamation-circle');
      } finally {
        this.guardando = false;
      }
    },

    cancelCert() {
      if (!this.selectedId) return;
      this.cancelMotivo = '';
      this.showCancelDialog = true;
      this.$nextTick(() => {
        const modal = new bootstrap.Modal(this.$refs.cancelModal);
        modal.show();
      });
    },

    async confirmCancel() {
      this.cancelando = true;
      try {
        const eRequest = {
          Operacion: 'sp_certificacion_cancelar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: this.selectedId, tipo: 'integer' },
            { nombre: 'p_motivo', valor: this.cancelMotivo, tipo: 'varchar' },
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

        if (data.eResponse?.success) {
          this.mostrarAlerta('success', data.eResponse.message, 'fa-check-circle');
          this.closeCancel();
          this.fetchListado();
        } else {
          this.mostrarAlerta('error', data.eResponse?.message || 'Error al cancelar', 'fa-exclamation-circle');
        }
      } catch (error) {
        console.error('Error al cancelar certificación:', error);
        this.mostrarAlerta('error', 'Error al cancelar certificación', 'fa-exclamation-circle');
      } finally {
        this.cancelando = false;
      }
    },

    closeCancel() {
      this.showCancelDialog = false;
      const modal = bootstrap.Modal.getInstance(this.$refs.cancelModal);
      if (modal) modal.hide();
    },

    async printCert() {
      if (!this.selectedId) return;
      this.showPrintDialog = true;
      this.printData = null;

      this.$nextTick(() => {
        const modal = new bootstrap.Modal(this.$refs.printModal);
        modal.show();
      });

      try {
        const eRequest = {
          Operacion: 'sp_certificacion_imprimir',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: this.selectedId, tipo: 'integer' }
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
        this.printData = JSON.stringify(data.eResponse, null, 2);
      } catch (error) {
        console.error('Error al generar vista previa:', error);
        this.printData = 'Error al generar vista previa de impresión';
      }
    },

    closePrint() {
      this.showPrintDialog = false;
      const modal = bootstrap.Modal.getInstance(this.$refs.printModal);
      if (modal) modal.hide();
    },

    imprimirDocumento() {
      window.print();
    },

    showListado() {
      this.showListadoTable = true;
      this.showFormDialog = false;
      this.showPrintDialog = false;
      this.showCancelDialog = false;
      this.fetchListado();
    },

    limpiarFiltros() {
      this.search = {
        axo: '',
        folio: '',
        id_licencia: '',
        feccap_ini: '',
        feccap_fin: '',
        tipo: ''
      };
      this.fetchListado();
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      try {
        return new Date(fecha).toLocaleDateString('es-ES');
      } catch (error) {
        return fecha;
      }
    },

    mostrarAlerta(tipo, mensaje, icono) {
      this.alerta = {
        mostrar: true,
        tipo: tipo,
        mensaje: mensaje,
        icono: icono
      };
      setTimeout(() => {
        this.cerrarAlerta();
      }, 5000);
    },

    cerrarAlerta() {
      this.alerta.mostrar = false;
    }
  }
};
</script>

<style scoped>
.table-responsive {
  border-radius: 0.375rem;
}

.badge {
  font-size: 0.75em;
}

.modal-dialog {
  margin: 1rem auto;
}

@media (min-width: 576px) {
  .modal-dialog {
    margin: 1.75rem auto;
  }
}

.alert {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.card {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border: 1px solid rgba(0, 0, 0, 0.125);
}

.table > :not(caption) > * > * {
  padding: 0.75rem;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}
</style>