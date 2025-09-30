<template>
  <div class="bloquear-licencia-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Bloqueo de Licencias</li>
      </ol>
    </nav>
    <div class="municipal-header">
      <i class="fas fa-shield-alt text-white me-2"></i>
      <h1>BLOQUEO DE LICENCIAS</h1>
    </div>
    <div class="municipal-card mb-3">
      <div class="card-body">
        <div class="row align-items-end">
          <div class="col-md-6">
            <label for="licencia" class="form-label">No. de licencia:</label>
            <input v-model="licenciaInput" @keyup.enter="buscarLicencia" type="text" id="licencia" class="form-control" />
          </div>
          <div class="col-md-3">
            <div class="btn-group municipal-group-btn" role="group">
              <button @click="buscarLicencia" class="btn btn-outline-primary">
                <i class="fas fa-search me-1"></i>Buscar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="licencia" class="municipal-card mb-3">
      <div class="card-body">
        <h5 class="card-title mb-3">
          <i class="fas fa-file-contract me-2"></i>Información de la Licencia
        </h5>
        <div class="row mb-2">
          <div class="col-md-6"><strong>Recaudadora:</strong> {{ licencia.recaud }}</div>
          <div class="col-md-6"><strong>Giro:</strong> {{ giro }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-md-12"><strong>Actividad:</strong> {{ licencia.actividad }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-md-12"><strong>Propietario:</strong> {{ licencia.primer_ap }} {{ licencia.segundo_ap }} {{ licencia.propietario }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-md-8"><strong>Ubicación:</strong> {{ licencia.ubicacion }}</div>
          <div class="col-md-2"><strong>No. ext:</strong> {{ licencia.numext_ubic }}</div>
          <div class="col-md-2"><strong>Letra ext:</strong> {{ licencia.letraext_ubic }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-md-2"><strong>No. int:</strong> {{ licencia.numint_ubic }}</div>
          <div class="col-md-2"><strong>Letra int:</strong> {{ licencia.letraint_ubic }}</div>
          <div class="col-md-8"><strong>Estado:</strong> <span :class="{'text-danger': licencia.bloqueado > 0, 'text-success': licencia.bloqueado == 0}" class="fw-bold">{{ estadoLicencia }}</span></div>
        </div>
      </div>
    </div>
    <div v-if="licencia">
      <div class="mb-3">
        <div class="btn-group municipal-group-btn" role="group">
          <button :disabled="licencia.bloqueado > 0" @click="abrirBloqueo" class="btn btn-outline-danger">
            <i class="fas fa-lock me-1"></i>Bloquear licencia
          </button>
          <button :disabled="!bloqueosActivos.length" @click="abrirDesbloqueo" class="btn btn-outline-success">
            <i class="fas fa-unlock me-1"></i>Desbloquear licencia
          </button>
        </div>
      </div>
      <div v-if="showBloqueo" class="municipal-card mb-3">
        <div class="card-body">
          <h5 class="card-title text-danger mb-3">
            <i class="fas fa-lock me-2"></i>Bloquear licencia
          </h5>
          <div class="row mb-3">
            <div class="col-md-6">
              <label class="form-label">Tipo de bloqueo:</label>
              <select v-model="tipoBloqueo" class="form-select">
                <option value="">Seleccione un tipo...</option>
                <option v-for="tipo in tiposBloqueo" :key="tipo.id" :value="tipo.id">{{ tipo.descripcion }}</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Motivo:</label>
              <input v-model="motivoBloqueo" type="text" class="form-control" placeholder="Ingrese el motivo..." />
            </div>
          </div>
          <div class="btn-group municipal-group-btn" role="group">
            <button @click="bloquearLicencia" class="btn btn-outline-danger">
              <i class="fas fa-check me-1"></i>Confirmar bloqueo
            </button>
            <button @click="showBloqueo=false" class="btn btn-outline-secondary">
              <i class="fas fa-times me-1"></i>Cancelar
            </button>
          </div>
        </div>
      </div>
      <div v-if="showDesbloqueo" class="municipal-card mb-3">
        <div class="card-body">
          <h5 class="card-title text-success mb-3">
            <i class="fas fa-unlock me-2"></i>Desbloquear licencia
          </h5>
          <div class="row mb-3">
            <div class="col-md-6">
              <label class="form-label">Seleccione el bloqueo a eliminar:</label>
              <select v-model="tipoDesbloqueo" class="form-select">
                <option value="">Seleccione un bloqueo...</option>
                <option v-for="bloq in bloqueosActivos" :key="bloq.bloqueado" :value="bloq.bloqueado">{{ bloq.descripcion_bloq }}</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Motivo:</label>
              <input v-model="motivoDesbloqueo" type="text" class="form-control" placeholder="Ingrese el motivo..." />
            </div>
          </div>
          <div class="btn-group municipal-group-btn" role="group">
            <button @click="desbloquearLicencia" class="btn btn-outline-success">
              <i class="fas fa-check me-1"></i>Confirmar desbloqueo
            </button>
            <button @click="showDesbloqueo=false" class="btn btn-outline-secondary">
              <i class="fas fa-times me-1"></i>Cancelar
            </button>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="card-body">
          <h5 class="card-title mb-3">
            <i class="fas fa-history me-2"></i>Histórico de bloqueos
          </h5>
          <div class="table-responsive">
            <table class="table table-sm municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Estado</th>
                  <th>Realizó</th>
                  <th>Fecha</th>
                  <th>Vigencia</th>
                  <th>Motivo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="bloq in bloqueos" :key="bloq.fecha_mov + '-' + bloq.bloqueado">
                  <td>{{ bloq.tipo_bloqueo }}</td>
                  <td>{{ bloq.capturista }}</td>
                  <td>{{ bloq.fecha_mov }}</td>
                  <td>{{ bloq.vigente }}</td>
                  <td>{{ bloq.observa }}</td>
                </tr>
                <tr v-if="!bloqueos.length">
                  <td colspan="5" class="text-center text-muted">Sin movimientos registrados</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">
      <i class="fas fa-exclamation-triangle me-2"></i>{{ error }}
    </div>
    <div v-if="success" class="alert alert-success mt-3">
      <i class="fas fa-check-circle me-2"></i>{{ success }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'BloquearLicenciaPage',
  data() {
    return {
      licenciaInput: '',
      licencia: null,
      giro: '',
      bloqueos: [],
      bloqueosActivos: [],
      tiposBloqueo: [],
      tipoBloqueo: '',
      motivoBloqueo: '',
      tipoDesbloqueo: '',
      motivoDesbloqueo: '',
      showBloqueo: false,
      showDesbloqueo: false,
      error: '',
      success: ''
    };
  },
  computed: {
    estadoLicencia() {
      if (!this.licencia) return '';
      switch (this.licencia.bloqueado) {
        case 0: return 'NO BLOQUEADO';
        case 1: return 'BLOQUEADO';
        case 2: return 'ESTADO 1';
        case 3: return 'CABARET';
        case 4: return 'SUSPENDIDA';
        case 5: return 'RESPONSIVA';
        case 6: return 'CONVENIADA';
        case 7: return 'DESGLOSAR LIC';
        default: return 'BLOQUEADO';
      }
    }
  },
  methods: {
    async buscarLicencia() {
      this.error = '';
      this.success = '';
      this.licencia = null;
      this.giro = '';
      this.bloqueos = [];
      this.bloqueosActivos = [];
      this.tiposBloqueo = [];
      this.tipoBloqueo = '';
      this.tipoDesbloqueo = '';
      this.motivoBloqueo = '';
      this.motivoDesbloqueo = '';
      this.showBloqueo = false;
      this.showDesbloqueo = false;
      if (!this.licenciaInput) return;
      try {
        // Buscar licencia
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'buscarLicencia', payload: { licencia: this.licenciaInput } })
        });
        let data = await res.json();
        if (!data.success) throw new Error(data.message);
        this.licencia = data.licencia;
        this.giro = data.giro;
        // Consultar bloqueos
        let res2 = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'consultarBloqueos', payload: { id_licencia: this.licencia.id_licencia } })
        });
        let data2 = await res2.json();
        this.bloqueos = data2.bloqueos;
        this.bloqueosActivos = data2.bloqueos_activos;
        // Catálogo tipo bloqueo
        let res3 = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'catalogoTipoBloqueo' })
        });
        let data3 = await res3.json();
        this.tiposBloqueo = data3.tipos;
      } catch (e) {
        this.error = e.message;
      }
    },
    abrirBloqueo() {
      this.showBloqueo = true;
      this.showDesbloqueo = false;
      this.tipoBloqueo = '';
      this.motivoBloqueo = '';
    },
    abrirDesbloqueo() {
      this.showDesbloqueo = true;
      this.showBloqueo = false;
      this.tipoDesbloqueo = '';
      this.motivoDesbloqueo = '';
    },
    async bloquearLicencia() {
      this.error = '';
      this.success = '';
      if (!this.tipoBloqueo || !this.motivoBloqueo) {
        this.error = 'Seleccione tipo de bloqueo y motivo';
        return;
      }
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'bloquearLicencia',
            payload: {
              id_licencia: this.licencia.id_licencia,
              tipo_bloqueo: this.tipoBloqueo,
              motivo: this.motivoBloqueo
            }
          })
        });
        let data = await res.json();
        if (!data.success) throw new Error(data.message);
        this.success = data.message;
        this.buscarLicencia();
        this.showBloqueo = false;
      } catch (e) {
        this.error = e.message;
      }
    },
    async desbloquearLicencia() {
      this.error = '';
      this.success = '';
      if (!this.tipoDesbloqueo || !this.motivoDesbloqueo) {
        this.error = 'Seleccione el bloqueo y motivo';
        return;
      }
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'desbloquearLicencia',
            payload: {
              id_licencia: this.licencia.id_licencia,
              tipo_bloqueo: this.tipoDesbloqueo,
              motivo: this.motivoDesbloqueo
            }
          })
        });
        let data = await res.json();
        if (!data.success) throw new Error(data.message);
        this.success = data.message;
        this.buscarLicencia();
        this.showDesbloqueo = false;
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.bloquear-licencia-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
}

