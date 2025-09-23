<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-lock me-2 text-warning"></i>
              Bloquear Licencia
            </h2>
            <p class="text-muted mb-0">Gestión de bloqueos y desbloqueos de licencias</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Bloquear Licencia</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-search me-2"></i>
          Buscar Licencia
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3 align-items-end">
          <div class="col-md-4">
            <label for="numeroLicencia" class="form-label">Número de Licencia</label>
            <input 
              type="number" 
              class="form-control" 
              id="numeroLicencia"
              v-model="numeroLicencia"
              placeholder="Ingrese número de licencia"
              @keyup.enter="buscarLicencia"
            >
          </div>
          <div class="col-md-2">
            <button 
              type="button" 
              class="btn btn-primary w-100"
              @click="buscarLicencia"
              :disabled="buscando || !numeroLicencia"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="licencia" class="licencia-info">
      <div><strong>Recaudadora:</strong> {{ licencia.recaud }}</div>
      <div><strong>Giro:</strong> {{ giro }}</div>
      <div><strong>Actividad:</strong> {{ licencia.actividad }}</div>
      <div><strong>Propietario:</strong> {{ licencia.primer_ap }} {{ licencia.segundo_ap }} {{ licencia.propietario }}</div>
      <div><strong>Ubicación:</strong> {{ licencia.ubicacion }} No. ext: {{ licencia.numext_ubic }} letra ext: {{ licencia.letraext_ubic }} No. int: {{ licencia.numint_ubic }} letra int: {{ licencia.letraint_ubic }}</div>
      <div><strong>Estado:</strong> <span :class="{'bloqueado': licencia.bloqueado > 0, 'no-bloqueado': licencia.bloqueado == 0}">{{ estadoLicencia }}</span></div>
    </div>
    <div v-if="licencia">
      <div class="actions">
        <button :disabled="licencia.bloqueado > 0" @click="abrirBloqueo">Bloquear licencia</button>
        <button :disabled="!bloqueosActivos.length" @click="abrirDesbloqueo">Desbloquear licencia</button>
      </div>
      <div v-if="showBloqueo">
        <h3>Bloquear licencia</h3>
        <label>Tipo de bloqueo:</label>
        <select v-model="tipoBloqueo">
          <option v-for="tipo in tiposBloqueo" :key="tipo.id" :value="tipo.id">{{ tipo.descripcion }}</option>
        </select>
        <label>Motivo:</label>
        <input v-model="motivoBloqueo" type="text" />
        <button @click="bloquearLicencia">Confirmar bloqueo</button>
        <button @click="showBloqueo=false">Cancelar</button>
      </div>
      <div v-if="showDesbloqueo">
        <h3>Desbloquear licencia</h3>
        <label>Seleccione el bloqueo a eliminar:</label>
        <select v-model="tipoDesbloqueo">
          <option v-for="bloq in bloqueosActivos" :key="bloq.bloqueado" :value="bloq.bloqueado">{{ bloq.descripcion_bloq }}</option>
        </select>
        <label>Motivo:</label>
        <input v-model="motivoDesbloqueo" type="text" />
        <button @click="desbloquearLicencia">Confirmar desbloqueo</button>
        <button @click="showDesbloqueo=false">Cancelar</button>
      </div>
      <h3>Histórico de bloqueos</h3>
      <table class="bloqueos-table">
        <thead>
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
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
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
  padding: 2rem;
}
.search-section {
  margin-bottom: 1rem;
}
.licencia-info {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1rem;
}
.actions {
  margin-bottom: 1rem;
}
.bloqueos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.bloqueos-table th, .bloqueos-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.bloqueado { color: red; font-weight: bold; }
.no-bloqueado { color: green; font-weight: bold; }
.error { color: red; margin-top: 1rem; }
.success { color: green; margin-top: 1rem; }
</style>
