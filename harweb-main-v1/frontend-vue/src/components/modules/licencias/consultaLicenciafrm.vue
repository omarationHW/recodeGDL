<template>
  <div class="container-fluid py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h1 class="h2 mb-0"><i class="fas fa-search me-2"></i>Consulta de Licencias</h1>
        <nav aria-label="breadcrumb">
          <ol class="breadcrumb mb-0">
            <li class="breadcrumb-item"><a href="#" class="text-decoration-none">Inicio</a></li>
            <li class="breadcrumb-item"><a href="#" class="text-decoration-none">Licencias</a></li>
            <li class="breadcrumb-item active" aria-current="page">Consulta</li>
          </ol>
        </nav>
      </div>
    </div>

    <!-- Formulario de Búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="card-title mb-0"><i class="fas fa-filter me-2"></i>Opciones de Búsqueda</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscar">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-bold">No. Licencia:</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-id-card"></i></span>
                <input v-model="form.licencia" type="text" class="form-control" placeholder="Ingrese número de licencia">
                <button type="button" @click="buscarPor('licencia')" class="btn btn-primary">
                  <i class="fas fa-search me-1"></i>Buscar
                </button>
              </div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-bold">Ubicación:</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-map-marker-alt"></i></span>
                <input v-model="form.ubicacion" type="text" class="form-control" placeholder="Ingrese ubicación">
                <button type="button" @click="buscarPor('ubicacion')" class="btn btn-primary">
                  <i class="fas fa-search me-1"></i>Buscar
                </button>
              </div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-bold">Contribuyente:</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-user"></i></span>
                <input v-model="form.propietario" type="text" class="form-control" placeholder="Ingrese nombre del contribuyente">
                <button type="button" @click="buscarPor('contribuyente')" class="btn btn-primary">
                  <i class="fas fa-search me-1"></i>Buscar
                </button>
              </div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-bold">No. Trámite:</label>
              <div class="input-group">
                <span class="input-group-text"><i class="fas fa-file-alt"></i></span>
                <input v-model="form.id_tramite" type="text" class="form-control" placeholder="Ingrese número de trámite">
                <button type="button" @click="buscarPor('tramite')" class="btn btn-primary">
                  <i class="fas fa-search me-1"></i>Buscar
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
    <!-- Resultados -->
    <div class="card mb-4" v-if="resultados.length">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="card-title mb-0"><i class="fas fa-list me-2"></i>Resultados ({{ resultados.length }})</h5>
        <button @click="exportarExcel" class="btn btn-success btn-sm">
          <i class="fas fa-file-excel me-1"></i>Exportar Excel
        </button>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th><i class="fas fa-id-card me-1"></i>Licencia</th>
                <th><i class="fas fa-user me-1"></i>Propietario</th>
                <th><i class="fas fa-map-marker-alt me-1"></i>Ubicación</th>
                <th><i class="fas fa-briefcase me-1"></i>Actividad</th>
                <th><i class="fas fa-calendar me-1"></i>Vigencia</th>
                <th><i class="fas fa-lock me-1"></i>Estado</th>
                <th class="text-center"><i class="fas fa-cogs me-1"></i>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="lic in resultados" :key="lic.id_licencia">
                <td><span class="badge bg-primary">{{ lic.licencia }}</span></td>
                <td>{{ lic.propietario }}</td>
                <td>{{ lic.ubicacion }}</td>
                <td>{{ lic.actividad }}</td>
                <td>{{ lic.vigente }}</td>
                <td>
                  <span v-if="lic.bloqueado" class="badge bg-danger">
                    <i class="fas fa-lock me-1"></i>Bloqueado
                  </span>
                  <span v-else class="badge bg-success">
                    <i class="fas fa-unlock me-1"></i>Activo
                  </span>
                </td>
                <td class="text-center">
                  <div class="btn-group" role="group">
                    <button @click="verDetalle(lic)" class="btn btn-info btn-sm" title="Ver Detalle">
                      <i class="fas fa-eye"></i>
                    </button>
                    <button v-if="!lic.bloqueado" @click="bloquear(lic)" class="btn btn-warning btn-sm" title="Bloquear">
                      <i class="fas fa-lock"></i>
                    </button>
                    <button v-if="lic.bloqueado" @click="desbloquear(lic)" class="btn btn-success btn-sm" title="Desbloquear">
                      <i class="fas fa-unlock"></i>
                    </button>
                    <button @click="verPagos(lic)" class="btn btn-primary btn-sm" title="Ver Pagos">
                      <i class="fas fa-money-bill"></i>
                    </button>
                    <button @click="verAdeudos(lic)" class="btn btn-danger btn-sm" title="Ver Adeudos">
                      <i class="fas fa-exclamation-triangle"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- Modal de Detalle -->
    <div class="modal fade show d-block" v-if="detalle" style="background-color: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title"><i class="fas fa-info-circle me-2"></i>Detalle de Licencia</h5>
            <button type="button" class="btn-close" @click="detalle = null"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label fw-bold">Licencia:</label>
                <p class="form-control-plaintext">{{ detalle.licencia }}</p>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-bold">Propietario:</label>
                <p class="form-control-plaintext">{{ detalle.propietario }}</p>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-bold">Ubicación:</label>
                <p class="form-control-plaintext">{{ detalle.ubicacion }}</p>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-bold">Actividad:</label>
                <p class="form-control-plaintext">{{ detalle.actividad }}</p>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-bold">Vigencia:</label>
                <p class="form-control-plaintext">{{ detalle.vigente }}</p>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-bold">Estado:</label>
                <p class="form-control-plaintext">
                  <span v-if="detalle.bloqueado" class="badge bg-danger">Bloqueado</span>
                  <span v-else class="badge bg-success">Activo</span>
                </p>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Correo:</label>
                <p class="form-control-plaintext">{{ detalle.email }}</p>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Teléfono:</label>
                <p class="form-control-plaintext">{{ detalle.telefono_prop }}</p>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Zona:</label>
                <p class="form-control-plaintext">{{ detalle.zona }}</p>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Subzona:</label>
                <p class="form-control-plaintext">{{ detalle.subzona }}</p>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Fecha de Otorgamiento:</label>
                <p class="form-control-plaintext">{{ detalle.fecha_otorgamiento }}</p>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Fecha de Baja:</label>
                <p class="form-control-plaintext">{{ detalle.fecha_baja || 'N/A' }}</p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="detalle = null">
              <i class="fas fa-times me-1"></i>Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
    <!-- Modal de Pagos -->
    <div class="modal fade show d-block" v-if="pagos.length" style="background-color: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title"><i class="fas fa-money-bill me-2"></i>Historial de Pagos</h5>
            <button type="button" class="btn-close" @click="pagos = []"></button>
          </div>
          <div class="modal-body">
            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-dark">
                  <tr>
                    <th><i class="fas fa-calendar me-1"></i>Fecha</th>
                    <th><i class="fas fa-dollar-sign me-1"></i>Importe</th>
                    <th><i class="fas fa-user me-1"></i>Cajero</th>
                    <th><i class="fas fa-receipt me-1"></i>Folio</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="p in pagos" :key="p.cvepago">
                    <td>{{ p.fecha }}</td>
                    <td class="text-success fw-bold">${{ p.importe }}</td>
                    <td>{{ p.cajero }}</td>
                    <td><span class="badge bg-info">{{ p.folio }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="pagos = []">
              <i class="fas fa-times me-1"></i>Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Adeudos -->
    <div class="modal fade show d-block" v-if="adeudos.length" style="background-color: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title"><i class="fas fa-exclamation-triangle me-2"></i>Adeudos Pendientes</h5>
            <button type="button" class="btn-close" @click="adeudos = []"></button>
          </div>
          <div class="modal-body">
            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-danger">
                  <tr>
                    <th><i class="fas fa-calendar me-1"></i>Año</th>
                    <th><i class="fas fa-coins me-1"></i>Derechos</th>
                    <th><i class="fas fa-percentage me-1"></i>Recargos</th>
                    <th><i class="fas fa-file-invoice me-1"></i>Formas</th>
                    <th><i class="fas fa-calculator me-1"></i>Saldo</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="a in adeudos" :key="a.axo">
                    <td><span class="badge bg-warning">{{ a.axo }}</span></td>
                    <td class="text-danger fw-bold">${{ a.derechos }}</td>
                    <td class="text-warning fw-bold">${{ a.recargos }}</td>
                    <td>${{ a.formas }}</td>
                    <td class="text-danger fw-bold">${{ a.saldo }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="adeudos = []">
              <i class="fas fa-times me-1"></i>Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Estados de Carga y Error -->
    <div v-if="loading" class="d-flex justify-content-center align-items-center py-5">
      <div class="spinner-border text-primary me-3" role="status"></div>
      <span class="text-primary fw-bold">Cargando...</span>
    </div>

    <div v-if="error" class="alert alert-danger d-flex align-items-center" role="alert">
      <i class="fas fa-exclamation-triangle me-2"></i>
      <div>{{ error }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaLicenciaPage',
  data() {
    return {
      form: {
        licencia: '',
        ubicacion: '',
        propietario: '',
        id_tramite: ''
      },
      resultados: [],
      detalle: null,
      pagos: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarPor(tipo) {
      this.loading = true;
      this.error = '';
      let operation = '';
      let params = {};
      if (tipo === 'licencia') {
        operation = 'search_by_licencia';
        params = { licencia: this.form.licencia };
      } else if (tipo === 'ubicacion') {
        operation = 'search_by_ubicacion';
        params = { ubicacion: this.form.ubicacion };
      } else if (tipo === 'contribuyente') {
        operation = 'search_by_contribuyente';
        params = { propietario: this.form.propietario };
      } else if (tipo === 'tramite') {
        operation = 'search_by_tramite';
        params = { id_tramite: this.form.id_tramite };
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation, params }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.resultados = [];
        } else {
          this.resultados = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    buscar() {
      // Por defecto busca por licencia
      this.buscarPor('licencia');
    },
    verDetalle(lic) {
      this.detalle = lic;
    },
    async verPagos(lic) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'get_pagos', params: { id_licencia: lic.id_licencia } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.pagos = [];
        } else {
          this.pagos = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async verAdeudos(lic) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'get_adeudos', params: { id_licencia: lic.id_licencia, tipo: 'L' } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.adeudos = [];
        } else {
          this.adeudos = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async bloquear(lic) {
      const motivo = prompt('Motivo del bloqueo:');
      if (!motivo) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'bloquear_licencia', params: { id_licencia: lic.id_licencia, tipo_bloqueo: 1, motivo } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          alert('Licencia bloqueada');
          this.buscar();
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async desbloquear(lic) {
      const motivo = prompt('Motivo del desbloqueo:');
      if (!motivo) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'desbloquear_licencia', params: { id_licencia: lic.id_licencia, tipo_bloqueo: 1, motivo } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          alert('Licencia desbloqueada');
          this.buscar();
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'exportar_excel', params: { filtros: this.form } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          // Suponiendo que el backend regresa una URL de descarga
          window.open(res.data.eResponse.result.url, '_blank');
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
/* Estilos adicionales para modales personalizados */
.modal.show {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-dialog {
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from { transform: translateY(-50px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.table th {
  border-top: none;
}

.btn-group .btn {
  margin: 0 1px;
}
</style>
