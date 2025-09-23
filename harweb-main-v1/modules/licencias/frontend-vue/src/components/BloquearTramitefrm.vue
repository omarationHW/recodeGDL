<template>
  <div class="bloquear-tramite-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Bloqueo de Trámites</li>
      </ol>
    </nav>
    <h2 class="mb-4">Bloqueo de Trámites</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="buscarTramite">
          <div class="form-group row">
            <label for="idTramite" class="col-sm-2 col-form-label">No. de trámite:</label>
            <div class="col-sm-4">
              <input type="number" v-model="idTramite" id="idTramite" class="form-control" required @keyup.enter="buscarTramite" />
            </div>
            <div class="col-sm-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="tramite" class="card mb-3">
      <div class="card-body">
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Actividad:</div>
          <div class="col-sm-10">{{ tramite.actividad }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Recaudadora:</div>
          <div class="col-sm-2">{{ tramite.recaud }}</div>
          <div class="col-sm-1 font-weight-bold">Giro:</div>
          <div class="col-sm-7">{{ giroDescripcion }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Propietario:</div>
          <div class="col-sm-10">{{ propietarioNvo }}</div>
        </div>
        <div class="row mb-2">
          <div class="col-sm-2 font-weight-bold">Ubicación:</div>
          <div class="col-sm-4">{{ tramite.ubicacion }}</div>
          <div class="col-sm-1 font-weight-bold">No. ext.:</div>
          <div class="col-sm-1">{{ tramite.numext_ubic }}</div>
          <div class="col-sm-1 font-weight-bold">Letra ext.:</div>
          <div class="col-sm-1">{{ tramite.letraext_ubic }}</div>
          <div class="col-sm-1 font-weight-bold">No. int.:</div>
          <div class="col-sm-1">{{ tramite.numint_ubic }}</div>
          <div class="col-sm-1 font-weight-bold">Letra int.:</div>
          <div class="col-sm-1">{{ tramite.letraint_ubic }}</div>
        </div>
      </div>
    </div>
    <div v-if="tramite" class="mb-3">
      <button class="btn btn-danger mr-2" :disabled="tramite.bloqueado" @click="bloquearTramite">Bloquear trámite</button>
      <button class="btn btn-success" :disabled="!tramite.bloqueado" @click="desbloquearTramite">Desbloquear trámite</button>
    </div>
    <div v-if="bloqueos && bloqueos.length" class="card">
      <div class="card-header">Movimientos sobre el trámite</div>
      <div class="card-body p-0">
        <table class="table table-striped mb-0">
          <thead>
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
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
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
  padding: 2rem 0;
}
</style>
