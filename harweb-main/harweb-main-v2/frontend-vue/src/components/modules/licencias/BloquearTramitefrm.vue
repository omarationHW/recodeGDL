<template>
  <div class="bloquear-tramite-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Bloqueo de Trámites</li>
      </ol>
    </nav>
    <div class="municipal-header">
      <i class="fas fa-file-alt text-white me-2"></i>
      <h2>BLOQUEO DE TRÁMITES</h2>
    </div>
    <div class="municipal-card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarTramite">
          <div class="row align-items-end">
            <div class="col-md-6">
              <label for="idTramite" class="form-label">No. de trámite:</label>
              <input type="number" v-model="idTramite" id="idTramite" class="form-control" required @keyup.enter="buscarTramite" placeholder="Ingrese el número de trámite..." />
            </div>
            <div class="col-md-3">
              <div class="btn-group municipal-group-btn" role="group">
                <button type="submit" class="btn btn-outline-primary">
                  <i class="fas fa-search me-1"></i>Buscar
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="tramite" class="municipal-card mb-3">
      <div class="card-body">
        <h5 class="card-title mb-3">
          <i class="fas fa-info-circle me-2"></i>Información del Trámite
          <span v-if="tramite.bloqueado" class="badge bg-danger ms-2">BLOQUEADO</span>
          <span v-else class="badge bg-success ms-2">ACTIVO</span>
        </h5>
        <div class="row mb-2">
          <div class="col-sm-12"><strong>Actividad:</strong> {{ tramite.actividad }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-4"><strong>Recaudadora:</strong> {{ tramite.recaud }}</div>
          <div class="col-sm-8"><strong>Giro:</strong> {{ giroDescripcion }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-12"><strong>Propietario:</strong> {{ propietarioNvo }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-6"><strong>Ubicación:</strong> {{ tramite.ubicacion }}</div>
          <div class="col-sm-2"><strong>No. ext:</strong> {{ tramite.numext_ubic }}</div>
          <div class="col-sm-2"><strong>Letra ext:</strong> {{ tramite.letraext_ubic }}</div>
          <div class="col-sm-2"><strong>No. int:</strong> {{ tramite.numint_ubic }}</div>
        </div>
        <div class="row">
          <div class="col-sm-2"><strong>Letra int:</strong> {{ tramite.letraint_ubic }}</div>
        </div>
      </div>
    </div>
    <div v-if="tramite" class="mb-3">
      <div class="btn-group municipal-group-btn" role="group">
        <button class="btn btn-outline-danger" :disabled="tramite.bloqueado" @click="bloquearTramite">
          <i class="fas fa-lock me-1"></i>Bloquear trámite
        </button>
        <button class="btn btn-outline-success" :disabled="!tramite.bloqueado" @click="desbloquearTramite">
          <i class="fas fa-unlock me-1"></i>Desbloquear trámite
        </button>
      </div>
    </div>
    <div v-if="bloqueos && bloqueos.length" class="municipal-card">
      <div class="card-body">
        <h5 class="card-title mb-3">
          <i class="fas fa-history me-2"></i>Movimientos sobre el trámite
        </h5>
        <div class="table-responsive">
          <table class="table table-sm municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Estado</th>
                <th>Realizó</th>
                <th>Fecha</th>
                <th>Motivo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bloqueo in bloqueos" :key="bloqueo.id">
                <td>{{ bloqueo.estado }}</td>
                <td>{{ bloqueo.capturista }}</td>
                <td>{{ bloqueo.fecha_mov }}</td>
                <td>{{ bloqueo.observa }}</td>
              </tr>
            </tbody>
          </table>
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
  name: 'BloquearTramitePage',
  data() {
    return {
      idTramite: '',
      tramite: null,
      bloqueos: [],
      giroDescripcion: '',
      error: '',
      success: ''
    };
  },
  computed: {
    propietarioNvo() {
      if (!this.tramite) return '';
      return [
        this.tramite.primer_ap ? this.tramite.primer_ap.trim() : '',
        this.tramite.segundo_ap ? this.tramite.segundo_ap.trim() : '',
        this.tramite.propietario ? this.tramite.propietario.trim() : ''
      ].join(' ').replace(/ +/g, ' ').trim();
    }
  },
  methods: {
    async buscarTramite() {
      this.error = '';
      this.success = '';
      this.tramite = null;
      this.bloqueos = [];
      this.giroDescripcion = '';
      if (!this.idTramite) return;
      try {
        // Obtener tramite
        let res = await this.apiRequest('getTramite', { id_tramite: this.idTramite });
        if (!res.success || !res.data.length) {
          this.error = 'No se encontró trámite con ese número';
          return;
        }
        this.tramite = res.data[0];
        // Obtener giro
        let giroRes = await this.apiRequest('getGiroDescripcion', { id_giro: this.tramite.id_giro });
        this.giroDescripcion = giroRes.success && giroRes.data.length ? giroRes.data[0].descripcion : '';
        // Obtener bloqueos
        let bloqueosRes = await this.apiRequest('getBloqueos', { id_tramite: this.idTramite });
        this.bloqueos = bloqueosRes.success ? bloqueosRes.data : [];
      } catch (e) {
        this.error = e.message || 'Error al buscar trámite';
      }
    },
    async bloquearTramite() {
      if (!this.tramite) return;
      const observa = prompt('Bloqueando trámite...\nObservaciones:', '');
      if (observa === null) return;
      try {
        let res = await this.apiRequest('bloquearTramite', {
          id_tramite: this.tramite.id_tramite,
          observa,
          capturista: this.tramite.capturista || 'usuario'
        });
        if (res.success) {
          this.success = 'Trámite bloqueado correctamente';
          await this.buscarTramite();
        } else {
          this.error = res.message || 'No se pudo bloquear el trámite';
        }
      } catch (e) {
        this.error = e.message || 'Error al bloquear trámite';
      }
    },
    async desbloquearTramite() {
      if (!this.tramite) return;
      const observa = prompt('Desbloqueando trámite...\nObservaciones:', '');
      if (observa === null) return;
      try {
        let res = await this.apiRequest('desbloquearTramite', {
          id_tramite: this.tramite.id_tramite,
          observa,
          capturista: this.tramite.capturista || 'usuario'
        });
        if (res.success) {
          this.success = 'Trámite desbloqueado correctamente';
          await this.buscarTramite();
        } else {
          this.error = res.message || 'No se pudo desbloquear el trámite';
        }
      } catch (e) {
        this.error = e.message || 'Error al desbloquear trámite';
      }
    },
    async apiRequest(action, params) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const data = await res.json();
      return data.eResponse;
    }
  }
};
</script>

<style scoped>
.bloquear-tramite-page {
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

.municipal-header h2 {
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
.form-control {
  border: 2px solid var(--slate-200);
  border-radius: var(--radius-md);
  padding: 0.75rem 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
}

.form-control:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
  outline: none;
}

.form-label {
  font-weight: var(--font-weight-bold);
  color: var(--slate-700);
  font-family: var(--font-municipal);
}

/* Badges */
.badge {
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
}

.bg-danger {
  background-color: var(--municipal-danger) !important;
}

.bg-success {
  background-color: var(--municipal-success) !important;
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
  .bloquear-tramite-page {
    padding: 1rem 0.5rem;
  }

  .municipal-header {
    padding: 1rem;
    text-align: center;
  }

  .municipal-header h2 {
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

  .row .col-sm-1,
  .row .col-sm-2 {
    margin-bottom: 0.5rem;
  }
}
</style>