/* Municipal Header */
.municipal-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  padding: 1.5rem 2rem;
  border-radius: var(--radius-lg);
  margin-bottom: 2rem;
  display: flex;
  align-items: center;
  box-shadow: var(--shadow-md);
}

.municipal-header h1 {
  margin: 0;
  font-weight: var(--font-weight-bold);
  font-size: 1.75rem;
}

/* Municipal Cards */
.municipal-card {
  background: white;
  border: none;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  border-top: 4px solid var(--municipal-primary);
  transition: var(--transition-normal);
}

.municipal-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.municipal-card .card-title {
  color: var(--municipal-primary);
  font-weight: var(--font-weight-bold);
  border-bottom: 2px solid var(--slate-100);
  padding-bottom: 0.5rem;
}

/* Municipal Button Groups */
.municipal-group-btn {
  box-shadow: var(--shadow-sm);
  border-radius: var(--radius-md);
}

.municipal-group-btn .btn {
  border: 1px solid var(--municipal-primary);
  font-weight: var(--font-weight-bold);
  transition: var(--transition-normal);
  font-family: var(--font-municipal);
}

.municipal-group-btn .btn-outline-primary {
  color: var(--municipal-primary);
  background: white;
}

.municipal-group-btn .btn-outline-primary:hover,
.municipal-group-btn .btn-outline-primary:focus {
  background: var(--municipal-primary);
  border-color: var(--municipal-primary);
  color: white;
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.municipal-group-btn .btn-outline-danger {
  color: var(--municipal-danger);
  border-color: var(--municipal-danger);
  background: white;
}

.municipal-group-btn .btn-outline-danger:hover,
.municipal-group-btn .btn-outline-danger:focus {
  background: var(--municipal-danger);
  border-color: var(--municipal-danger);
  color: white;
}

.municipal-group-btn .btn-outline-success {
  color: var(--municipal-success);
  border-color: var(--municipal-success);
  background: white;
}

.municipal-group-btn .btn-outline-success:hover,
.municipal-group-btn .btn-outline-success:focus {
  background: var(--municipal-success);
  border-color: var(--municipal-success);
  color: white;
}

.municipal-group-btn .btn-outline-secondary {
  color: var(--slate-600);
  border-color: var(--slate-300);
  background: white;
}

.municipal-group-btn .btn-outline-secondary:hover,
.municipal-group-btn .btn-outline-secondary:focus {
  background: var(--slate-100);
  border-color: var(--slate-400);
  color: var(--slate-700);
}

/* Municipal Tables */
.municipal-table {
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.municipal-table-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
}

.municipal-table-header th {
  border: none;
  font-weight: var(--font-weight-bold);
  padding: 1rem;
  font-family: var(--font-municipal);
}

.municipal-table td {
  border: none;
  border-bottom: 1px solid var(--slate-100);
  padding: 0.75rem 1rem;
  transition: var(--transition-normal);
}

.municipal-table tr:hover td {
  background-color: var(--slate-50);
}

.municipal-table tr:last-child td {
  border-bottom: none;
}

/* Form Controls */
.form-control,
.form-select {
  border: 2px solid var(--slate-200);
  border-radius: var(--radius-md);
  padding: 0.75rem 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
}

.form-control:focus,
.form-select:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
  outline: none;
}

.form-label {
  font-weight: var(--font-weight-bold);
  color: var(--slate-700);
  font-family: var(--font-municipal);
}

/* Status Colors */
.text-danger {
  color: var(--municipal-danger) !important;
  font-weight: var(--font-weight-bold);
}

.text-success {
  color: var(--municipal-success) !important;
  font-weight: var(--font-weight-bold);
}

.text-warning {
  color: var(--municipal-warning) !important;
  font-weight: var(--font-weight-bold);
}

/* Alert Styling */
.alert {
  border: none;
  border-radius: var(--radius-md);
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
}

.alert-danger {
  background-color: rgba(233, 108, 176, 0.1);
  color: var(--municipal-danger);
  border-left: 4px solid var(--municipal-danger);
}

.alert-success {
  background-color: rgba(108, 202, 152, 0.1);
  color: var(--municipal-success);
  border-left: 4px solid var(--municipal-success);
}

/* Responsive */
@media (max-width: 768px) {
  .bloquear-licencia-page {
    padding: 1rem 0.5rem;
  }

  .municipal-header {
    padding: 1rem;
    text-align: center;
  }

  .municipal-header h1 {
    font-size: 1.5rem;
  }

  .btn-group {
    display: flex;
    flex-direction: column;
    width: 100%;
  }

  .btn-group .btn {
    border-radius: var(--radius-md) !important;
    margin-bottom: 0.5rem;
  }

  .table-responsive {
    font-size: 0.85rem;
  }
}
</style>
